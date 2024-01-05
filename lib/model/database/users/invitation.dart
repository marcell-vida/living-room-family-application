import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:living_room/extension/dart/map_extension.dart';
import 'package:living_room/model/database/base/firestore_item.dart';

userInvitationCollectionPath(String userId) => "users/$userId/invitations";

const String userInvitationDocumentFamilyIdField = "familyId";
const String userInvitationDocumentSenderField = "sender";
const String userInvitationDocumentSentAtField = "sentAt";
const String userInvitationDocumentMessageField = "message";
const String userInvitationDocumentAcceptedField = "accepted";

class Invitation extends FirestoreItem {
  String? userId;
  String? familyId;
  String? sender;
  DateTime? sentAt;
  String? message;
  bool? accepted;

  Invitation(
      {this.userId,
      this.familyId,
      this.sender,
      this.sentAt,
      this.message,
      this.accepted});

  Invitation.fromSnapshot(
      MapEntry<DocumentReference, Map<String, dynamic>> snapshotEntry)
      : super.doc(snapshotEntry.key) {
    var data = snapshotEntry.value;
    userId = snapshotEntry.key.parent.parent?.id;
    familyId = data.getString(userInvitationDocumentFamilyIdField);
    sender = data.getString(userInvitationDocumentSenderField);
    sentAt = data.getTimestamp(userInvitationDocumentSentAtField)?.toDate();
    message = data.getString(userInvitationDocumentMessageField);
    accepted = data.getBool(userInvitationDocumentAcceptedField);
  }

  @override
  String get collectionPath => userInvitationCollectionPath(userId!);

  @override
  Map<String, dynamic> get toJson => {
        userInvitationDocumentFamilyIdField: familyId,
        userInvitationDocumentSenderField: sender,
        userInvitationDocumentSentAtField: sentAt,
        userInvitationDocumentMessageField: message,
        userInvitationDocumentAcceptedField: accepted,
      };

  @override
  String toString() {
    return toJson.toString();
  }
}
