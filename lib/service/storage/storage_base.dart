abstract class StorageBase {
  void uploadFile(String directory, String filePath, String uploadName,
      {Function? onSuccess, Function? onError});

  void deleteFile(String directory, {Function? onSuccess, Function? onError});
}
