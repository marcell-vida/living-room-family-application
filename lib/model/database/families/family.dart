import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:living_room/extension/dart/map_extension.dart';
import 'package:living_room/model/database/base/firestore_item.dart';

const String familiesCollectionPath = "families";

const String familyDocumentCreationDateField = "createdAt";
const String familyDocumentNameField = "name";
const String familyDocumentDescriptionField = "description";
const String familyDocumentPhotoUrlField = "photoUrl";

class Family extends FirestoreItem{
  DateTime? createdAt;
  String? name;
  String? description;
  String? photoUrl;


  Family({this.createdAt, this.name, this.description, this.photoUrl});

  Family.fromSnapshot(
      MapEntry<DocumentReference, Map<String, dynamic>> snapshotEntry)
      : super.doc(snapshotEntry.key) {
    var data = snapshotEntry.value;
    createdAt = data.getTimestamp(familyDocumentCreationDateField)?.toDate();
    name = data.getString(familyDocumentNameField);
    description = data.getString(familyDocumentDescriptionField);
    photoUrl = data.getString(familyDocumentPhotoUrlField);
  }

  @override
  String get collectionPath => familiesCollectionPath;

  @override
  Map<String, dynamic> get toJson => {
    familyDocumentCreationDateField: createdAt,
    familyDocumentNameField: name,
    familyDocumentDescriptionField: description,
    familyDocumentPhotoUrlField: photoUrl
  };
}
