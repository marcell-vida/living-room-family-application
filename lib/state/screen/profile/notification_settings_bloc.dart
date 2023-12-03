import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/util/utils.dart';

class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final DatabaseService _databaseService;
  final AuthenticationService _authenticationService;
  StreamSubscription? _userStreamSubscription;

  NotificationSettingsCubit(
      {required DatabaseService databaseService,
      required AuthenticationService authenticationService})
      : _databaseService = databaseService,
        _authenticationService = authenticationService,
        super(const NotificationSettingsState()) {
    _init();
  }

  void _init() {
    String uid = _authenticationService.currentUser?.uid ?? '';

    if (uid.isNotEmpty) {
      _userStreamSubscription =
          _databaseService.streamUserById(uid).listen((DatabaseUser? user) {
        emit(state.copyWith(user: user));
      });
    }
  }

  Future<void> toggleNotification() async {
    if (state.saveStatus == ProcessStatus.processing) return;
    emit(state.copyWith(saveStatus: ProcessStatus.processing));

    if (state.user != null) {
      bool currentValue = state.user?.generalNotification ?? false;

      await _databaseService.changeCurrentUserGeneralNotifications(
          authenticationService: _authenticationService,
          notifications: !currentValue,
          onSuccess: () async {
            emit(state.copyWith(saveStatus: ProcessStatus.successful));
            await Future.delayed(const Duration(milliseconds: 300));
            emit(state.copyWith(saveStatus: ProcessStatus.idle));
          },
          onError: () async {
            emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
            await Future.delayed(const Duration(milliseconds: 300));
            emit(state.copyWith(saveStatus: ProcessStatus.idle));
          });
    } else {
      emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
      return;
    }
  }

  @override
  Future<void> close() async {
    _userStreamSubscription?.cancel();
    super.close();
  }
}

class NotificationSettingsState extends Equatable {
  final DatabaseUser? user;
  final ProcessStatus? saveStatus;
  final bool updateFlag;

  const NotificationSettingsState(
      {this.user, this.saveStatus, this.updateFlag = true});

  NotificationSettingsState copyWith(
      {DatabaseUser? user, ProcessStatus? saveStatus}) {
    return NotificationSettingsState(
        user: user ?? this.user,
        saveStatus: saveStatus ?? this.saveStatus,
        updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [user, saveStatus, updateFlag];
}
