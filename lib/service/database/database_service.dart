import 'dart:core';

import 'package:living_room/model/authentication/auth_user.dart';
import 'package:living_room/model/database/base/firestore_item.dart';
import 'package:living_room/model/database/families/family.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/model/database/users/invitation.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_base.dart';
import 'package:living_room/service/database/firestore/firestore_database.dart';
import 'package:living_room/util/utils.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._();
  static late DatabaseBase _database;

  DatabaseService._();

  factory DatabaseService() {
    _database = DatabaseImp();
    return _instance;
  }

  Future<T> saveItem<T>(
      {required FirestoreItem firestoreItem, String? documentId}) {
    return _database.saveItem<T>(
        firestoreItem: firestoreItem, documentId: documentId);
  }

  //#region DatabaseUser
  void createCurrentUser(AuthenticationService authenticationService) {
    var authUser = authenticationService.currentUser;
    if (authUser != null) {
      saveItem<DatabaseUser>(
          firestoreItem: DatabaseUser.fromAuthUser(authUser),
          documentId: authUser.uid);
    }
  }

  Future<void> initializeCurrentUser(
      {required AuthenticationService authenticationService,
      void Function()? onSuccess,
      void Function()? onError}) async {
    AuthUser? currentUser = authenticationService.currentUser;
    if (currentUser?.uid != null) {
      await _database.setDocumentFields(
          "$userCollectionPath/${currentUser!.uid!}",
          {
            userDocumentDisplayNameField: currentUser.email != null
                ? Utils.userNameFromEmail(currentUser.email!)
                : '',
            userDocumentEmailField: currentUser.email,
            userDocumentPhotoUrlField: null,
            userDocumentIsBannedField: false,
            userDocumentIsArchiveField: false,
            userDocumentCreationDateField: DateTime.now(),
          },
          onSuccess: onSuccess,
          onError: onError);
    } else {
      onError?.call();
    }
  }

  Future<void> changeCurrentUserDisplayName(
      {required AuthenticationService authenticationService,
      required String displayName,
      void Function()? onSuccess,
      void Function()? onError}) async {
    var currentUserId = authenticationService.currentUser?.uid;
    if (currentUserId != null) {
      await _database.setDocumentFields("$userCollectionPath/$currentUserId",
          {userDocumentDisplayNameField: displayName},
          onSuccess: onSuccess, onError: onError);
    }
  }

  Future<void> changeCurrentUserGeneralNotifications(
      {required AuthenticationService authenticationService,
      required bool notifications,
      void Function()? onSuccess,
      void Function()? onError}) async {
    var currentUserId = authenticationService.currentUser?.uid;
    if (currentUserId != null) {
      await _database.setDocumentFields("$userCollectionPath/$currentUserId",
          {userDocumentGeneralNotificationsField: notifications},
          onSuccess: onSuccess, onError: onError);
    }
  }

  Future<void> changeCurrentUserPhotoUrl(
      {required AuthenticationService authenticationService,
      String? photoUrl,
      void Function()? onSuccess,
      void Function()? onError}) async {
    var currentUserId = authenticationService.currentUser?.uid;
    if (currentUserId != null) {
      await _database.setDocumentFields("$userCollectionPath/$currentUserId",
          {userDocumentPhotoUrlField: photoUrl},
          onSuccess: onSuccess, onError: onError);
    }
  }

  Future<void> changeCurrentUserFcmToken(
      {required AuthenticationService authenticationService,
      required String? token,
      void Function()? onSuccess,
      void Function()? onError}) async {
    var currentUserId = authenticationService.currentUser?.uid;
    if (currentUserId != null) {
      await _database.setDocumentFields("$userCollectionPath/$currentUserId",
          {userDocumentFcmTokenField: token},
          onSuccess: onSuccess, onError: onError);
    }
  }

  Future<DatabaseUser?> getUserById({required String uid}) async =>
      _database.getTDocument<DatabaseUser>("$userCollectionPath/$uid");

  Stream<DatabaseUser?> streamUserById(String uid) =>
      _database.streamTDocument<DatabaseUser>("$userCollectionPath/$uid");

  Future<List<DatabaseUser>?> getUsers() async =>
      _database.getTCollection<DatabaseUser>(userCollectionPath);

  Stream<List<DatabaseUser>?> streamUsers() =>
      _database.streamTCollection(userCollectionPath);

