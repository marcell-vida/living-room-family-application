import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/data_base_user_stream_subscription_list_extension.dart';
import 'package:living_room/extension/modify_family_process.dart';
import 'package:living_room/model/database/families/family.dart';
import 'package:living_room/model/database/families/family_member.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/model/database/users/invitation.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/service/storage/storage_service.dart';
import 'package:living_room/state/object/family_bloc.dart';
import 'package:living_room/util/utils.dart';

/// [EditFamilyCubit] manages [Family] modifications and creations.
class EditFamilyCubit extends Cubit<EditFamilyState> {
  final FamilyCubit? existingFamilyCubit;
  final DatabaseService _databaseService;
  final AuthenticationService _authenticationService;
  final StorageService _storageService;
  final List<StreamSubscription<DatabaseUser?>>
      _individualUsersStreamSubscriptions;
  StreamSubscription? _usersStreamSubscription;
  StreamSubscription? _existingFamilyStreamSubscription;

  EditFamilyCubit(
      {this.existingFamilyCubit,
      required DatabaseService databaseService,
      required AuthenticationService authenticationService,
      required StorageService storageService})
      : _databaseService = databaseService,
        _authenticationService = authenticationService,
        _storageService = storageService,
        _individualUsersStreamSubscriptions = [],
        super(const EditFamilyState()) {
    _init();
  }

  Future<void> _init() async {
    if (existingFamilyCubit != null) {
      // this is a modification of an existing family
      _existingFamilyStreamSubscription =
          existingFamilyCubit?.stream.listen(_onFamilyUpdate);

      if (state.existingFamilyState == null) {
        _onFamilyUpdate(existingFamilyCubit?.state);
      }
    } else {
      // this is the creation of a new family
      await _initInvitations();
    }

    _usersStreamSubscription =
        _databaseService.streamUsers().listen(_onUsersUpdate);
  }

  void _onFamilyUpdate(FamilyState? familyState) {
    if (familyState != null) {
      emit(state.copyWith(existingFamilyState: familyState));
    }
  }

  Future<void> _initInvitations() async {
    DatabaseUser? currentUser = await _databaseService.getUserById(
        uid: _authenticationService.currentUser?.uid ?? '');
    if (currentUser != null) {
      emit(state.copyWith(eligibleInvitations: [currentUser]));
    }
  }

  /// Called when the list of users in the database updates.
  ///
  /// This method checks if the set invitations still can be made with
  /// the new list of users and sets up streams to those users.
  Future<void> _onUsersUpdate(List<DatabaseUser>? users) async {
    List<DatabaseUser> previousInvitations = state.eligibleInvitations ?? [];
    List<DatabaseUser> allUsers =
        users ?? await _databaseService.getUsers() ?? [];
    List<DatabaseUser> newInvitations = [];
    if (previousInvitations.isNotEmpty && users != null && users.isNotEmpty) {
      // there are invitations and users
      for (DatabaseUser dbCurrent in allUsers) {
        for (DatabaseUser invCurrent in previousInvitations) {
          if (dbCurrent.id == invCurrent.id) {
            // current DatabaseUser is one of the invited
            if (!newInvitations.contains(dbCurrent)) {
              newInvitations.add(dbCurrent);
            }
          }
        }
      }
    }

    // stream the changes of the users
    _setIndividualStreamSubscriptions(newInvitations);

    emit(state.copyWith(users: users, eligibleInvitations: newInvitations));
  }

  /// This method sets up the individual user streams on the invited users
  void _setIndividualStreamSubscriptions(List<DatabaseUser> newInvitations) {
    onUserUpdates(DatabaseUser? user) {
      List<DatabaseUser> newInvitees = state.eligibleInvitations ?? [];

      // modify corresponding user
      for (DatabaseUser current in newInvitees) {
        if (user != null && current.id == user.id) {
          current = user;
          break;
        }
      }

      emit(state.copyWith(eligibleInvitations: newInvitees));
    }

    _individualUsersStreamSubscriptions.clearAndAddSubscriptions(
        usersToAdd: newInvitations,
        databaseService: _databaseService,
        onUserUpdates: onUserUpdates);
  }

