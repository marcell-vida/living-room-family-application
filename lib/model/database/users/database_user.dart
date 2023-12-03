import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:living_room/extension/dart/map_extension.dart';
import 'package:living_room/model/authentication/auth_user.dart';
import 'package:living_room/model/database/base/firestore_item.dart';

const String userCollectionPath = "users";

const String userDocumentCreationDateField = "createdAt";
const String userDocumentDisplayNameField = "displayName";
const String userDocumentPhotoUrlField = "photoUrl";
const String userDocumentEmailField = "email";
const String userDocumentIsBannedField = "isBanned";
const String userDocumentIsArchiveField = "isArchive";
const String userDocumentFcmTokenField = "fcmToken";
const String userDocumentGeneralNotificationsField = "generalNotifications";

class DatabaseUser extends FirestoreItem {
  DateTime? createdAt;
  String? displayName;
  String? photoUrl;
  String? email;
  bool? isBanned;
  bool? isArchived;
  String? fcmToken;
  bool? generalNotification;

  DatabaseUser.fromAuthUser(AuthUser authUser) {
    email = authUser.email;
    displayName = authUser.displayName;
    photoUrl = authUser.photoURL;
    createdAt = authUser.creationTime;
  }

  DatabaseUser.fromSnapshot(
      MapEntry<DocumentReference, Map<String, dynamic>> snapshotEntry)
      : super.doc(snapshotEntry.key) {
    var data = snapshotEntry.value;
    email = data.getString(userDocumentEmailField);
    displayName = data.getString(userDocumentDisplayNameField);
    photoUrl =
        data.getString(userDocumentPhotoUrlField);
    isBanned = data.getBool(userDocumentIsBannedField);
    isArchived = data.getBool(userDocumentIsArchiveField);
    createdAt = data.getTimestamp(userDocumentCreationDateField)?.toDate();
    fcmToken = data.getString(userDocumentFcmTokenField);
    generalNotification = data.getBool(userDocumentGeneralNotificationsField);
  }

  @override
  String get collectionPath => userCollectionPath;

  @override
  Map<String, dynamic> get toJson => {
    userDocumentEmailField: email,
    userDocumentDisplayNameField: displayName,
    userDocumentPhotoUrlField: photoUrl,
    userDocumentIsBannedField: isBanned,
    userDocumentIsArchiveField: isArchived,
    userDocumentCreationDateField: createdAt,
    userDocumentFcmTokenField: fcmToken,
    userDocumentGeneralNotificationsField: generalNotification,
  };
}