//#endregion

  //#region UserInvitations

  Future<void> updateUserInvitation(
      {required String userId,
      required String familyId,
      bool? accepted,
      void Function()? onSuccess,
      void Function()? onError}) async {
    Map<String, dynamic> saveDetails = {};
    if (accepted != null) {
      saveDetails[userInvitationDocumentAcceptedField] = accepted;
    }

    await _database.setDocumentFields(
        "${userInvitationCollectionPath(userId)}/$familyId", saveDetails,
        onSuccess: onSuccess, onError: onError);
  }

  Future<void> deleteInvitation(
      {required String userId,
      required String familyId,
      void Function()? onSuccess,
      void Function()? onError}) async {
    await _database.deleteDocument(
        "${userInvitationCollectionPath(userId)}/$familyId",
        onSuccess: onSuccess,
        onError: onError);
  }

  Future<Invitation?> createUserInvitation(
      {required String targetUserId,
      required String familyId,
      String? message,
      bool isAccepted = false,
      required AuthenticationService authenticationService}) async {
    var authUser = authenticationService.currentUser;
    if (authUser != null) {
      return await saveItem<Invitation>(
          firestoreItem: Invitation(
            userId: targetUserId,
            sender: authUser.uid,
            familyId: familyId,
            message: message,
            sentAt: DateTime.now(),
            accepted: isAccepted,
          ),
          documentId: familyId);
    }
    return null;
  }

  Stream<Invitation?> streamUserInvitation(
          {required String userId, required String invitationId}) =>
      _database.streamTDocument<Invitation>(
          "${userInvitationCollectionPath(userId)}/$invitationId");

  Future<Invitation?>? getUserInvitation(
          {required String userId, required String invitationId}) async =>
      await _database.getTDocument<Invitation>(
          "${userInvitationCollectionPath(userId)}/$invitationId");

  Stream<List<Invitation>?> streamUserInvitations({required String userId}) =>
      _database
          .streamTCollection<Invitation>(userInvitationCollectionPath(userId));

  Future<List<Invitation>?> getUserInvitations(
          {required String userId}) async =>
      await _database
          .getTCollection<Invitation>(userInvitationCollectionPath(userId));

//#endregion

  //#region Family

  Future<void> updateFamily(
      {required String familyUid,
      String? name,
      String? description,
      String? photoUrl,
      void Function()? onSuccess,
      void Function()? onError}) async {
    Map<String, String> saveDetails = {};
    if (name != null) saveDetails[familyDocumentNameField] = name;
    if (description != null) {
      saveDetails[familyDocumentDescriptionField] = description;
    }
    if (photoUrl != null) saveDetails[familyDocumentPhotoUrlField] = photoUrl;

    await _database.setDocumentFields(
        "$familiesCollectionPath/$familyUid", saveDetails,
        onSuccess: onSuccess, onError: onError);
  }

  Future<CreateFamilyResult?> createFamily(
      {String? name,
      String? description,
      String? photoUrl,
      required AuthenticationService authenticationService}) async {
    var authUser = authenticationService.currentUser;
    if (authUser != null) {
      Family? savedFamily = await saveItem<Family>(
          firestoreItem: Family(
              name: name,
              description: description,
              photoUrl: photoUrl,
              createdAt: DateTime.now()));

      FamilyMember? savedMember;
      Invitation? savedInvitation;

      if (savedFamily.id != null) {
        AuthUser? authUser = authenticationService.currentUser;
        if (authUser?.uid != null) {
          savedMember = await createFamilyMember(
              userId: authUser!.uid!,
              familyId: savedFamily.id!,
              isCreator: true,
              isParent: true);
          savedInvitation = await createUserInvitation(
              targetUserId: authUser.uid!,
              familyId: savedFamily.id!,
              isAccepted: true,
              authenticationService: authenticationService);
        }
      }

      return CreateFamilyResult(
          family: savedFamily,
          member: savedMember,
          invitation: savedInvitation);
    }
    return null;
  }

  Stream<Family?> streamFamily(String id) {
    return _database.streamTDocument<Family>("$familiesCollectionPath/$id");
  }

  Stream<List<Family>?> streamFamilies() {
    return _database.streamTCollection<Family>(familiesCollectionPath);
  }

  Future<List<Family>?> getFamilies() async =>
      _database.getTCollection<Family>(familiesCollectionPath);

  Future<Family?>? getFamily(String id) async {
    return await _database.getTDocument<Family>("$familiesCollectionPath/$id");
  }

  //#endregion

  //#region FamilyMembers

  Future<FamilyMember> createFamilyMember(
      {required String userId,
      bool isParent = false,
      bool isCreator = false,
      int pointsCollected = 0,
      required String familyId}) async {
    return await saveItem<FamilyMember>(
        firestoreItem: FamilyMember(
            isParent: isParent,
            isCreator: isCreator,
            pointsCollected: pointsCollected,
            familyId: familyId),
        documentId: userId);
  }

  Future<void> updateFamilyMember(
      {required String familyId,
      required String userId,
      bool? isParent,
      bool? isCreator,
      int? pointsCollected,
      void Function()? onSuccess,
      void Function()? onError}) async {
    Map<String, dynamic> saveDetails = {};
    if (isParent != null) {
      saveDetails[familyMemberDocumentIsParentField] = isParent;
    }
    if (isCreator != null) {
      saveDetails[familyMemberDocumentIsCreatorField] = isCreator;
    }
    if (pointsCollected != null) {
      saveDetails[familyMemberDocumentPointsCollectedField] = pointsCollected;
    }

    await _database.setDocumentFields(
        "${familyMemberCollectionPath(familyId)}/$userId", saveDetails,
        onSuccess: onSuccess, onError: onError);
  }

  Stream<FamilyMember?> streamFamilyMember(
          {required String familyId, required String userId}) =>
      _database.streamTDocument<FamilyMember>(
          "${familyMemberCollectionPath(familyId)}/$userId");

  Future<FamilyMember?>? getFamilyMember(
          {required String familyId, required String userId}) async =>
      await _database.getTDocument<FamilyMember>(
          "${familyMemberCollectionPath(familyId)}/$userId");

  Stream<List<FamilyMember>?> streamFamilyMembers({required String familyId}) =>
      _database.streamTCollection<FamilyMember>(
          familyMemberCollectionPath(familyId));

  Future<List<FamilyMember>?> getFamilyMembers(
          {required String familyId}) async =>
      await _database
          .getTCollection<FamilyMember>(familyMemberCollectionPath(familyId));

