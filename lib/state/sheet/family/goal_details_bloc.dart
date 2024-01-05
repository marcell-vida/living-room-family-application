import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/service/storage/storage_service.dart';
import 'package:living_room/util/utils.dart';

/// [GoalDetailsCubit] manages [FamilyMemberGoal] creations and modifications
class GoalDetailsCubit extends Cubit<GoalDetailsState> {
  final String? existingGoalId;
  final String familyId;
  final String userId;
  final DatabaseService _databaseService;
  final StorageService _storageService;
  StreamSubscription? _existingGoalStreamSubscription;
  StreamSubscription? _memberStreamSubscription;

  GoalDetailsCubit(
      {required AuthenticationService authenticationService,
      required DatabaseService databaseService,
      required StorageService storageService,
      required this.familyId,
      required this.userId,
      this.existingGoalId})
      : _databaseService = databaseService,
        _storageService = storageService,
        super(const GoalDetailsState()) {
    debugPrint('EditGoalCubit created');
    _init();
  }

  Future<void> _init() async {
    /// family member stream
    _memberStreamSubscription = _databaseService
        .streamFamilyMember(familyId: familyId, userId: userId)
        .listen((familyMember) {
      emit(state.copyWith(familyMember: familyMember));
    });
    if (existingGoalId != null) {
      FamilyMemberGoal? goal = await _databaseService.getFamilyMemberGoal(
          familyId: familyId, userId: userId, goalId: existingGoalId!);

      if (goal != null) {
        emit(state.copyWith(
            title: goal.title,
            description: goal.description,
            points: goal.points,
            goalDetailsMode: GoalDetailsMode.viewing));
      }

      _existingGoalStreamSubscription = _databaseService
          .streamFamilyMemberGoal(
              familyId: familyId, userId: userId, goalId: existingGoalId!)
          .listen((FamilyMemberGoal? goal) {
        emit(state.copyWith(existingGoal: goal));
      });
    } else {
      emit(state.copyWith(goalDetailsMode: GoalDetailsMode.editing));
    }
  }

  Future<void> save() async {
    emit(state.copyWith(
        saveStatus: ProcessStatus.processing,
        goalDetailsMode: GoalDetailsMode.loading));
    String name = state.title ?? state.existingGoal?.title ?? '';
    if (name.isNotEmpty) {
      /// function to save picture later
      saveGoalPhotoToDb({String? newGoalId}) {
        String photoGoalId = newGoalId ?? state.existingGoal?.id ?? '';
        if (photoGoalId.isNotEmpty) {
          _storageService.changeGoalPicture(
              localFilePath: state.goalPhotoUploadPath!,
              uploadName:
                  '$photoGoalId${DateTime.now().millisecondsSinceEpoch}',
              familyUid: familyId,
              userUid: userId,
              goalUid: photoGoalId,
              onSuccess: (String url) {
                _databaseService.updateFamilyMemberGoal(
                    familyId: familyId,
                    userId: userId,
                    goalId: photoGoalId,
                    photoUrl: url,
                    onSuccess: () => emit(
                        state.copyWith(saveStatus: ProcessStatus.successful)),
                    onError: () => emit(state.copyWith(
                        saveStatus: ProcessStatus.unsuccessful)));
              });
        }
      }

      if (existingGoalId != null) {
        /// goal update
        await _databaseService.updateFamilyMemberGoal(
            familyId: familyId,
            userId: userId,
            goalId: existingGoalId!,
            title: state.title ?? state.existingGoal?.title,
            description: state.description ?? state.existingGoal?.description,
            isAchieved: state.isAchieved ?? state.existingGoal?.isAchieved,
            isApproved: state.isApproved ?? state.existingGoal?.isApproved,
            points: state.points ?? state.existingGoal?.points,
            onError: () {
              emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
            },
            onSuccess: () {
              if (state.goalPhotoUploadPath.isNotEmptyOrNull) {
                // photo has to be saved
                saveGoalPhotoToDb();
              } else {
                emit(state.copyWith(saveStatus: ProcessStatus.successful));
              }
            });
      } else {
        // goal creation
        FamilyMemberGoal? result =
            await _databaseService.createFamilyMemberGoal(
                familyId: familyId,
                userId: userId,
                title: state.title ?? state.existingGoal?.title,
                description:
                    state.description ?? state.existingGoal?.description,
                points: state.points);

        if (result.id == null) {
          emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
        } else {
          if (state.goalPhotoUploadPath.isNotEmptyOrNull) {
            saveGoalPhotoToDb(newGoalId: result.id);
          } else {
            emit(state.copyWith(saveStatus: ProcessStatus.successful));
          }
        }
      }
    }
  }

