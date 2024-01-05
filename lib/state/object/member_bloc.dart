import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/main.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/service/database/database_service.dart';

class MemberCubit extends Cubit<MemberState> {
  final String userId;
  final String familyId;
  final DatabaseService _databaseService;
  StreamSubscription<DatabaseUser?>? _userStreamSubscription;
  StreamSubscription<FamilyMember?>? _memberStreamSubscription;
  StreamSubscription<List<FamilyMemberTask>?>? _tasksStreamSubscription;
  StreamSubscription<List<FamilyMemberGoal>?>? _goalsStreamSubscription;

  MemberCubit(
      {required DatabaseService databaseService,
      required this.familyId,
      required this.userId})
      : _databaseService = databaseService,
        super(const MemberState()) {
    log.d('MemberCubit created with userId == $userId, familyId == $familyId');
    _init();
  }

  void _init() {
    if (userId.isNotEmpty && familyId.isNotEmpty) {
      _userStreamSubscription = _userStream;
      _memberStreamSubscription = _memberStream;
      _tasksStreamSubscription = _tasksStream;
      _goalsStreamSubscription = _goalsStream;
    }
  }

  /// [DatabaseUser] updates
  StreamSubscription<DatabaseUser?> get _userStream =>
      _databaseService.streamUserById(userId).listen(_updateUser);

  /// [FamilyMember] updates
  StreamSubscription<FamilyMember?> get _memberStream => _databaseService
      .streamFamilyMember(familyId: familyId, userId: userId)
      .listen(_updateMember);

  /// list of [FamilyMemberTask] updates
  StreamSubscription<List<FamilyMemberTask>?> get _tasksStream =>
      _databaseService
          .streamFamilyMemberTasks(familyId: familyId, userId: userId)
          .listen(_updateTasks);

  /// list of [FamilyMemberGoal] updates
  StreamSubscription<List<FamilyMemberGoal>?> get _goalsStream =>
      _databaseService
          .streamFamilyMemberGoals(familyId: familyId, userId: userId)
          .listen(_updateGoals);

  void _updateTasks(List<FamilyMemberTask>? newList) {
    emit(state.copyWith(tasks: newList ?? <FamilyMemberTask>[]));
  }

  void _updateGoals(List<FamilyMemberGoal>? newList) {
    emit(state.copyWith(goals: newList ?? <FamilyMemberGoal>[]));
  }

  void _updateMember(FamilyMember? newMember) async {
    emit(state.copyWith(member: newMember));
  }

  void _updateUser(DatabaseUser? newUser) {
    emit(state.copyWith(user: newUser));
  }

  @override
  Future<void> close() {
    _tasksStreamSubscription?.cancel();
    _goalsStreamSubscription?.cancel();
    _userStreamSubscription?.cancel();
    _memberStreamSubscription?.cancel();
    return super.close();
  }
}

class MemberState extends Equatable {
  final DatabaseUser? user;
  final FamilyMember? member;
  final List<FamilyMemberTask>? tasks;
  final List<FamilyMemberGoal>? goals;
  final bool updateFlag;
  final int updateNo;

  const MemberState(
      {this.user,
      this.member,
      this.tasks,
      this.goals,
      this.updateFlag = true,
      this.updateNo = 0});

  MemberState copyWith(
      {DatabaseUser? user,
      FamilyMember? member,
      List<FamilyMemberTask>? tasks,
      List<FamilyMemberGoal>? goals}) {
    return MemberState(
        user: user ?? this.user,
        member: member ?? this.member,
        tasks: tasks ?? this.tasks,
        goals: goals ?? this.goals,
        updateFlag: !updateFlag,
        updateNo: updateNo + 1);
  }

  @override
  List<Object?> get props => [user, member, tasks, goals, updateFlag, updateNo];
}