//#endregion

//#region FamilyMemberGoal
  Future<FamilyMemberGoal> createFamilyMemberGoal(
      {required String familyId,
      required String userId,
      String? title,
      String? description,
      String? photoUrl,
      int? points,
      void Function()? onSuccess,
      void Function()? onError}) async {
    FamilyMemberGoal goal = FamilyMemberGoal(
        title: title,
        familyId: familyId,
        memberId: userId,
        description: description,
        photoUrl: photoUrl,
        points: points,
        createdAt: DateTime.now());

    return await saveItem<FamilyMemberGoal>(firestoreItem: goal);
  }

  Future<void> updateFamilyMemberGoal(
      {required String familyId,
      required String userId,
      required String goalId,
      String? title,
      String? description,
      String? photoUrl,
      int? points,
      bool? isAchieved,
      bool? isApproved,
      void Function()? onSuccess,
      void Function()? onError}) async {
    Map<String, dynamic> saveDetails = {};
    if (title != null) {
      saveDetails[familyMemberTaskDocumentTitleField] = title;
    }
    if (description != null) {
      saveDetails[familyMemberTaskDocumentDescriptionField] = description;
    }
    if (photoUrl != null) {
      saveDetails[familyMemberGoalDocumentPhotoUrlField] = photoUrl;
    }
    if (isAchieved != null) {
      saveDetails[familyMemberGoalDocumentIsAchievedField] = isAchieved;
    }
    if (isApproved != null) {
      saveDetails[familyMemberGoalDocumentIsApprovedField] = isApproved;
    }
    if (points != null) {
      saveDetails[familyMemberTaskDocumentPointsField] = points;
    }

    await _database.setDocumentFields(
        "${familyMemberGoalCollectionPath(familyId, userId)}/$goalId",
        saveDetails,
        onSuccess: onSuccess,
        onError: onError);
  }

  Stream<FamilyMemberGoal?> streamFamilyMemberGoal(
          {required String familyId,
          required String userId,
          required String goalId}) =>
      _database.streamTDocument<FamilyMemberGoal>(
          "${familyMemberGoalCollectionPath(familyId, userId)}/$goalId");

  Future<FamilyMemberGoal?>? getFamilyMemberGoal(
          {required String familyId,
          required String userId,
          required String goalId}) =>
      _database.getTDocument<FamilyMemberGoal>(
          "${familyMemberGoalCollectionPath(familyId, userId)}/$goalId");

  Stream<List<FamilyMemberGoal>?> streamFamilyMemberGoals(
          {required String familyId, required String userId}) =>
      _database.streamTCollection<FamilyMemberGoal>(
          familyMemberGoalCollectionPath(familyId, userId));

  Future<List<FamilyMemberGoal>?> getFamilyMemberGoals(
          {required String familyId, required String userId}) =>
      _database.getTCollection<FamilyMemberGoal>(
          familyMemberGoalCollectionPath(familyId, userId));

