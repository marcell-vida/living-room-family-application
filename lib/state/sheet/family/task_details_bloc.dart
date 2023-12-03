import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/service/storage/storage_service.dart';
import 'package:living_room/util/utils.dart';

/// [TaskDetailsCubit] manages [FamilyMemberTask] creations and modifications
class TaskDetailsCubit extends Cubit<TaskDetailsState> {
  final String? existingTaskId;
  final String familyId;
  final String userId;
  final AuthenticationService _authenticationService;
  final DatabaseService _databaseService;
  final StorageService _storageService;
  StreamSubscription? _existingTaskStreamSubscription;
  StreamSubscription? _memberStreamSubscription;

  TaskDetailsCubit(
      {required AuthenticationService authenticationService,
      required DatabaseService databaseService,
      required StorageService storageService,
      required this.familyId,
      required this.userId,
      this.existingTaskId})
      : _authenticationService = authenticationService,
        _databaseService = databaseService,
        _storageService = storageService,
        super(const TaskDetailsState()) {
    _init();
  }

  Future<void> _init() async {
    /// family member stream
    _memberStreamSubscription = _databaseService
        .streamFamilyMember(familyId: familyId, userId: userId)
        .listen((familyMember) {
      emit(state.copyWith(familyMember: familyMember));
    });
    if (existingTaskId != null) {
      FamilyMemberTask? task = await _databaseService.getFamilyMemberTask(
          familyId: familyId, userId: userId, taskId: existingTaskId!);

      if (task != null) {
        /// default values
        emit(state.copyWith(
            title: task.title,
            description: task.description,
            points: task.points,
            taskDetailsMode: TaskDetailsMode.viewing));
      }

      /// existing task stream
      _existingTaskStreamSubscription = _databaseService
          .streamFamilyMemberTask(
              familyId: familyId, userId: userId, taskId: existingTaskId!)
          .listen((FamilyMemberTask? newTask) {
        emit(state.copyWith(existingTask: newTask));
      });
    } else {
      emit(state.copyWith(taskDetailsMode: TaskDetailsMode.editing));
    }
  }

  Future<void> finish({bool? setTo}) async {
    if (existingTaskId == null ||
        state.saveStatus == ProcessStatus.processing) {
      /// not valid task or already processing previous task
      return;
    }

    emit(state.copyWith(saveStatus: ProcessStatus.processing));

    bool newFinishedValue = setTo ?? !(state.existingTask!.isFinished ?? false);

    await _databaseService.changeFinishStatusOfFamilyMemberTask(
        familyUid: familyId,
        userUid: userId,
        taskUid: existingTaskId!,
        finished: newFinishedValue,
        onError: () {
          /// update task succeeded
          emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
        },
        onSuccess: () {
          /// update task failed
          emit(state.copyWith(saveStatus: ProcessStatus.successful));
        });
  }

  Future<void> approve({bool? setTo}) async {
    if (existingTaskId == null ||
        state.saveStatus == ProcessStatus.processing) {
      /// not valid task or already processing previous task
      return;
    }

    emit(state.copyWith(saveStatus: ProcessStatus.processing));

    if (state.familyMember == null) {
      /// cannot edit FamilyMember
      emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
      return;
    }

    int pointsCollected = state.familyMember!.pointsCollected ?? 0;

    int pointsOfTask = state.existingTask?.points ?? state.points ?? 0;

    bool newFinishedValue = setTo ?? !(state.existingTask!.isFinished ?? false);

    int newPoints = newFinishedValue
        ? pointsCollected + pointsOfTask
        : pointsCollected - pointsOfTask;

    await _databaseService.updateFamilyMember(
        familyId: familyId,
        userId: userId,
        pointsCollected: newPoints,
        onError: () {
          /// adding points to member failed
          emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
        },
        onSuccess: () async {
          /// adding points to member succeeded -> update task
          await _databaseService.changeApprovedStatusOfFamilyMemberTask(
              familyUid: familyId,
              userUid: userId,
              taskUid: existingTaskId!,
              approved: newFinishedValue,
              authenticationService: _authenticationService,
              onError: () {
                emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
              },
              onSuccess: () {
                emit(state.copyWith(saveStatus: ProcessStatus.successful));
              });
        });
  }

  Future<void> save() async {
    emit(state.copyWith(
        saveStatus: ProcessStatus.processing,
        taskDetailsMode: TaskDetailsMode.loading));
    String name = state.title ?? state.existingTask?.title ?? '';
    if (name.isNotEmpty) {
      /// function to save picture after creation
      saveTaskPhotoToDb({String? taskId}) {
        String photoTaskId = taskId ?? existingTaskId ?? '';
        if (photoTaskId.isNotEmpty) {
          _storageService.changeTaskPicture(
              localFilePath: state.taskPhotoUploadPath!,
              uploadName:
                  '$photoTaskId${DateTime.now().millisecondsSinceEpoch}',
              familyUid: familyId,
              userUid: userId,
              taskUid: photoTaskId,
              onSuccess: (String url) {
                _databaseService.updateFamilyMemberTask(
                    familyUid: familyId,
                    userUid: userId,
                    taskUid: photoTaskId,
                    photoUrl: url,
                    onSuccess: () => emit(
                        state.copyWith(saveStatus: ProcessStatus.successful)),
                    onError: () => emit(state.copyWith(
                        saveStatus: ProcessStatus.unsuccessful)));
              });
        }
      }

      if (existingTaskId != null) {
        // task update
        await _databaseService.updateFamilyMemberTask(
            familyUid: familyId,
            userUid: userId,
            taskUid: existingTaskId!,
            title: state.title ?? state.existingTask?.title,
            description: state.description ?? state.existingTask?.description,
            deadLine: state.deadLine ?? state.existingTask?.deadline,
            points: state.points ?? state.existingTask?.points,
            onError: () {
              emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
            },
            onSuccess: () {
              if (state.taskPhotoUploadPath.isNotEmptyOrNull) {
                // photo has to be saved
                saveTaskPhotoToDb();
              } else {
                emit(state.copyWith(saveStatus: ProcessStatus.successful));
              }
            });
      } else {
        // task creation
        FamilyMemberTask? result =
            await _databaseService.createFamilyMemberTask(
                familyUid: familyId,
                userUid: userId,
                title: state.title ?? state.existingTask?.title,
                description:
                    state.description ?? state.existingTask?.description,
                deadLine: state.deadLine ?? state.existingTask?.deadline,
                points: state.points);

        if (result?.id == null) {
          emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
        } else {
          if (state.taskPhotoUploadPath.isNotEmptyOrNull) {
            saveTaskPhotoToDb(taskId: result!.id);
          } else {
            emit(state.copyWith(saveStatus: ProcessStatus.successful));
          }
        }
      }
    }
  }

