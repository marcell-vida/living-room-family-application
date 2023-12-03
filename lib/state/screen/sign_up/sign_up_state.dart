import 'package:equatable/equatable.dart';
import 'package:living_room/extension/result/invalid_input_extension.dart';
import 'package:living_room/extension/result/sign_up_exception_extension.dart';
import 'package:living_room/extension/result/success_message_extension.dart';
import 'package:living_room/util/utils.dart';

class SignUpState extends Equatable {
  final String userName;
  final String email;
  final String password;
  final String passwordAgain;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isPasswordAgainValid;
  final bool obscurePassword;
  final bool obscurePasswordAgain;
  final InvalidInput? invalidEmailMessage;
  final InvalidInput? invalidPasswordMessage;
  final InvalidInput? invalidPasswordAgainMessage;
  final ProcessStatus signUpStatus;
  final SignUpException? signUpException;
  final SuccessMessage? successMessage;

  const SignUpState(
      {this.userName = '',
      this.email = '',
      this.password = '',
      this.passwordAgain = '',
      this.isEmailValid = false,
      this.isPasswordValid = false,
      this.isPasswordAgainValid = false,
      this.obscurePassword = true,
      this.obscurePasswordAgain = true,
      this.invalidEmailMessage = InvalidInput.emptyInput,
      this.invalidPasswordMessage = InvalidInput.emptyInput,
      this.invalidPasswordAgainMessage = InvalidInput.emptyInput,
      this.signUpStatus = ProcessStatus.idle,
      this.signUpException,
      this.successMessage});

  SignUpState copyWith(
      {String? userName,
      String? email,
      String? password,
      String? passwordAgain,
      bool? isEmailValid,
      bool? isPasswordValid,
      bool? isPasswordAgainValid,
      bool? obscurePassword,
      bool? obscurePasswordAgain,
      InvalidInput? invalidEmailMessage,
      InvalidInput? invalidPasswordMessage,
      InvalidInput? invalidPasswordAgainMessage,
      ProcessStatus? signUpStatus,
      SignUpException? signUpException,
      SuccessMessage? successMessage}) {
    return SignUpState(
        userName: userName ?? this.userName,
        email: email ?? this.email,
        password: password ?? this.password,
        passwordAgain: passwordAgain ?? this.passwordAgain,
        isEmailValid: isEmailValid ?? this.isEmailValid,
        isPasswordValid: isPasswordValid ?? this.isPasswordValid,
        obscurePassword: obscurePassword ?? this.obscurePassword,
        obscurePasswordAgain: obscurePasswordAgain ?? this.obscurePasswordAgain,
        isPasswordAgainValid: isPasswordAgainValid ?? this.isPasswordAgainValid,
        invalidEmailMessage: invalidEmailMessage ?? this.invalidEmailMessage,
        invalidPasswordMessage:
            invalidPasswordMessage ?? this.invalidPasswordMessage,
        invalidPasswordAgainMessage:
            invalidPasswordAgainMessage ?? this.invalidPasswordAgainMessage,
        signUpStatus: signUpStatus ?? this.signUpStatus,
        signUpException: signUpException ?? this.signUpException,
        successMessage: successMessage ?? this.successMessage);
  }

  @override
  List<Object?> get props => [
        email,
        userName,
        password,
        passwordAgain,
        isEmailValid,
        isPasswordValid,
        isPasswordAgainValid,
        obscurePassword,
        obscurePasswordAgain,
        invalidEmailMessage,
        invalidPasswordMessage,
        invalidPasswordAgainMessage,
        signUpStatus,
        signUpException,
        successMessage
      ];
}