  /// Sets the individual process's statuses based on the [Map] given.
  void _setProcessStatuses(
      Map<ModifyFamilyProcess, ProcessStatus> newStatuses) {
    Map<ModifyFamilyProcess, ProcessStatus> statuses =
        state.saveDetailedStatus ?? {};

    for (MapEntry<ModifyFamilyProcess, ProcessStatus> element
        in newStatuses.entries) {
      statuses[element.key] = element.value;
    }
    emit(state.copyWith(saveDetailedStatus: statuses));
  }

  /// This method saves the changes made in an existing [Family] object
  /// or creates one.
  Future<void> save() async {
    if (state.name != null && state.name!.isNotEmpty) {
      emit(state.copyWith(saveGeneralStatus: ProcessStatus.processing));

      // save basic data
      Family? family = await _saveFamilyProcess();

      if (family != null &&
          state.saveGeneralStatus != ProcessStatus.unsuccessful) {
        // photo
        _uploadPhotoProcess(family, _savePhotoUrl);

        // invites
        await _saveInvitesProcess(family);

        // success
        emit(state.copyWith(saveGeneralStatus: ProcessStatus.successful));
        return;
      } else {
        // previous step did not succeed
        return;
      }
    }
    emit(state.copyWith(saveGeneralStatus: ProcessStatus.unsuccessful));
  }

  /// This method updates or creates a [Family].
  Future<Family?> _saveFamilyProcess() async {
    if (existingFamilyCubit != null) {
      return await _updateFamily();
    } else {
      return await _createFamily();
    }
  }

  /// This method saves the [Invitation]s to the users given.
  Future<void> _saveInvitesProcess(Family family) async {
    if (family.id != null) {
      // send out invites
      String signedInUserId = _authenticationService.currentUser?.uid ?? '';

      if (signedInUserId.isNotEmpty) {
        List<DatabaseUser> invitedUsers = state.eligibleInvitations ?? [];

        for (DatabaseUser currentUser in invitedUsers) {
          if (currentUser.id != null && currentUser.id != signedInUserId) {
            // get user's invitations
            List<Invitation> currentUserInvitations = await _databaseService
                    .getUserInvitations(userId: currentUser.id!) ??
                [];

            // check if this user was already invited to the family or not
            bool alreadyInvited = false;
            for (Invitation currentInvitation in currentUserInvitations) {
              if (currentInvitation.familyId == family.id) {
                alreadyInvited = true;
              }
            }

            if (alreadyInvited == false) {
              // not invited yet
              Invitation? invitation =
                  await _databaseService.createUserInvitation(
                      targetUserId: currentUser.id!,
                      familyId: family.id!,
                      message: state.invitationMessage,
                      authenticationService: _authenticationService);

              if (invitation == null) {
                // saving this invitation did not succeed
                _setProcessStatuses({
                  ModifyFamilyProcess.saveInvitations:
                      ProcessStatus.unsuccessful
                });
                return;
              }
            }
          }
        }
        // successful invitations
        _setProcessStatuses(
            {ModifyFamilyProcess.saveInvitations: ProcessStatus.successful});
      } else {
        // signed in user id is empty
        _setProcessStatuses(
            {ModifyFamilyProcess.saveInvitations: ProcessStatus.unsuccessful});
        return;
      }
    } else {
      // family id is null
      _setProcessStatuses(
          {ModifyFamilyProcess.saveInvitations: ProcessStatus.unsuccessful});
      return;
    }
  }

  /// Uploads the chosen photo.
  void _uploadPhotoProcess(
      Family family, void Function(String?, Family) onUploadSuccess) {
    String photoPath = state.photoUploadPath ?? '';
    if (photoPath == '') {
      // no photo upload needed
      return;
    } else if (family.id != null) {
      // family id is valid

      onError(_) {
        _setProcessStatuses(
            {ModifyFamilyProcess.uploadPhoto: ProcessStatus.unsuccessful});
      }

      onSuccess(String? path) {
        _setProcessStatuses(
            {ModifyFamilyProcess.uploadPhoto: ProcessStatus.successful});

        onUploadSuccess(path, family);
      }

      _storageService.changeFamilyPicture(
          localFilePath: state.photoUploadPath!,
          uploadName: '${family.id}${DateTime.now().millisecondsSinceEpoch}',
          familyUid: family.id!,
          onError: onError,
          onSuccess: onSuccess);
    }
  }

