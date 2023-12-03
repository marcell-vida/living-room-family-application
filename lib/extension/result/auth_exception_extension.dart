import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:living_room/extension/dart/context_extension.dart';

// messages indicating errors occurring during login
enum AuthException {
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  emailNotVerified,
  tooManyRequests,
  networkRequestFailed,
  unknown
}

extension AuthExceptionExtension on AuthException {
  String getErrorMessage(BuildContext context) {
    try {
      AppLocalizations appLocalizations = context.loc!;
      switch (this) {
        case AuthException.emailNotVerified:
          return appLocalizations.signInExceptionEmailNotVerified;
        case AuthException.invalidEmail:
          return appLocalizations.globalExceptionInvalidEmail;
        case AuthException.userDisabled:
          return appLocalizations.signInExceptionUserDisabled;
        case AuthException.userNotFound:
          return appLocalizations.signInExceptionUserNotFound;
        case AuthException.wrongPassword:
          return appLocalizations.signInExceptionWrongPassword;
        case AuthException.tooManyRequests:
          return appLocalizations.globalExceptionTooManyRequests;
        case AuthException.unknown:
          return appLocalizations.globalExceptionUnknownError;
        case AuthException.networkRequestFailed:
          return appLocalizations.signInExceptionNetworkError;
        default:
          return appLocalizations.globalExceptionUnknownError;
      }
    } catch (e) {
      return '';
    }
  }
}
