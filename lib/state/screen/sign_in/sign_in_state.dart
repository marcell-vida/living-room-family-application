import 'package:equatable/equatable.dart';
import 'package:living_room/extension/result/auth_exception_extension.dart';
import 'package:living_room/extension/result/invalid_input_extension.dart';
import 'package:living_room/extension/result/success_message_extension.dart';
import 'package:living_room/util/utils.dart';

class SignInState extends Equatable {
  final String userName;
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool obscurePassword;
  final InvalidInput? invalidEmailMessage;
  final InvalidInput? invalidPasswordMessage;
  final ProcessStatus signInStatus;
  final AuthException? authException;
  final SuccessMessage? successMessage;

  const SignInState(
      {this.userName = '',
      this.email = '',
      this.password = '',
      this.isEmailValid = false,
      this.isPasswordValid = false,
      this.obscurePassword = true,
      this.invalidEmailMessage = InvalidInput.emptyInput,
      this.invalidPasswordMessage = InvalidInput.emptyInput,
      this.signInStatus = ProcessStatus.idle,
      this.authException,
      this.successMessage});

  SignInState copyWith(
      {String? userName,
      String? email,
      String? password,
      bool? isEmailValid,
      bool? isPasswordValid,
      bool? obscurePassword,
      InvalidInput? invalidEmailMessage,
      InvalidInput? invalidPasswordMessage,
      ProcessStatus? signInStatus,
      AuthException? authException,
      SuccessMessage? successMessage}) {
    return SignInState(
        userName: userName ?? this.userName,
        email: email ?? this.email,
        password: password ?? this.password,
        isEmailValid: isEmailValid ?? this.isEmailValid,
        isPasswordValid: isPasswordValid ?? this.isPasswordValid,
        obscurePassword: obscurePassword ?? this.obscurePassword,
        invalidEmailMessage: invalidEmailMessage ?? this.invalidEmailMessage,
        invalidPasswordMessage:
            invalidPasswordMessage ?? this.invalidPasswordMessage,
        signInStatus: signInStatus ?? this.signInStatus,
        authException: authException ?? this.authException,
        successMessage: successMessage ?? this.successMessage);
  }

  @override
  List<Object?> get props => [
        email,
        userName,
        password,
        isEmailValid,
        isPasswordValid,
        obscurePassword,
        invalidEmailMessage,
        invalidPasswordMessage,
        signInStatus,
        authException,
        successMessage
      ];
}