  void approveTaskPhotoPath(bool? approve) {
    if (approve == true && state.taskPhotoTempPath.isNotEmptyOrNull) {
      emit(state.copyWith(taskPhotoUploadPath: state.taskPhotoTempPath));
    }
  }

  void approveFinishedPhotoPath(bool? approve) {
    if (approve == true && state.finishedPhotoTempPath.isNotEmptyOrNull) {
      emit(
          state.copyWith(finishedPhotoUploadPath: state.finishedPhotoTempPath));
    }
  }

  void setMode(TaskDetailsMode? newValue) {
    if (newValue != null) {
      emit(state.copyWith(taskDetailsMode: newValue));
    }
  }

  void setTitle(String? title) {
    if (title != null) emit(state.copyWith(title: title));
  }

  void setDeadline(DateTime? deadLine) {
    if (deadLine != null) emit(state.copyWith(deadLine: deadLine));
  }

  void setDescription(String? description) {
    if (description != null) emit(state.copyWith(description: description));
  }

  void setPoints(int? points) {
    if (points != null) emit(state.copyWith(points: points));
  }

  void setTaskPhotoTempPath(String? path) {
    if (path != null) emit(state.copyWith(taskPhotoTempPath: path));
  }

  void setFinishedPhotoTempPath(String? path) {
    if (path != null) emit(state.copyWith(finishedPhotoTempPath: path));
  }

  @override
  Future<void> close() {
    _memberStreamSubscription?.cancel();
    _existingTaskStreamSubscription?.cancel();
    return super.close();
  }
}

enum TaskDetailsMode { viewing, editing, loading }

class TaskDetailsState extends Equatable {
  final FamilyMemberTask? existingTask;
  final FamilyMember? familyMember;
  final String? title;
  final String? description;
  final String? taskPhotoUploadPath;
  final String? taskPhotoTempPath;
  final DateTime? deadLine;
  final bool? isFinished;
  final bool? isFinishApproved;
  final String? finishedPhotoUploadPath;
  final String? finishedPhotoTempPath;
  final int? points;
  final ProcessStatus saveStatus;
  final TaskDetailsMode? taskDetailsMode;
  final bool updateFlag;

  const TaskDetailsState(
      {this.familyMember,
      this.existingTask,
      this.title,
      this.description,
      this.finishedPhotoUploadPath,
      this.finishedPhotoTempPath,
      this.taskPhotoUploadPath,
      this.taskPhotoTempPath,
      this.deadLine,
      this.isFinishApproved,
      this.isFinished,
      this.points,
      this.saveStatus = ProcessStatus.idle,
      this.taskDetailsMode,
      this.updateFlag = true});

  TaskDetailsState copyWith(
      {FamilyMember? familyMember,
      FamilyMemberTask? existingTask,
      String? title,
      String? description,
      String? taskPhotoUploadPath,
      String? taskPhotoTempPath,
      String? finishedPhotoTempPath,
      DateTime? deadLine,
      bool? isFinished,
      bool? isFinishApproved,
      String? finishedPhotoUploadPath,
      int? points,
      ProcessStatus? saveStatus,
      TaskDetailsMode? taskDetailsMode}) {
    return TaskDetailsState(
        familyMember: familyMember ?? this.familyMember,
        existingTask: existingTask ?? this.existingTask,
        title: title ?? this.title,
        description: description ?? this.description,
        finishedPhotoUploadPath:
            finishedPhotoUploadPath ?? this.finishedPhotoUploadPath,
        finishedPhotoTempPath:
            finishedPhotoTempPath ?? this.finishedPhotoTempPath,
        taskPhotoUploadPath: taskPhotoUploadPath ?? this.taskPhotoUploadPath,
        taskPhotoTempPath: taskPhotoTempPath ?? this.taskPhotoTempPath,
        deadLine: deadLine ?? this.deadLine,
        saveStatus: saveStatus ?? this.saveStatus,
        isFinishApproved: isFinishApproved ?? this.isFinishApproved,
        isFinished: isFinished ?? this.isFinished,
        points: points ?? this.points,
        taskDetailsMode: taskDetailsMode ?? this.taskDetailsMode,
        updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [
        familyMember,
        existingTask,
        title,
        description,
        finishedPhotoUploadPath,
        taskPhotoUploadPath,
        deadLine,
        saveStatus,
        isFinishApproved,
        isFinished,
        points,
        taskDetailsMode,
        updateFlag
      ];
}