  /// Saves the url of the uploaded photo to the previously saved [Family]
  /// object.
  Future<void> _savePhotoUrl(String? path, Family family) async {
    onError() {
      _setProcessStatuses(
          {ModifyFamilyProcess.savePhotoUrl: ProcessStatus.unsuccessful});
    }

    onSuccess() {
      _setProcessStatuses(
          {ModifyFamilyProcess.savePhotoUrl: ProcessStatus.successful});
    }

    await _databaseService.updateFamily(
        familyUid: family.id!,
        photoUrl: path,
        onError: onError,
        onSuccess: onSuccess());
  }

  /// This method updates an existing family based on the properties stored in
  /// [EditFamilyState]
  Future<Family?> _updateFamily() async {
    Family? existingFamily = state.existingFamilyState?.family;
    if (existingFamily != null &&
        existingFamily.name == state.name &&
        existingFamily.description == state.description) {
      // nothing to be modified
      return existingFamily;
    } else if (existingFamily?.id != null) {
      _setProcessStatuses(
          {ModifyFamilyProcess.saveFamily: ProcessStatus.processing});

      onSuccess() {
        _setProcessStatuses(
            {ModifyFamilyProcess.saveFamily: ProcessStatus.successful});
      }

      onError() {
        _setProcessStatuses(
            {ModifyFamilyProcess.saveFamily: ProcessStatus.unsuccessful});
      }

      // update family
      await _databaseService.updateFamily(
          familyUid: existingFamily!.id!,
          name: state.name,
          description: state.description,
          onSuccess: onSuccess,
          onError: onError);

      // return updated family
      return await _databaseService.getFamily(existingFamily.id!);
    }
    return null;
  }

  /// This method creates a family with the properties stored in [EditFamilyState]
  Future<Family?> _createFamily() async {
    _setProcessStatuses({
      ModifyFamilyProcess.saveFamily: ProcessStatus.processing,
      ModifyFamilyProcess.saveOwnerMember: ProcessStatus.processing,
      ModifyFamilyProcess.saveOwnerInvitation: ProcessStatus.processing
    });

    CreateFamilyResult? createFamilyResult =
        await _databaseService.createFamily(
            authenticationService: _authenticationService,
            name: state.name,
            description: state.description,
            photoUrl: null);

    // determine family save success
    Family? family = createFamilyResult?.family;
    _setProcessStatuses({
      ModifyFamilyProcess.saveFamily:
          family != null ? ProcessStatus.successful : ProcessStatus.unsuccessful
    });

    // determine owner member save success
    FamilyMember? ownerMember = createFamilyResult?.member;
    _setProcessStatuses({
      ModifyFamilyProcess.saveOwnerMember: ownerMember != null
          ? ProcessStatus.successful
          : ProcessStatus.unsuccessful
    });

    // determine owner invite save success
    Invitation? ownerInvitation = createFamilyResult?.invitation;
    _setProcessStatuses({
      ModifyFamilyProcess.saveOwnerInvitation: ownerInvitation != null
          ? ProcessStatus.successful
          : ProcessStatus.unsuccessful
    });

    if (family != null && ownerMember != null && ownerInvitation != null) {
      //success
      return family;
    }
    return null;
  }

  /// The invitation in the input field will get approved.
  void approveCurrentInvitation(List<DatabaseUser>? users) {
    emit(state.copyWith(addInviteStatus: ProcessStatus.processing));
    if (state.tempInvitationEmail != null &&
        state.tempInvitationEmail!.isNotEmpty) {
      List<DatabaseUser> listToSearch = users ?? state.users ?? [];

      if (listToSearch.isNotEmpty) {
        DatabaseUser? searchUser;
        for (DatabaseUser current in listToSearch) {
          if (current.email != null &&
              current.email == state.tempInvitationEmail) {
            searchUser = current;
            break;
          }
        }
        if (searchUser != null) {
          List<DatabaseUser> newInvitationsList =
              state.eligibleInvitations ?? [];
          if (!newInvitationsList.contains(searchUser)) {
            newInvitationsList.add(searchUser);
            emit(state.copyWith(
                eligibleInvitations: newInvitationsList,
                tempInvitationEmail: '',
                addInviteStatus: ProcessStatus.successful));
            emit(state.copyWith(addInviteStatus: ProcessStatus.idle));
            return;
          }
        }
      }
    }
    emit(state.copyWith(addInviteStatus: ProcessStatus.unsuccessful));
    emit(state.copyWith(addInviteStatus: ProcessStatus.idle));
  }

