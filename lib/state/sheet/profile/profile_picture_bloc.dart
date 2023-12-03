import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/model/authentication/auth_user.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/service/storage/storage_service.dart';
import 'package:living_room/util/utils.dart';

class ProfilePictureCubit extends Cubit<ProfilePictureState> {
  final DatabaseService _databaseService;
  final AuthenticationService _authenticationService;
  final StorageService _storageService;

  ProfilePictureCubit(
      {required DatabaseService databaseService,
        required AuthenticationService authenticationService,
        required StorageService storageService})
      : _databaseService = databaseService,
        _authenticationService = authenticationService,
        _storageService = storageService,
        super(const ProfilePictureState());

  void modifyNewPictureUrl(String? changeTo) {
    emit(state.copyWith(newPictureUrl: changeTo));
  }

  Future<void> uploadPicture() async {
    emit(state.copyWith(pictureUpdateStatus: ProcessStatus.processing));
    AuthUser? authenticatedUser = _authenticationService.currentUser;
    DatabaseUser? databaseUser = authenticatedUser?.uid != null
        ? await _databaseService.getUserById(uid: authenticatedUser!.uid!)
        : null;

    onSuccess(String? path) async {
      await _databaseService.changeCurrentUserPhotoUrl(
          authenticationService: _authenticationService,
          photoUrl: path,
          onSuccess: () {
            emit(state.copyWith(
                pictureUpdateStatus: ProcessStatus.successful));
            debugPrint('SettingsCubit: state.uploadPicture: Successful operation');
          },
          onError: () => emit(state.copyWith(
              pictureUpdateStatus: ProcessStatus.unsuccessful)));
    }

    if(state.newPictureUrl == '' && authenticatedUser != null){
      onSuccess(null);
    }
    if (state.newPictureUrl != null && authenticatedUser != null) {
      _storageService.changeUserProfilePicture(
          localFilePath: state.newPictureUrl!,
          uploadName:
          '${Utils.userNameFromEmail(authenticatedUser.email ?? '')}${authenticatedUser.uid}${DateTime.now().millisecondsSinceEpoch}',
          userUid:
          '${Utils.userNameFromEmail(authenticatedUser.email ?? '')}${authenticatedUser.uid}',
          currentFilePath: databaseUser?.photoUrl,
          onSuccess: onSuccess,
          onError: () {
            emit(
                state.copyWith(pictureUpdateStatus: ProcessStatus.unsuccessful));
          });
    }
    emit(state.copyWith(pictureUpdateStatus: ProcessStatus.idle));
  }
}

class ProfilePictureState extends Equatable {
  final String? newPictureUrl;
  final ProcessStatus? pictureUpdateStatus;

  const ProfilePictureState({this.newPictureUrl, this.pictureUpdateStatus});

  ProfilePictureState copyWith(
      {String? newPictureUrl, ProcessStatus? pictureUpdateStatus}) {
    return ProfilePictureState(
        newPictureUrl: newPictureUrl ?? this.newPictureUrl,
        pictureUpdateStatus: pictureUpdateStatus ?? this.pictureUpdateStatus);
  }

  @override
  List<Object?> get props => [newPictureUrl, pictureUpdateStatus];
}

