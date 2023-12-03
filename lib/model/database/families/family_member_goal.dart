import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:living_room/extension/dart/map_extension.dart';
import 'package:living_room/model/database/base/firestore_item.dart';

String familyMemberGoalCollectionPath(String familyId, String memberId) =>
    "families/$familyId/members/$memberId/goals";

const String familyMemberGoalDocumentTitleField = "title";
const String familyMemberGoalDocumentDescriptionField = "description";
const String familyMemberGoalDocumentCreationTimeField = "createdAt";
const String familyMemberGoalDocumentIsAchievedField = "isAchieved";
const String familyMemberGoalDocumentIsApprovedField = "isApproved";
const String familyMemberGoalDocumentUserApprovedField = "userApproved";
const String familyMemberGoalDocumentPointsField = "points";
const String familyMemberGoalDocumentPhotoUrlField = "photoUrl";

class FamilyMemberGoal extends FirestoreItem {
  String? familyId;
  String? memberId;
  String? title;
  String? description;
  DateTime? createdAt;
  bool? isAchieved;
  bool? isApproved;
  String? userApproved;
  String? photoUrl;
  int? points;

  FamilyMemberGoal(
      {this.familyId,
      this.memberId,
      this.title,
      this.description,
      this.createdAt,
      this.isAchieved,
      this.isApproved,
      this.userApproved,
      this.photoUrl,
      this.points});

  FamilyMemberGoal.fromSnapshot(
      MapEntry<DocumentReference, Map<String, dynamic>> snapshotEntry)
      : super.doc(snapshotEntry.key) {
    var data = snapshotEntry.value;
    familyId = snapshotEntry.key.parent.parent?.parent.parent?.id;
    memberId = snapshotEntry.key.parent.parent?.id;
    title = data.getString(familyMemberGoalDocumentTitleField);
    description = data.getString(familyMemberGoalDocumentDescriptionField);
    createdAt =
        data.getTimestamp(familyMemberGoalDocumentCreationTimeField)?.toDate();
    isAchieved = data.getBool(familyMemberGoalDocumentIsAchievedField);
    isApproved = data.getBool(familyMemberGoalDocumentIsApprovedField);
    userApproved = data.getString(familyMemberGoalDocumentUserApprovedField);
    points = data.getInt(familyMemberGoalDocumentPointsField);
    photoUrl = data.getString(familyMemberGoalDocumentPhotoUrlField);
  }

  @override
  String get collectionPath =>
      familyMemberGoalCollectionPath(familyId!, memberId!);

  @override
  Map<String, dynamic> get toJson => {
        familyMemberGoalDocumentTitleField: title,
        familyMemberGoalDocumentDescriptionField: description,
        familyMemberGoalDocumentCreationTimeField: createdAt,
        familyMemberGoalDocumentIsAchievedField: isAchieved,
        familyMemberGoalDocumentIsApprovedField: isApproved,
        familyMemberGoalDocumentUserApprovedField: userApproved,
        familyMemberGoalDocumentPointsField: points,
        familyMemberGoalDocumentPhotoUrlField: photoUrl
      };
}
