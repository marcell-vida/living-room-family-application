import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/util/utils.dart';

class ProfileNameCubit extends Cubit<ProfileNameState> {
  final DatabaseService _databaseService;
  final AuthenticationService _authenticationService;

  ProfileNameCubit(
      {required DatabaseService databaseService,
      required AuthenticationService authenticationService})
      : _databaseService = databaseService,
        _authenticationService = authenticationService,
        super(const ProfileNameState());

  void modifyNewDisplayName(String changeTo) {
    emit(state.copyWith(newName: changeTo));
  }

  Future<void> uploadDisplayName() async {
    emit(state.copyWith(nameUpdateStatus: ProcessStatus.processing));
    if (state.newName != null) {
      await _databaseService.changeCurrentUserDisplayName(
          authenticationService: _authenticationService,
          displayName: state.newName!,
          onSuccess: () =>
              emit(state.copyWith(nameUpdateStatus: ProcessStatus.successful)),
          onError: () => emit(
              state.copyWith(nameUpdateStatus: ProcessStatus.unsuccessful)));
    }
    emit(state.copyWith(nameUpdateStatus: ProcessStatus.idle));
  }
}

class ProfileNameState extends Equatable {
  final String? newName;
  final ProcessStatus? nameUpdateStatus;

  const ProfileNameState({this.newName, this.nameUpdateStatus});

  ProfileNameState copyWith(
      {String? newName, ProcessStatus? nameUpdateStatus}) {
    return ProfileNameState(
      newName: newName ?? this.newName,
      nameUpdateStatus: nameUpdateStatus ?? this.nameUpdateStatus,
    );
  }

  @override
  List<Object?> get props => [newName, nameUpdateStatus];
}
