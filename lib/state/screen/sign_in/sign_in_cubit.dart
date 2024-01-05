import 'package:bloc/bloc.dart';
import 'package:living_room/extension/result/invalid_input_extension.dart';
import 'package:living_room/model/authentication/auth_user.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/state/screen/sign_in/sign_in_state.dart';
import 'package:living_room/util/utils.dart';

class SignInCubit extends Cubit<SignInState> {
  final AuthenticationService _authenticationService;

  SignInCubit(this._authenticationService) : super(const SignInState());

  bool? get isEmailValid => state.isEmailValid;

  bool? get isPasswordValid => state.isPasswordValid;

  AuthUser? get currentUser {
    return _authenticationService.currentUser;
  }

  void toggleObscurePassword() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void modifyEmail(String newValue) {
    emit(state.copyWith(email: newValue, signInStatus: ProcessStatus.idle));
  }

  void modifyPassword(String newValue) {
    emit(state.copyWith(password: newValue, signInStatus: ProcessStatus.idle));
  }

  void validate() {
    bool isEmailValid = Utils.isEmailFormatValid(state.email);
    InvalidInput? invalidEmailInput;

    if (state.email.isEmpty) {
      invalidEmailInput = InvalidInput.emptyInput;
    } else if (!isEmailValid) {
      invalidEmailInput = InvalidInput.invalidEmail;
    }

    bool isPasswordValid = Utils.isPasswordFormatValid(state.password);
    InvalidInput? invalidPasswordInput;

    if (state.password.isEmpty) {
      invalidPasswordInput = InvalidInput.emptyInput;
    } else if (!isPasswordValid) {
      invalidPasswordInput = InvalidInput.invalidPassword;
    }

    emit(state.copyWith(
        isEmailValid: isEmailValid,
        invalidEmailMessage: invalidEmailInput,
        isPasswordValid: isPasswordValid,
        invalidPasswordMessage: invalidPasswordInput,
        signInStatus: ProcessStatus.idle));
  }

  void signInWithEmailAndPassword() async {
    if (state.isEmailValid &&
        state.isPasswordValid &&
        state.signInStatus != ProcessStatus.processing) {
      emit(state.copyWith(signInStatus: ProcessStatus.processing));

      _authenticationService.signIn(
          email: state.email,
          password: state.password,
          onError: (errorMessage) {
            emit(state.copyWith(
                authException: errorMessage,
                signInStatus: ProcessStatus.unsuccessful));
          },
          onSuccess: () {
            emit(state.copyWith(signInStatus: ProcessStatus.successful));
          });
    }
  }
}
