import 'dart:async';

import 'package:collection/collection.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/service/database/database_service.dart';

extension GoalStreamSubscriptionList
    on List<StreamSubscription<FamilyMemberGoal?>> {
  /// Cancel all subscriptions from the stream subscription list of individual users
  /// and clear the list.
  void clearSubscriptions() {
    for (StreamSubscription<FamilyMemberGoal?> element in this) {
      element.cancel();
    }
    clear();
  }

  /// Cancel all subscriptions from the stream subscription list of individual users
  /// and clear the list.
  ///
  /// Then add some new subscriptions to the stream subscription list of individual users.
  void clearAndAddSubscriptions(
      {List<FamilyMemberGoal>? goalsToAdd,
      required DatabaseService databaseService,
      void Function(FamilyMemberGoal?)? onGoalUpdates}) {
    clearSubscriptions();

    addSubscriptions(
        databaseService: databaseService,
        goalsToAdd: goalsToAdd,
        onGoalUpdates: onGoalUpdates);
  }

  /// Add some new subscriptions to the stream subscription list of individual users.
  void addSubscriptions(
      {List<FamilyMemberGoal>? goalsToAdd,
      String? familyId,
      String? userId,
      required DatabaseService databaseService,
      void Function(FamilyMemberGoal?)? onGoalUpdates}) {
    if (goalsToAdd != null && goalsToAdd.isNotEmpty) {
      for (FamilyMemberGoal goal in goalsToAdd) {
        if (goal.id.isNotEmptyOrNull &&
            familyId.isNotEmptyOrNull &&
            userId.isNotEmptyOrNull) {
          StreamSubscription<FamilyMemberGoal?> goalStream = databaseService
              .streamFamilyMemberGoal(
                  familyId: familyId!, userId: userId!, goalId: goal.id!)
              .listen(onGoalUpdates);

          if (contains(goalStream)) {
            goalStream.cancel();
          } else {
            add(goalStream);
          }
        }
      }
    }
  }

  /// Cancel some of the subscriptions from the stream subscription list of
  /// individual users.
  void cancelSubscription(
      {List<FamilyMemberGoal>? goalsToRemove,
      String? familyId,
      String? userId,
      required DatabaseService databaseService,
      void Function(FamilyMemberGoal?)? onGoalUpdates}) {
    if (goalsToRemove != null && goalsToRemove.isNotEmpty) {
      for (FamilyMemberGoal goal in goalsToRemove) {
        if (goal.id.isNotEmptyOrNull &&
            familyId.isNotEmptyOrNull &&
            userId.isNotEmptyOrNull) {
          StreamSubscription<FamilyMemberGoal?> goalStream = databaseService
              .streamFamilyMemberGoal(
                  familyId: familyId!, userId: goal.id!, goalId: goal.id!)
              .listen(onGoalUpdates);

          if (contains(goalStream)) {
            firstWhereOrNull((element) => element == goalStream)?.cancel();
            remove(goalStream);
          }
        }
      }
    }
  }
}