//#endregion

//#region FamilyMemberTask
  Future<FamilyMemberTask?> createFamilyMemberTask(
      {required String familyUid,
      required String userUid,
      required AuthenticationService authenticationService,
      String? title,
      String? description,
      String? taskPhotoUrl,
      DateTime? deadLine,
      int? points,
      void Function()? onSuccess,
      void Function()? onError}) async {
    String? creatorId = authenticationService.currentUser?.uid;

    if (creatorId == null) {
      onError?.call();
      return null;
    }

    FamilyMemberTask task = FamilyMemberTask(
        title: title,
        familyId: familyUid,
        memberId: userUid,
        description: description,
        taskPhotoUrl: taskPhotoUrl,
        points: points,
        deadline: deadLine,
        userCreated: creatorId,
        createdAt: DateTime.now());

    return await saveItem<FamilyMemberTask>(firestoreItem: task);
  }

  Future<void> updateFamilyMemberTask(
      {required String familyUid,
      required String userUid,
      required String taskUid,
      String? title,
      String? description,
      String? photoUrl,
      DateTime? deadLine,
      int? points,
      void Function()? onSuccess,
      void Function()? onError}) async {
    Map<String, dynamic> saveDetails = {};
    if (title != null) {
      saveDetails[familyMemberTaskDocumentTitleField] = title;
    }
    if (description != null) {
      saveDetails[familyMemberTaskDocumentDescriptionField] = description;
    }
    if (photoUrl != null) {
      saveDetails[familyMemberTaskDocumentTaskPhotoUrlField] = photoUrl;
    }
    if (deadLine != null) {
      saveDetails[familyMemberTaskDocumentDeadlineField] = deadLine;
    }
    if (points != null) {
      saveDetails[familyMemberTaskDocumentPointsField] = points;
    }

    await _database.setDocumentFields(
        "${familyMemberTaskCollectionPath(familyUid, userUid)}/$taskUid",
        saveDetails,
        onSuccess: onSuccess,
        onError: onError);
  }

  Future<void> changeFinishStatusOfFamilyMemberTask(
      {required String familyUid,
      required String userUid,
      required String taskUid,
      required bool finished,
      void Function()? onSuccess,
      void Function()? onError}) async {
    Map<String, dynamic> saveDetails = {
      familyMemberTaskDocumentIsFinishedField: finished
    };
    if (finished != true) {
      saveDetails[familyMemberTaskDocumentIsFinishApprovedField] = false;
    }

    await _database.setDocumentFields(
        "${familyMemberTaskCollectionPath(familyUid, userUid)}/$taskUid",
        saveDetails,
        onSuccess: onSuccess,
        onError: onError);
  }

  Future<void> changeApprovedStatusOfFamilyMemberTask(
      {required String familyUid,
      required String userUid,
      required String taskUid,
      required bool approved,
      AuthenticationService? authenticationService,
      void Function()? onSuccess,
      void Function()? onError}) async {
    String? approverId;
    if (authenticationService != null) {
      approverId = authenticationService.currentUser?.uid;
    }

    await _database.setDocumentFields(
        "${familyMemberTaskCollectionPath(familyUid, userUid)}/$taskUid",
        {
          familyMemberTaskDocumentIsFinishApprovedField: approved,
          familyMemberTaskDocumentUserApprovedFinishField: approverId
        },
        onSuccess: onSuccess,
        onError: onError);
  }

  Stream<FamilyMemberTask?> streamFamilyMemberTask(
          {required String familyId,
          required String userId,
          required String taskId}) =>
      _database.streamTDocument<FamilyMemberTask>(
          "${familyMemberTaskCollectionPath(familyId, userId)}/$taskId");

  Future<FamilyMemberTask?>? getFamilyMemberTask(
          {required String familyId,
          required String userId,
          required String taskId}) =>
      _database.getTDocument<FamilyMemberTask>(
          "${familyMemberTaskCollectionPath(familyId, userId)}/$taskId");

  Stream<List<FamilyMemberTask>?> streamFamilyMemberTasks(
          {required String familyId, required String userId}) =>
      _database.streamTCollection<FamilyMemberTask>(
          familyMemberTaskCollectionPath(familyId, userId));

  Future<List<FamilyMemberTask>?> getFamilyMemberTasks(
          {required String familyId, required String userId}) =>
      _database.getTCollection<FamilyMemberTask>(
          familyMemberTaskCollectionPath(familyId, userId));
//#endregion
}
