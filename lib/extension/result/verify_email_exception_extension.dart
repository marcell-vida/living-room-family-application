import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:living_room/extension/dart/context_extension.dart';

// messages indicating errors during email verification
enum VerifyEmailException { emailNotSent, tooManyRequests }

extension VerifyEmailExceptionExtension on VerifyEmailException {
  String getErrorMessage(BuildContext context) {
    try {
      AppLocalizations appLocalizations = context.loc!;
      switch (this) {
        case VerifyEmailException.emailNotSent:
          return appLocalizations.verifyEmailExceptionEmailNotSent;
        case VerifyEmailException.tooManyRequests:
          return appLocalizations.globalExceptionTooManyRequests;
        default:
          return appLocalizations.globalExceptionUnknownError;
      }
    } catch (e) {
      return '';
    }
  }
}
