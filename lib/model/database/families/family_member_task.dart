import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:living_room/extension/dart/map_extension.dart';
import 'package:living_room/model/database/base/firestore_item.dart';

String familyMemberTaskCollectionPath(String familyId, String memberId) =>
    "families/$familyId/members/$memberId/tasks";

const String familyMemberTaskDocumentTitleField = "title";
const String familyMemberTaskDocumentDescriptionField = "description";
const String familyMemberTaskDocumentCreationTimeField = "createdAt";
const String familyMemberTaskDocumentDeadlineField = "deadline";
const String familyMemberTaskDocumentIsFinishedField = "isFinished";
const String familyMemberTaskDocumentIsFinishApprovedField = "isFinishApproved";
const String familyMemberTaskDocumentUserApprovedFinishField =
    "userApprovedFinish";
const String familyMemberTaskDocumentUserCreatedField = "userCreated";
const String familyMemberTaskDocumentTaskPhotoUrlField = "taskPhotoUrl";
const String familyMemberTaskDocumentFinishedPhotoUrlField = "finishedPhotoUrl";
const String familyMemberTaskDocumentPointsField = "points";

class FamilyMemberTask extends FirestoreItem {
  String? familyId;
  String? memberId;
  String? title;
  String? description;
  DateTime? createdAt;
  DateTime? deadline;
  bool? isFinished;
  bool? isFinishApproved;
  String? userApprovedFinish;
  String? userCreated;
  String? taskPhotoUrl;
  String? finishedPhotoUrl;
  int? points;

  FamilyMemberTask(
      {this.familyId,
      this.memberId,
      this.title,
      this.description,
      this.createdAt,
      this.deadline,
      this.isFinished,
      this.isFinishApproved,
      this.userApprovedFinish,
      this.userCreated,
      this.taskPhotoUrl,
      this.finishedPhotoUrl,
      this.points});

  FamilyMemberTask.fromSnapshot(
      MapEntry<DocumentReference, Map<String, dynamic>> snapshotEntry)
      : super.doc(snapshotEntry.key) {
    var data = snapshotEntry.value;
    familyId = snapshotEntry.key.parent.parent?.parent.parent?.id;
    memberId = snapshotEntry.key.parent.parent?.id;
    title = data.getString(familyMemberTaskDocumentTitleField);
    description = data.getString(familyMemberTaskDocumentDescriptionField);
    createdAt =
        data.getTimestamp(familyMemberTaskDocumentCreationTimeField)?.toDate();
    deadline =
        data.getTimestamp(familyMemberTaskDocumentDeadlineField)?.toDate();
    isFinished = data.getBool(familyMemberTaskDocumentIsFinishedField);
    isFinishApproved =
        data.getBool(familyMemberTaskDocumentIsFinishApprovedField);
    userApprovedFinish =
        data.getString(familyMemberTaskDocumentUserApprovedFinishField);
    userCreated = data.getString(familyMemberTaskDocumentUserCreatedField);
    taskPhotoUrl = data.getString(familyMemberTaskDocumentTaskPhotoUrlField);
    finishedPhotoUrl =
        data.getString(familyMemberTaskDocumentFinishedPhotoUrlField);
    points = data.getInt(familyMemberTaskDocumentPointsField);

    debugPrint(
        'FamilyMemberTask.fromSnapshot: familyId == $familyId, memberId == $memberId');
  }

  @override
  String get collectionPath =>
      familyMemberTaskCollectionPath(familyId!, memberId!);

  @override
  Map<String, dynamic> get toJson => {
        familyMemberTaskDocumentTitleField: title,
        familyMemberTaskDocumentDescriptionField: description,
        familyMemberTaskDocumentCreationTimeField: createdAt,
        familyMemberTaskDocumentDeadlineField: deadline,
        familyMemberTaskDocumentIsFinishedField: isFinished,
        familyMemberTaskDocumentIsFinishApprovedField: isFinishApproved,
        familyMemberTaskDocumentUserApprovedFinishField: userApprovedFinish,
        familyMemberTaskDocumentUserCreatedField: userCreated,
        familyMemberTaskDocumentTaskPhotoUrlField: taskPhotoUrl,
        familyMemberTaskDocumentFinishedPhotoUrlField: finishedPhotoUrl,
        familyMemberTaskDocumentPointsField: points
      };
}
