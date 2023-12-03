import 'package:living_room/service/storage/base/firebase_storage.dart';
import 'package:living_room/service/storage/storage_base.dart';

const String firebaseStorageUsersPath = 'users';
const String firebaseStorageFamiliesPath = 'families';

String convertUrlToFileName(String url, String storagePath) => url
    .replaceAll(firebaseStoragePath(storagePath), '')
    .replaceAll('?alt=media', '');

class StorageService {
  static final StorageService _instance = StorageService._();
  static late StorageBase _storageBase;

  StorageService._();

  factory StorageService() {
    _storageBase = StorageImp();
    return _instance;
  }

  void changeUserProfilePicture(
      {required String localFilePath,
      required String uploadName,
      required String userUid,
      String? currentFilePath,
      Function? onSuccess,
      Function? onError}) {
    if (currentFilePath != null) {
      try {
        String oldFileName = currentFilePath
            .replaceAll(
                firebaseStoragePath('$firebaseStorageUsersPath%2F$userUid%2F'),
                '')
            .replaceAll('?alt=media', '');
        _storageBase
            .deleteFile('$firebaseStorageUsersPath/$userUid/$oldFileName');
      } catch (_) {
        onError?.call();
        return;
      }
    }
    _storageBase.uploadFile(
        '$firebaseStorageUsersPath/$userUid', localFilePath, uploadName,
        onSuccess: (path) => onSuccess?.call('$path?alt=media'),
        onError: onError);
  }

  //#region Families
  void changeFamilyPicture(
      {required String localFilePath,
      required String uploadName,
      required String familyUid,
      String? currentFileUrl,
      Function? onSuccess,
      Function? onError}) {
    if (currentFileUrl != null) {
      try {
        String oldFileName = convertUrlToFileName(
            currentFileUrl, '$firebaseStorageFamiliesPath%2F$familyUid%2F');
        _storageBase.deleteFile(
            '$firebaseStorageFamiliesPath/$familyUid/familyPhoto/$oldFileName');
      } catch (_) {
        onError?.call();
        return;
      }
    }
    _storageBase.uploadFile(
        '$firebaseStorageFamiliesPath/$familyUid/familyPhoto',
        localFilePath,
        uploadName,
        onSuccess: (path) => onSuccess?.call('$path?alt=media'),
        onError: onError);
  }

  void changeTaskPicture(
      {required String localFilePath,
      required String uploadName,
      required String familyUid,
      required String userUid,
      required String taskUid,
      String? currentFilePath,
      void Function(String)? onSuccess,
      void Function()? onError}) {
    if (currentFilePath != null) {
      try {
        String oldFileName = currentFilePath
            .replaceAll(
                firebaseStoragePath(
                    '$firebaseStorageFamiliesPath%2F$familyUid%2Fmembers%2F$userUid%2Ftasks%2F$taskUid'),
                '')
            .replaceAll('?alt=media', '');
        _storageBase.deleteFile(
            '$firebaseStorageFamiliesPath/$familyUid/members/$userUid/tasks/$taskUid/$oldFileName');
      } catch (_) {
        onError?.call();
        return;
      }
    }
    _storageBase.uploadFile(
        '$firebaseStorageFamiliesPath/$familyUid/members/$userUid/tasks/$taskUid',
        localFilePath,
        uploadName,
        onSuccess: (path) => onSuccess?.call('$path?alt=media'),
        onError: onError);
  }

  void changeGoalPicture(
      {required String localFilePath,
      required String uploadName,
      required String familyUid,
      required String userUid,
      required String goalUid,
      String? currentFilePath,
      void Function(String)? onSuccess,
      void Function()? onError}) {
    if (currentFilePath != null) {
      try {
        /// the name of the old file is extracted from the old url
        String oldFileName = currentFilePath
            .replaceAll(
                firebaseStoragePath(_onlineUrl([
                  firebaseStorageFamiliesPath,
                  familyUid,
                  'members',
                  userUid,
                  'goals',
                  goalUid
                ])),
                '')
            .replaceAll('?alt=media', '');
        /// old file gets deleted
        _storageBase.deleteFile(
            '$firebaseStorageFamiliesPath/$familyUid/members/$userUid/tasks/$goalUid/$oldFileName');
      } catch (_) {
        onError?.call();
        return;
      }
    }
    /// upload new file
    _storageBase.uploadFile(
      _normalUrl([
        firebaseStorageFamiliesPath,
        familyUid,
        'members',
        userUid,
        'tasks',
        goalUid
      ]),
        localFilePath,
        uploadName,
        onSuccess: (path) => onSuccess?.call('$path?alt=media'),
        onError: onError);
  }

  /// puts %2F character between [parts]
  String _onlineUrl(List<String> parts) {
    String result = '';

    for (int i = 0; i < parts.length; i++) {
      if (i != 0) {
        result += '%2F${parts[i]}';
      } else {
        result = parts.first;
      }
    }

    return result;
  }

  /// puts / character between [parts]
  String _normalUrl(List<String> parts) {
    String result = '';

    for (int i = 0; i < parts.length; i++) {
      if (i != 0) {
        result += '/${parts[i]}';
      } else {
        result = parts.first;
      }
    }

    return result;
  }

//#endregion
}
