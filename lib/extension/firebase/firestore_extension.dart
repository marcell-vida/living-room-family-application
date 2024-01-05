import 'package:cloud_firestore/cloud_firestore.dart';

extension MyQuerySnapshot on QuerySnapshot<Object?> {
  Map<DocumentReference, Map<String, dynamic>>? data() {
    try {
      return {
        for (var v in docs)
          v.reference: (v.data() as Map).cast<String, dynamic>()
      };
    } catch (e) {
      return null;
    }
  }
}

extension MyDocumentSnapshot on DocumentSnapshot<Object?> {
  MapEntry<DocumentReference, Map<String, dynamic>>? document() {
    try {
      return MapEntry(reference, (data() as Map).cast<String, dynamic>());
    } catch (e) {
      return null;
    }
  }
}
