import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/service/database/database_service.dart';

class FamilyGoalCubit extends Cubit<FamilyGoalState> {
  final String goalId;
  final String memberId;
  final String familyId;
  final DatabaseService _databaseService;
  StreamSubscription<FamilyMemberGoal?>? _goalStreamSubscription;

  FamilyGoalCubit(
      {required DatabaseService databaseService,
      required this.goalId,
      required this.familyId,
      required this.memberId})
      : _databaseService = databaseService,
        super(const FamilyGoalState()) {
    _init();
  }

  void _init() {
    if (memberId.isNotEmpty && familyId.isNotEmpty && goalId.isNotEmpty) {
      _goalStreamSubscription = _goalStream;
    }
  }

  /// [FamilyMemberGoal] updates
  StreamSubscription<FamilyMemberGoal?> get _goalStream => _databaseService
      .streamFamilyMemberGoal(
          familyId: familyId, userId: memberId, goalId: goalId)
      .listen(
          (FamilyMemberGoal? newGoal) => emit(state.copyWith(goal: newGoal)));

  @override
  Future<void> close() {
    _goalStreamSubscription?.cancel();
    return super.close();
  }
}

class FamilyGoalState extends Equatable {
  final FamilyMemberGoal? goal;
  final bool updateFlag;

  const FamilyGoalState({this.goal, this.updateFlag = true});

  FamilyGoalState copyWith({FamilyMemberGoal? goal}) {
    return FamilyGoalState(goal: goal ?? this.goal, updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [goal, updateFlag];
}
