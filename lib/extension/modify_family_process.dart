import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:living_room/extension/dart/context_extension.dart';

enum ModifyFamilyProcess {
  saveFamily,
  uploadPhoto,
  savePhotoUrl,
  saveOwnerMember,
  saveOwnerInvitation,
  saveInvitations
}
extension ModifyFamilyProcessExtension on ModifyFamilyProcess{
  String getTitle (BuildContext context){
    try {
      AppLocalizations appLocalizations = context.loc!;

      switch (this) {
        case ModifyFamilyProcess.saveFamily:
          return appLocalizations.familiesTabCreateProcessSaveFamily;
        case ModifyFamilyProcess.saveOwnerMember:
          return appLocalizations.familiesTabCreateProcessSaveOwnerMember;
        case ModifyFamilyProcess.saveOwnerInvitation:
          return appLocalizations.familiesTabCreateProcessSaveOwnerInvite;
        case ModifyFamilyProcess.uploadPhoto:
          return appLocalizations.familiesTabCreateProcessUploadPhoto;
        case ModifyFamilyProcess.savePhotoUrl:
          return appLocalizations.familiesTabCreateProcessSavePhotoUrl;
        case ModifyFamilyProcess.saveInvitations:
          return appLocalizations.familiesTabCreateProcessSaveInvites;
        default:
          return '';
      }
    } catch (e) {
      return '';
    }
  }
}