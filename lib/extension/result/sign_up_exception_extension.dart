import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:living_room/extension/dart/context_extension.dart';

// messages indicating errors occurring during registration
enum SignUpException {
  emailAlreadyInUse,
  invalidEmail,
  operationNotAllowed,
  weakPassword,
  unknown
}

extension SignUpExceptionExtension on SignUpException {
  String getErrorMessage(BuildContext context) {
    try {
      AppLocalizations appLocalizations = context.loc!;
      switch (this) {
        case SignUpException.invalidEmail:
          return appLocalizations.globalExceptionInvalidEmail;
        case SignUpException.emailAlreadyInUse:
          return appLocalizations.signUpExceptionEmailAlreadyUsed;
        case SignUpException.operationNotAllowed:
          return appLocalizations.globalExceptionOperationNotAllowed;
        case SignUpException.weakPassword:
          return appLocalizations.signUpExceptionWeakPassword;
        case SignUpException.unknown:
          return appLocalizations.globalExceptionUnknownError;
        default:
          return appLocalizations.globalExceptionUnknownError;
      }
    } catch (e) {
      return '';
    }
  }
}
