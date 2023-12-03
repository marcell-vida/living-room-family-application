import 'package:flutter/material.dart';
import 'package:living_room/extension/dart/context_extension.dart';

enum DatabaseException {
  permissionDenied,
  noDocumentFound,
  unknown
}

extension DatabaseExceptionExtension on DatabaseException {
  String getErrorMessage(BuildContext context) {
    try{
      var appLocalizations = context.loc!;
      switch (this) {
        case DatabaseException.permissionDenied:
          return appLocalizations.databaseExceptionPermissionDenied;
        case DatabaseException.noDocumentFound:
          return appLocalizations.databaseExceptionNoDocument;
        case DatabaseException.unknown:
          return appLocalizations.globalExceptionUnknownError;
        default:
          return appLocalizations.globalExceptionUnknownError;
      }
    } catch (e){
      return '';
    }
  }
}