  void approvePhotoPath(bool? approve) {
    if (approve == true &&
        state.tempPhotoPath != null &&
        state.tempPhotoPath!.isNotEmpty) {
      emit(state.copyWith(photoUploadPath: state.tempPhotoPath));
    }
  }

  void setCurrentInvitation(String? newValue) {
    if (newValue != null && newValue != state.tempInvitationEmail) {
      emit(state.copyWith(tempInvitationEmail: newValue));
    }
  }

  void setName(String? newName) {
    if (newName != null && newName != state.name) {
      emit(state.copyWith(name: newName));
    }
  }

  void setDescription(String? newDescription) {
    if (newDescription != null && newDescription != state.description) {
      emit(state.copyWith(description: newDescription));
    }
  }

  void setPhotoTempPath(String? newPath) {
    if (newPath != null && newPath != state.tempPhotoPath) {
      emit(state.copyWith(tempPhotoPath: newPath));
    }
  }

  void setInvitationMessage(String? value) {
    if (value != null) {
      emit(state.copyWith(invitationMessage: value));
    }
  }

  @override
  Future<void> close() {
    _individualUsersStreamSubscriptions.clearSubscriptions();
    _usersStreamSubscription?.cancel();
    _existingFamilyStreamSubscription?.cancel();
    return super.close();
  }
}

class EditFamilyState extends Equatable {
  final FamilyState? existingFamilyState;
  final String? name;
  final String? description;
  final String? photoUploadPath;
  final String? invitationMessage;
  final List<DatabaseUser>? eligibleInvitations;
  final String? tempInvitationEmail;
  final String? tempPhotoPath;
  final ProcessStatus addInviteStatus;
  final ProcessStatus saveGeneralStatus;
  final Map<ModifyFamilyProcess, ProcessStatus>? saveDetailedStatus;
  final List<DatabaseUser>? users;
  final bool updateFlag;
  final List<Invitation>? invitations;

  const EditFamilyState(
      {this.existingFamilyState,
      this.name,
      this.description,
      this.tempPhotoPath,
      this.photoUploadPath,
      this.invitationMessage,
      this.invitations,
      this.users,
      this.tempInvitationEmail,
      this.eligibleInvitations,
      this.addInviteStatus = ProcessStatus.idle,
      this.saveGeneralStatus = ProcessStatus.idle,
      this.saveDetailedStatus,
      this.updateFlag = true});

  EditFamilyState copyWith(
      {FamilyState? existingFamilyState,
      String? name,
      String? description,
      String? tempPhotoPath,
      String? photoUploadPath,
      String? invitationMessage,
      List<Invitation>? invitations,
      List<DatabaseUser>? users,
      String? tempInvitationEmail,
      List<DatabaseUser>? eligibleInvitations,
      ProcessStatus? saveGeneralStatus,
      ProcessStatus? addInviteStatus,
      Map<ModifyFamilyProcess, ProcessStatus>? saveDetailedStatus}) {
    debugPrint('EditFamilyState.copyWith: name == $name');
    return EditFamilyState(
        existingFamilyState: existingFamilyState ?? this.existingFamilyState,
        name: name ?? this.name,
        description: description ?? this.description,
        tempPhotoPath: tempPhotoPath ?? this.tempPhotoPath,
        photoUploadPath: photoUploadPath ?? this.photoUploadPath,
        invitationMessage: invitationMessage ?? this.invitationMessage,
        invitations: invitations ?? this.invitations,
        saveGeneralStatus: saveGeneralStatus ?? this.saveGeneralStatus,
        tempInvitationEmail: tempInvitationEmail ?? this.tempInvitationEmail,
        eligibleInvitations: eligibleInvitations ?? this.eligibleInvitations,
        users: users ?? this.users,
        addInviteStatus: addInviteStatus ?? this.addInviteStatus,
        saveDetailedStatus: saveDetailedStatus ?? this.saveDetailedStatus,
        updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [
        name,
        description,
        tempPhotoPath,
        photoUploadPath,
        invitationMessage,
        invitations,
        saveGeneralStatus,
        tempInvitationEmail,
        eligibleInvitations,
        users,
        addInviteStatus,
        updateFlag
      ];
}
