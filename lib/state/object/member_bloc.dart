import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/goal_stream_subscription_list_extension.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/extension/dart/task_stream_subscription_list_extension.dart';
import 'package:living_room/main.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/state/object/goal_bloc.dart';
import 'package:living_room/state/object/task_bloc.dart';
import 'package:meta/meta_meta.dart';

class MemberCubit extends Cubit<MemberState> {
  final String userId;
  final String familyId;
  final DatabaseService _databaseService;
  // final List<FamilyTaskCubit> taskCubits;
  // final List<FamilyGoalCubit> goalCubits;
  final List<StreamSubscription<FamilyMemberTask>>
      _taskDocumentStreamSubscriptions;
  final List<StreamSubscription<FamilyMemberGoal>>
      _goalDocumentStreamSubscriptions;
  StreamSubscription<DatabaseUser?>? _userStreamSubscription;
  StreamSubscription<FamilyMember?>? _memberStreamSubscription;
  StreamSubscription<List<FamilyMemberTask>?>? _tasksStreamSubscription;
  StreamSubscription<List<FamilyMemberGoal>?>? _goalsStreamSubscription;

  MemberCubit(
      {required DatabaseService databaseService,
      required this.familyId,
      required this.userId})
      : _databaseService = databaseService,
        _taskDocumentStreamSubscriptions = [],
        _goalDocumentStreamSubscriptions = [],
  //       taskCubits = <FamilyTaskCubit>[],
  // goalCubits = <FamilyGoalCubit>[],
        super(const MemberState()) {
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


  void _updateTasks(List<FamilyMemberTask>? newList){
    emit(state.copyWith(tasks: newList ?? <FamilyMemberTask>[]));
  }

  void _updateGoals(List<FamilyMemberGoal>? newList){
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
    _taskDocumentStreamSubscriptions.clearSubscriptions();
    _goalDocumentStreamSubscriptions.clearSubscriptions();
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

  const MemberState(
      {this.user, this.member, this.tasks, this.goals, this.updateFlag = true});

  MemberState copyWith(
      {DatabaseUser? user,
      FamilyMember? member,
      List<FamilyMemberTask>? tasks,
      List<FamilyMemberGoal>? goals}) {
    log.d('update with tasks == $tasks');
    return MemberState(
        user: user ?? this.user,
        member: member ?? this.member,
        tasks: tasks ?? this.tasks,
        goals: goals ?? this.goals,
        updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [user, member, tasks, goals];
}

//   Future<void> _updateTasks(List<FamilyMemberTask>? newTasks) async {
//     if (newTasks == null || newTasks.isEmpty) {
//       /// clear tasks
//       if (taskCubits.isNotEmpty) {
//         // previously there were tasks, now all of them has to be deleted
//         for (FamilyTaskCubit cubit in taskCubits) {
//           cubit.close();
//         }
//         taskCubits.clear();
//       }
//       emit(state.copyWith());
//     } else {
//       /// delete cubits that belong to deleted tasks
//       taskCubits.removeWhere((element) {
//         if (element.state.task == null ||
//             !newTasks.contains(element.state.task)) {
//           /// either the new list of tasks does not contain this element
//           /// or the task itself became deleted
//           element.close();
//           /// remove this
//           return true;
//         }
//         /// do not remove this
//         return false;
//       });
//
//       /// update or create tasks
//       List<FamilyTaskCubit> addList = [];
//
//       for (FamilyMemberTask element in newTasks) {
//         bool isUpdate = false;
//         for (FamilyTaskCubit taskCubit in taskCubits) {
//           if (taskCubit.state.task != null &&
//               taskCubit.state.task!.idNotNullOrEmpty) {
//             /// [TaskCubit] already created for this [FamilyMemberTask], this is an update
//             isUpdate = true;
//           }
//         }
//         if (!isUpdate && element.id.isNotEmptyOrNull) {
//           /// cubit was not created previously for this task, create one
//           /// and add later to taskCubits
//           addList.add(FamilyTaskCubit(
//               databaseService: _databaseService,
//               familyId: familyId,
//               memberId: userId,
//               taskId: element.id!));
//         }
//       }
//
//       if (addList.isNotEmpty) taskCubits.addAll(addList);
//     }
//     emit(state.copyWith());
//   }
//
//   Future<void> _updateGoals(List<FamilyMemberGoal>? newGoals) async {
//     if (newGoals == null || newGoals.isEmpty) {
//       /// clear goals
//       if (goalCubits.isNotEmpty) {
//         /// previously there were goals, now all of them has to be deleted
//         for (FamilyGoalCubit cubit in goalCubits) {
//           cubit.close();
//         }
//         goalCubits.clear();
//       }
//       emit(state.copyWith());
//     } else {
//       /// delete cubits that belong to deleted goals
//       goalCubits.removeWhere((element) {
//         if (element.state.goal == null ||
//             !newGoals.contains(element.state.goal)) {
//           /// either the new list of goals does not contain this element
//           /// or the goal itself became deleted
//           element.close();
//           /// remove this
//           return true;
//         }
//         /// do not remove this
//         return false;
//       });
//
//       /// update or create
//       List<FamilyGoalCubit> addList = [];
//
//       for (FamilyMemberGoal element in newGoals) {
//         bool isUpdate = false;
//         for (FamilyGoalCubit goalCubit in goalCubits) {
//           if (goalCubit.state.goal != null &&
//               goalCubit.state.goal!.idNotNullOrEmpty) {
//             /// [GoalCubit] already created for this [FamilyMemberGoal], this is an update
//             isUpdate = true;
//           }
//         }
//         if (!isUpdate && element.id.isNotEmptyOrNull) {
//           /// cubit was not created previously for this goal, create one
//           /// and add later to goalsCubits
//           addList.add(FamilyGoalCubit(
//               databaseService: _databaseService,
//               familyId: familyId,
//               memberId: userId,
//               goalId: element.id!));
//         }
//       }
//
//       if (addList.isNotEmpty) goalCubits.addAll(addList);
//     }
//     emit(state.copyWith());
//   }