  void claim() {
    if (state.saveStatus == ProcessStatus.processing ||
        (state.familyMember?.pointsCollected ?? 0) <
            (state.existingGoal?.points ?? 0) ||
        state.existingGoal?.isApproved == true) return;

    _setStatus(ProcessStatus.processing);

    int pointsCollectedNew = (state.familyMember?.pointsCollected ?? 0) -
        (state.existingGoal?.points ?? 0);

    if (pointsCollectedNew < 0) {
      _setStatus(ProcessStatus.unsuccessful);
      return;
    }

    _databaseService.updateFamilyMember(
        familyId: familyId,
        userId: userId,
        pointsCollected: pointsCollectedNew,
        onError: () {
          _setStatus(ProcessStatus.unsuccessful);
        },
        onSuccess: () {
          if (existingGoalId == null) {
            _setStatus(ProcessStatus.unsuccessful);
            return;
          }
          _databaseService.updateFamilyMemberGoal(
              familyId: familyId,
              userId: userId,
              goalId: existingGoalId!,
              isAchieved: true,
              isApproved: false,
              onError: () {
                _setStatus(ProcessStatus.unsuccessful);
              },
              onSuccess: () {
                _setStatus(ProcessStatus.successful);
              });
        });
  }

  void approve() {
    if (state.saveStatus == ProcessStatus.processing ||
        state.existingGoal?.isApproved == true ||
        state.existingGoal?.isAchieved != true) return;

    _setStatus(ProcessStatus.processing);

    _databaseService.updateFamilyMemberGoal(
        familyId: familyId,
        userId: userId,
        goalId: existingGoalId!,
        isApproved: true,
        onError: () {
          _setStatus(ProcessStatus.unsuccessful);
        },
        onSuccess: () {
          _setStatus(ProcessStatus.successful);
        });
  }

  void _setStatus(ProcessStatus? processStatus) {
    emit(state.copyWith(saveStatus: processStatus ?? ProcessStatus.processing));
  }

  void approveGoalPhotoPath(bool? approve) {
    if (approve == true && state.goalPhotoTempPath.isNotEmptyOrNull) {
      emit(state.copyWith(goalPhotoUploadPath: state.goalPhotoTempPath));
    }
  }

  void setMode(GoalDetailsMode? newValue) {
    if (newValue != null) {
      emit(state.copyWith(goalDetailsMode: newValue));
    }
  }

  void setTitle(String? title) {
    if (title != null) emit(state.copyWith(title: title));
  }

  void setDescription(String? description) {
    if (description != null) emit(state.copyWith(description: description));
  }

  void setPoints(int? points) {
    if (points != null) emit(state.copyWith(points: points));
  }

  void setPhotoPath(String? path) {
    if (path != null) emit(state.copyWith(goalPhotoTempPath: path));
  }

  void setFinishedPhotoTempPath(String? path) {
    if (path != null) emit(state.copyWith(finishedPhotoTempPath: path));
  }

  @override
  Future<void> close() {
    _memberStreamSubscription?.cancel();
    _existingGoalStreamSubscription?.cancel();
    return super.close();
  }
}

enum GoalDetailsMode { viewing, editing, loading }

class GoalDetailsState extends Equatable {
  final FamilyMember? familyMember;
  final FamilyMemberGoal? existingGoal;
  final String? title;
  final String? description;
  final String? goalPhotoUploadPath;
  final String? goalPhotoTempPath;
  final GoalDetailsMode? goalDetailsMode;
  final bool? isAchieved;
  final bool? isApproved;
  final int? points;
  final ProcessStatus saveStatus;
  final bool updateFlag;

  const GoalDetailsState(
      {this.familyMember,
      this.existingGoal,
      this.title,
      this.description,
      this.goalPhotoUploadPath,
      this.goalPhotoTempPath,
      this.goalDetailsMode,
      this.isApproved,
      this.isAchieved,
      this.points,
      this.saveStatus = ProcessStatus.idle,
      this.updateFlag = true});

  GoalDetailsState copyWith({
    FamilyMember? familyMember,
    FamilyMemberGoal? existingGoal,
    String? title,
    String? description,
    String? goalPhotoUploadPath,
    String? goalPhotoTempPath,
    String? finishedPhotoTempPath,
    GoalDetailsMode? goalDetailsMode,
    bool? isAchieved,
    bool? isApproved,
    String? finishedPhotoUploadPath,
    int? points,
    ProcessStatus? saveStatus,
  }) {
    return GoalDetailsState(
        familyMember: familyMember ?? this.familyMember,
        existingGoal: existingGoal ?? this.existingGoal,
        title: title ?? this.title,
        description: description ?? this.description,
        goalPhotoUploadPath: goalPhotoUploadPath ?? this.goalPhotoUploadPath,
        goalPhotoTempPath: goalPhotoTempPath ?? this.goalPhotoTempPath,
        goalDetailsMode: goalDetailsMode ?? this.goalDetailsMode,
        saveStatus: saveStatus ?? this.saveStatus,
        isApproved: isApproved ?? this.isApproved,
        isAchieved: isAchieved ?? this.isAchieved,
        points: points ?? this.points,
        updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [
        familyMember,
        existingGoal,
        title,
        description,
        goalPhotoUploadPath,
        goalDetailsMode,
        saveStatus,
        isApproved,
        isAchieved,
        points,
        updateFlag
      ];
}
