import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:living_room/extension/dart/map_extension.dart';
import 'package:living_room/model/database/base/firestore_item.dart';

String familyMemberCollectionPath(String familyId) =>
    "families/$familyId/members";

const String familyMemberDocumentIsParentField = "isParent";
const String familyMemberDocumentIsCreatorField = "isCreator";
const String familyMemberDocumentPointsCollectedField = "pointsCollected";

class FamilyMember extends FirestoreItem {
  String? familyId;
  bool? isParent;
  bool? isCreator;
  int? pointsCollected;

  FamilyMember(
      {this.familyId, this.isParent, this.isCreator, this.pointsCollected});

  FamilyMember.fromSnapshot(
      MapEntry<DocumentReference, Map<String, dynamic>> snapshotEntry)
      : super.doc(snapshotEntry.key) {
    var data = snapshotEntry.value;
    familyId = snapshotEntry.key.parent.parent?.id;
    isParent = data.getBool(familyMemberDocumentIsParentField);
    isCreator = data.getBool(familyMemberDocumentIsCreatorField);
    pointsCollected = data.getInt(familyMemberDocumentPointsCollectedField);
  }

  @override
  String get collectionPath => familyMemberCollectionPath(familyId!);

  @override
  Map<String, dynamic> get toJson => {
        familyMemberDocumentIsParentField: isParent,
        familyMemberDocumentIsCreatorField: isCreator,
        familyMemberDocumentPointsCollectedField: pointsCollected
      };
}
