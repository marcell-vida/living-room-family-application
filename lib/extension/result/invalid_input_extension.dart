import 'package:flutter/material.dart';
import 'package:living_room/extension/dart/context_extension.dart';

// messages indicating incorrect inputs
enum InvalidInput {
  emptyInput,
  invalidEmail,
  invalidPassword,
  passwordsNotMatch
}

extension InvalidInputExtension on InvalidInput {
  String getErrorMessage(BuildContext context) {
    try{
      var appLocalizations = context.loc!;
      switch (this) {
        case InvalidInput.emptyInput:
          return appLocalizations.invalidInputEmpty;
        case InvalidInput.invalidEmail:
          return appLocalizations.invalidInputEmail;
        case InvalidInput.invalidPassword:
          return appLocalizations.invalidInputPassword;
        case InvalidInput.passwordsNotMatch:
          return appLocalizations.invalidInputPasswordsNotMatch;
        default:
          return appLocalizations.globalExceptionUnknownError;
      }
    } catch (e){
      return '';
    }
  }
}