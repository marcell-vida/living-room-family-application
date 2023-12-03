import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/result/invalid_input_extension.dart';
import 'package:living_room/model/database/users/database_user.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/util/utils.dart';

class PasswordSettingsCubit extends Cubit<PasswordSettingsState> {
  final AuthenticationService _authenticationService;
  StreamSubscription? _userStreamSubscription;

  PasswordSettingsCubit({required AuthenticationService authenticationService})
      : _authenticationService = authenticationService,
        super(const PasswordSettingsState());

  void modifyOldPassword(String? newValue) {
    emit(state.copyWith(oldPassword: newValue));
  }

  void modifyPassword(String? newValue) {
    emit(state.copyWith(password: newValue));
  }

  void modifyPasswordAgain(String? newValue) {
    emit(state.copyWith(passwordAgain: newValue));
  }

  void validate() {
    /// old password
    bool isOldPasswordValid = Utils.isPasswordFormatValid(state.oldPassword);
    InvalidInput? invalidOldPasswordMessage;

    if (state.oldPassword.isEmpty) {
      invalidOldPasswordMessage = InvalidInput.emptyInput;
    } else if (!isOldPasswordValid) {
      invalidOldPasswordMessage = InvalidInput.invalidPassword;
    }

    /// password
    bool isPasswordValid = Utils.isPasswordFormatValid(state.password);
    InvalidInput? invalidPasswordMessage;

    if (state.password.isEmpty) {
      invalidPasswordMessage = InvalidInput.emptyInput;
    } else if (!isPasswordValid) {
      invalidPasswordMessage = InvalidInput.invalidPassword;
    }

    /// password again
    bool isPasswordAgainValid =
        Utils.isPasswordFormatValid(state.passwordAgain);
    InvalidInput? invalidPasswordAgainMessage =
        state.invalidPasswordAgainMessage;

    if (state.passwordAgain.isEmpty) {
      invalidPasswordAgainMessage = InvalidInput.emptyInput;
    } else if (state.password != state.passwordAgain) {
      isPasswordAgainValid = false;
      invalidPasswordAgainMessage = InvalidInput.passwordsNotMatch;
    } else if (!isPasswordAgainValid) {
      invalidPasswordAgainMessage = InvalidInput.invalidPassword;
    }

    emit(state.copyWith(
        isOldPasswordValid: isOldPasswordValid,
        invalidOldPasswordMessage: invalidOldPasswordMessage,
        isPasswordValid: isPasswordValid,
        invalidPasswordMessage: invalidPasswordMessage,
        isPasswordAgainValid: isPasswordAgainValid,
        invalidPasswordAgainMessage: invalidPasswordAgainMessage));
  }

  void setPassword() {
    if (state.saveStatus == ProcessStatus.processing) return;

    emit(state.copyWith(saveStatus: ProcessStatus.processing));

    if (state.isPasswordValid &&
        state.isPasswordAgainValid &&
        state.isOldPasswordValid) {
      _authenticationService.changePassword(
          pasword: state.oldPassword,
          newPassword: state.password,
          onSuccess: (_) {
            emit(state.copyWith(saveStatus: ProcessStatus.successful));
          },
          onError: () {
            emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
          });
    } else {
      emit(state.copyWith(saveStatus: ProcessStatus.unsuccessful));
    }
  }

  @override
  Future<void> close() async {
    _userStreamSubscription?.cancel();
    super.close();
  }
}

class PasswordSettingsState extends Equatable {
  final DatabaseUser? user;
  final ProcessStatus? saveStatus;
  final String oldPassword;
  final String password;
  final String passwordAgain;
  final InvalidInput? invalidPasswordMessage;
  final InvalidInput? invalidPasswordAgainMessage;
  final InvalidInput? invalidOldPasswordMessage;
  final bool isPasswordValid;
  final bool isPasswordAgainValid;
  final bool isOldPasswordValid;
  final bool updateFlag;

  const PasswordSettingsState(
      {this.user,
      this.saveStatus,
      this.oldPassword = '',
      this.password = '',
      this.passwordAgain = '',
      this.invalidPasswordMessage,
      this.invalidPasswordAgainMessage,
      this.invalidOldPasswordMessage,
      this.isPasswordValid = false,
      this.isPasswordAgainValid = false,
      this.isOldPasswordValid = false,
      this.updateFlag = true});

  PasswordSettingsState copyWith(
      {DatabaseUser? user,
      ProcessStatus? saveStatus,
      String? password,
      String? passwordAgain,
      String? oldPassword,
      InvalidInput? invalidPasswordMessage,
      InvalidInput? invalidPasswordAgainMessage,
      InvalidInput? invalidOldPasswordMessage,
      bool? isPasswordValid,
      bool? isPasswordAgainValid,
      bool? isOldPasswordValid}) {
    return PasswordSettingsState(
        user: user ?? this.user,
        saveStatus: saveStatus ?? this.saveStatus,
        password: password ?? this.password,
        passwordAgain: passwordAgain ?? this.passwordAgain,
        oldPassword: oldPassword ?? this.oldPassword,
        invalidPasswordMessage:
            invalidPasswordMessage ?? this.invalidPasswordMessage,
        invalidPasswordAgainMessage:
            invalidPasswordAgainMessage ?? this.invalidPasswordAgainMessage,
        invalidOldPasswordMessage:
            invalidOldPasswordMessage ?? this.invalidOldPasswordMessage,
        isPasswordValid: isPasswordValid ?? this.isPasswordValid,
        isPasswordAgainValid: isPasswordAgainValid ?? this.isPasswordAgainValid,
        isOldPasswordValid: isOldPasswordValid ?? this.isOldPasswordValid,
        updateFlag: !updateFlag);
  }

  @override
  List<Object?> get props => [
        user,
        saveStatus,
        password,
        passwordAgain,
        oldPassword,
        updateFlag,
        invalidPasswordMessage,
        invalidPasswordAgainMessage,
        invalidOldPasswordMessage,
        isPasswordValid,
        isPasswordAgainValid,
        isOldPasswordValid
      ];
}
