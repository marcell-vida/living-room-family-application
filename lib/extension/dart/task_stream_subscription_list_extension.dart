import 'dart:async';

import 'package:collection/collection.dart';
import 'package:living_room/extension/dart/string_extension.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/service/database/database_service.dart';

extension TaskStreamSubscriptionList
    on List<StreamSubscription<FamilyMemberTask?>> {
  /// Cancel all subscriptions from the stream subscription list of individual users
  /// and clear the list.
  void clearSubscriptions() {
    for (StreamSubscription<FamilyMemberTask?> element in this) {
      element.cancel();
    }
    clear();
  }

  /// Cancel all subscriptions from the stream subscription list of individual users
  /// and clear the list.
  ///
  /// Then add some new subscriptions to the stream subscription list of individual users.
  void clearAndAddSubscriptions(
      {List<FamilyMemberTask>? tasksToAdd,
      required DatabaseService databaseService,
      void Function(FamilyMemberTask?)? onTaskUpdates}) {
    clearSubscriptions();

    addSubscriptions(
        databaseService: databaseService,
        tasksToAdd: tasksToAdd,
        onTaskUpdates: onTaskUpdates);
  }

  /// Add some new subscriptions to the stream subscription list of individual users.
  void addSubscriptions(
      {List<FamilyMemberTask>? tasksToAdd,
      String? familyId,
      String? userId,
      required DatabaseService databaseService,
      void Function(FamilyMemberTask?)? onTaskUpdates}) {
    if (tasksToAdd != null && tasksToAdd.isNotEmpty) {
      for (FamilyMemberTask task in tasksToAdd) {
        if (task.id.isNotEmptyOrNull &&
            familyId.isNotEmptyOrNull &&
            userId.isNotEmptyOrNull) {
          StreamSubscription<FamilyMemberTask?> taskStream = databaseService
              .streamFamilyMemberTask(
                  familyId: familyId!, userId: userId!, taskId: task.id!)
              .listen(onTaskUpdates);
          if (contains(taskStream)) {
            taskStream.cancel();
          } else {
            add(taskStream);
          }
        }
      }
    }
  }

  /// Cancel some of the subscriptions from the stream subscription list of
  /// individual users.
  void cancelSubscription(
      {List<FamilyMemberTask>? tasksToRemove,
      String? familyId,
      String? userId,
      required DatabaseService databaseService,
      void Function(FamilyMemberTask?)? onTaskUpdates}) {
    if (tasksToRemove != null && tasksToRemove.isNotEmpty) {
      for (FamilyMemberTask task in tasksToRemove) {
        if (task.id.isNotEmptyOrNull &&
            familyId.isNotEmptyOrNull &&
            userId.isNotEmptyOrNull) {
          StreamSubscription<FamilyMemberTask?> taskStream = databaseService
              .streamFamilyMemberTask(
                  familyId: familyId!, userId: task.id!, taskId: task.id!)
              .listen(onTaskUpdates);

          if (contains(taskStream)) {
            firstWhereOrNull((element) => element == taskStream)?.cancel();
            remove(taskStream);
          }
        }
      }
    }
  }
}
