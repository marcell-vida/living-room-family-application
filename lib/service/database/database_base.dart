import 'package:living_room/model/database/base/firestore_item.dart';

abstract class DatabaseBase {
  //#region General
  Future<T> saveItem<T>(
      {required FirestoreItem firestoreItem, String? documentId});

  Future<void> setDocumentFields(String path, Map<String, dynamic> json,
      {void Function()? onSuccess, void Function()? onError});

  Future<void> deleteDocument(String path,
      {void Function()? onSuccess, void Function()? onError});

  Stream<T?> streamTDocument<T>(String path);

  Future<T?>? getTDocument<T>(String path);

  Stream<List<T>?> streamTCollection<T>(
      String path);

  Future<List<T>?> getTCollection<T>(
      String path);
}
