import 'package:bloc/bloc.dart';
import 'package:living_room/extension/result/invalid_input_extension.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/state/screen/sign_up/sign_up_state.dart';
import 'package:living_room/util/utils.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthenticationService _authenticationService;
  final DatabaseService _databaseService;

  SignUpCubit(
      {required AuthenticationService authenticationService,
      required DatabaseService databaseService})
      : _authenticationService = authenticationService,
        _databaseService = databaseService,
        super(const SignUpState());

  bool? get isEmailValid => state.isEmailValid;

  bool? get isPasswordValid => state.isPasswordValid;

  bool? get isPasswordAgainValid => state.isPasswordAgainValid;

  void toggleObscurePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void toggleObscurePasswordAgain() {
    emit(state.copyWith(obscurePasswordAgain: !state.obscurePasswordAgain));
  }

  void modifyEmail(String newValue) {
    emit(state.copyWith(email: newValue, signUpStatus: ProcessStatus.idle));
  }

  void modifyPassword(String newValue) {
    emit(state.copyWith(password: newValue, signUpStatus: ProcessStatus.idle));
  }

  void modifyPasswordAgain(String newValue) {
    emit(state.copyWith(
        passwordAgain: newValue, signUpStatus: ProcessStatus.idle));
  }

  void validate() {
    /// email
    bool isEmailValid = Utils.isEmailFormatValid(state.email);
    InvalidInput? invalidEmailMessage;

    if (state.email.isEmpty) {
      invalidEmailMessage = InvalidInput.emptyInput;
    } else if (!isEmailValid) {
      invalidEmailMessage = InvalidInput.invalidEmail;
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
        isEmailValid: isEmailValid,
        invalidEmailMessage: invalidEmailMessage,
        isPasswordValid: isPasswordValid,
        invalidPasswordMessage: invalidPasswordMessage,
        isPasswordAgainValid: isPasswordAgainValid,
        invalidPasswordAgainMessage: invalidPasswordAgainMessage,
        signUpStatus: ProcessStatus.idle));
  }

  void signUpWithEmailAndPassword() async {
    if (state.isEmailValid &&
        state.isPasswordValid &&
        state.isPasswordAgainValid &&
        state.signUpStatus != ProcessStatus.processing) {
      emit(state.copyWith(signUpStatus: ProcessStatus.processing));
      _authenticationService.signUp(
          email: state.email,
          password: state.password,
          onError: (errorMessage) {
            emit(state.copyWith(
                signUpException: errorMessage,
                signUpStatus: ProcessStatus.unsuccessful));
          },
          onSuccess: (successMessage) async {
            await _databaseService.initializeCurrentUser(
                authenticationService: _authenticationService);

            emit(state.copyWith(
                successMessage: successMessage,
                signUpStatus: ProcessStatus.successful));
          });
    }
  }
}
