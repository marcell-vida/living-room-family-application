import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/service/database/database_service.dart';

class FamilyTaskCubit extends Cubit<FamilyTaskState> {
  final String taskId;
  final String memberId;
  final String familyId;
  final DatabaseService _databaseService;
  StreamSubscription<FamilyMemberTask?>? _taskStreamSubscription;

  FamilyTaskCubit(
      {required DatabaseService databaseService,
      required this.taskId,
      required this.familyId,
      required this.memberId})
      : _databaseService = databaseService,
        super(const FamilyTaskState()) {
    _init();
  }

  void _init() {
    if (memberId.isNotEmpty && familyId.isNotEmpty && taskId.isNotEmpty) {
      _taskStreamSubscription = _taskStream;
    }
  }

  /// [FamilyMemberTask] updates
  StreamSubscription<FamilyMemberTask?> get _taskStream => _databaseService
      .streamFamilyMemberTask(
          familyId: familyId, userId: memberId, taskId: taskId)
      .listen(_update);

  void _update(FamilyMemberTask? newTask) {
    emit(state.copyWith(task: newTask));
  }

  @override
  Future<void> close() {
    _taskStreamSubscription?.cancel();
    return super.close();
  }
}

class FamilyTaskState extends Equatable {
  final FamilyMemberTask? task;
  final bool updateFlag;

  const FamilyTaskState({this.task, this.updateFlag = true});

  FamilyTaskState copyWith({FamilyMemberTask? task}) {
    debugPrint('TaskState: copying with task?.title == ${task?.title}, '
        'task?.photoUrl == ${task?.taskPhotoUrl}, '
        'task?.points == ${task?.points}');
    return FamilyTaskState(task: task ?? this.task, updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [task, updateFlag];
}
