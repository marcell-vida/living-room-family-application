import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/users/database_user.dart';

class ComplexUser {
  DatabaseUser? dbUser;
  FamilyMember? famMember;


  // final DatabaseService _databaseService;
  //
  // ComplexUser(
  //     {required DatabaseService databaseService,
  //     DatabaseUser? user,
  //     FamilyMember? member})
  //     : _databaseService = databaseService,
  //       dbUser = user,
  //       famMember = member;

  // Future<void> searchUser({FamilyMember? member}) async {
  //   if (member != null) setFamilyMember(member);
  //   if (famMember?.id != null) {
  //     setDatabaseUser(
  //         await _databaseService.getUserById(uid: famMember!.id!));
  //   }
  // }
  //
  // Future<void> searchMember(
  //     {required String? familyId, DatabaseUser? user}) async {
  //   if (user != null) setDatabaseUser(user);
  //   if (familyId != null && dbUser?.id != null) {
  //     setFamilyMember(await _databaseService.getFamilyMember(
  //         familyId: famMember!.id!, userId: dbUser!.id!));
  //   }
  // }
}
