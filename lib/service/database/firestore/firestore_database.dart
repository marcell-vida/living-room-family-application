import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:living_room/extension/firebase/firestore_extension.dart';
import 'package:living_room/extension/result/database_exception_extension.dart';
import 'package:living_room/model/database/base/firestore_item.dart';
import 'package:living_room/model/database/families/family.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/families/family_member_goal.dart';
import 'package:living_room/model/database/families/family_member_task.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/model/database/users/invitation.dart';
import 'package:living_room/service/database/database_base.dart';

typedef FirestoreItemMapFunction = FirestoreItem Function(
    MapEntry<DocumentReference<Object?>, Map<String, dynamic>>);

FirestoreItemMapFunction _mapInv = (doc) => Invitation.fromSnapshot(doc);
FirestoreItemMapFunction _mapFam = (doc) => Family.fromSnapshot(doc);
FirestoreItemMapFunction _mapMem = (doc) => FamilyMember.fromSnapshot(doc);
FirestoreItemMapFunction _mapGoal = (doc) => FamilyMemberGoal.fromSnapshot(doc);
FirestoreItemMapFunction _mapTask = (doc) => FamilyMemberTask.fromSnapshot(doc);
FirestoreItemMapFunction _mapUser = (doc) => DatabaseUser.fromSnapshot(doc);

FirestoreItemMapFunction? _firestoreItemMapFunction<T>() {
  if (T == DatabaseUser) {
    return _mapUser;
  } else if (T == Invitation) {
    return _mapInv;
  } else if (T == Family) {
    return _mapFam;
  } else if (T == FamilyMember) {
    return _mapMem;
  } else if (T == FamilyMemberTask) {
    return _mapTask;
  } else if (T == FamilyMemberGoal) {
    return _mapGoal;
  }
  return null;
}

class DatabaseImp extends DatabaseBase {
  //#region Singleton factory
  static final DatabaseImp _instance = DatabaseImp._();

  DatabaseImp._();

  factory DatabaseImp() {
    return _instance;
  }

  //#endregion

  //#region Basics
  final rawDatabaseExceptions = {
    "permission-denied": DatabaseException.permissionDenied,
  };

  FirebaseFirestore get _firestoreInstance {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    firebaseFirestore.settings = const Settings(persistenceEnabled: false);
    return firebaseFirestore;
  }

  CollectionReference collection(String path) {
    return _firestoreInstance.collection(path);
  }

  DocumentReference document(String path) {
    return _firestoreInstance.doc(path);
  }

  Query collectionGroup(String path) {
    return _firestoreInstance.collectionGroup(path);
  }

  @override
  Future<T> saveItem<T>(
      {required FirestoreItem firestoreItem, String? documentId}) async {
    assert(documentId == null || documentId.isNotEmpty);
    if (firestoreItem.documentReference == null) {
      var coll = collection(firestoreItem.collectionPath);
      if (documentId != null) {
        firestoreItem.documentReference = coll.doc(documentId);
        await firestoreItem.documentReference?.set(firestoreItem.toJson);
      } else {
        firestoreItem.documentReference = await coll.add(firestoreItem.toJson);
      }
    } else {
      await firestoreItem.documentReference
          ?.set(firestoreItem.toJson, SetOptions(merge: true));
    }
    return firestoreItem as T;
  }

  @override
  Future<void> deleteDocument(String path,
      {void Function()? onSuccess, void Function()? onError}) async {
    return await document(path)
        .delete()
        .then((_) => onSuccess?.call(), onError: (_) => onError?.call());
  }

  @override
  Future<void> setDocumentFields(String path, Map<String, dynamic> json,
      {void Function()? onSuccess, void Function()? onError}) async {
    return await document(path)
        .set(json, SetOptions(merge: true))
        .then((_) => onSuccess?.call(), onError: (_) => onError?.call());
  }

  @override
  Stream<T?> streamTDocument<T>(String path) {
    return document(path).snapshots().asyncMap((data) {
      var documentMapEntry = data.document();
      if (documentMapEntry != null) {
        var x = _firestoreItemMapFunction<T>()?.call(documentMapEntry) as T;
        return x;
      }
      return null;
    });
  }

  @override
  Future<List<T>?> getTCollection<T>(String path) async {
    var snapshot = await collection(path).get();
    return snapshot.data()?.entries.map((entry) {
      return _firestoreItemMapFunction<T>()?.call(entry) as T;
    }).toList();
  }

  @override
  Future<T?>? getTDocument<T>(String path) async {
    var data = await document(path).get();
    var documentMapEntry = data.document();
    return documentMapEntry != null
        ? _firestoreItemMapFunction<T>()?.call(documentMapEntry) as T
        : null;
  }

  @override
  Stream<List<T>?> streamTCollection<T>(String path) {
    return collection(path).snapshots().asyncMap((event) {
      return event
          .data()
          ?.entries
          .map((entry) => _firestoreItemMapFunction<T>()?.call(entry) as T)
          .toList();
    });
  }
}
