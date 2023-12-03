import 'dart:async';

import 'package:collection/collection.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/service/database/database_service.dart';


extension DatabaseUserStreamSubscriptionList
    on List<StreamSubscription<DatabaseUser?>> {
  /// Cancel all subscriptions from the stream subscription list of individual users
  /// and clear the list.
  void clearSubscriptions() {
    for (StreamSubscription<DatabaseUser?> element in this) {
      element.cancel();
    }
    clear();
  }

  /// Cancel all subscriptions from the stream subscription list of individual users
  /// and clear the list.
  ///
  /// Then add some new subscriptions to the stream subscription list of individual users.
  void clearAndAddSubscriptions(
      {List<DatabaseUser>? usersToAdd,
      required DatabaseService databaseService,
      void Function(DatabaseUser?)? onUserUpdates}) {
    clearSubscriptions();

    addSubscriptions(
        databaseService: databaseService,
        usersToAdd: usersToAdd,
        onUserUpdates: onUserUpdates);
  }

  /// Add some new subscriptions to the stream subscription list of individual users.
  void addSubscriptions(
      {List<DatabaseUser>? usersToAdd,
      required DatabaseService databaseService,
      void Function(DatabaseUser?)? onUserUpdates}) {
    if (usersToAdd != null && usersToAdd.isNotEmpty) {
      for (DatabaseUser user in usersToAdd) {
        if (user.id != null) {
          StreamSubscription<DatabaseUser?> userStream =
              databaseService.streamUserById(user.id!).listen(onUserUpdates);

          if (contains(userStream)) {
            userStream.cancel();
          } else {
            add(userStream);
          }
        }
      }
    }
  }

  /// Cancel some of the subscriptions from the stream subscription list of
  /// individual users.
  void cancelSubscription(
      {List<DatabaseUser>? usersToRemove,
      required DatabaseService databaseService,
      void Function(DatabaseUser?)? onUserUpdates}) {
    if (usersToRemove != null && usersToRemove.isNotEmpty) {
      for (DatabaseUser user in usersToRemove) {
        if (user.id != null) {
          StreamSubscription<DatabaseUser?> userStream =
              databaseService.streamUserById(user.id!).listen(onUserUpdates);

          if (contains(userStream)) {
            firstWhereOrNull((element) => element == userStream)?.cancel();
            remove(userStream);
          }
        }
      }
    }
  }
}
