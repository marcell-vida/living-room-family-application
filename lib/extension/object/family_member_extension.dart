import 'package:collection/collection.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/service/database/database_service.dart';

extension FamilyMemberExtension on FamilyMember{
  /// Returns a [DatabaseUser] if its id equals to the id of this [FamilyMember].
  ///
  /// This method gets the [List] of all [DatabaseUser] itself.
  Future<DatabaseUser?> get getDbUser async {
    List<DatabaseUser>? users = await DatabaseService().getUsers();

    if(users == null) return null;

    return users.firstWhereOrNull((element)=> element.id == id);
  }

  /// Returns a [DatabaseUser] if its id equals to the id of this [FamilyMember].
  ///
  /// This method requires the [List] of all [DatabaseUser].
  DatabaseUser? getUserFromList(List<DatabaseUser> users)  {
    return users.firstWhereOrNull((element)=> element.id == id);
  }
}