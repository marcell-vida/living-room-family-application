import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:living_room/extension/dart/context_extension.dart';

// messages indicating a successful operation
enum SuccessMessage { signUpComplete, verificationEmailSent, passwordChangeComplete }

extension SuccessMessageExtension on SuccessMessage {
  String getMessage(BuildContext context) {
    try {
      AppLocalizations appLocalizations = context.loc!;
      switch (this) {
        case SuccessMessage.signUpComplete:
          return appLocalizations.signUpSuccess;
        case SuccessMessage.verificationEmailSent:
          return appLocalizations.verifyEmailSuccessSent;
          case SuccessMessage.passwordChangeComplete:
          return appLocalizations.verifyEmailSuccessSent;
        default:
          return appLocalizations.globalExceptionUnknownError;
      }
    } catch (e) {
      return '';
    }
  }
}
