import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:living_room/service/storage/storage_base.dart';

String firebaseStoragePath(String path) =>
    'https://firebasestorage.googleapis.com/v0/b/living-room-9bcc0.appspot.com/o/$path';

class StorageImp extends StorageBase {
  static final StorageImp _instance = StorageImp._();

  StorageImp._();

  factory StorageImp() {
    return _instance;
  }

  FirebaseStorage get _firebaseStorageInstance {
    return FirebaseStorage.instance;
  }

  Reference get _firebaseStorageRef => _firebaseStorageInstance.ref();

  @override
  void uploadFile(String directory, String filePath, String uploadName,
      {Function? onSuccess, Function? onError}) {
    File file = File(filePath);
    _firebaseStorageRef.child(directory).child(uploadName).putFile(file).then(
        (result) {
      String modifiedPath =
          firebaseStoragePath(result.ref.fullPath.replaceAll('/', '%2F'));
      onSuccess?.call(modifiedPath);
    }, onError: (_) {
      debugPrint('Upload failed');
      onError?.call();
    });
  }

  @override
  void deleteFile(
      String directory, {Function? onSuccess, Function? onError}) {
    _firebaseStorageRef
        .child(directory)
        .delete()
        .then((_) => onSuccess?.call(), onError: (_) => onError?.call());
  }
}
