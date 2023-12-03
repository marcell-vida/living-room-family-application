import 'package:living_room/extension/result/auth_exception_extension.dart';
import 'package:living_room/extension/result/sign_up_exception_extension.dart';
import 'package:living_room/extension/result/success_message_extension.dart';
import 'package:living_room/extension/result/verify_email_exception_extension.dart';
import 'package:living_room/model/authentication/auth_user.dart';
import 'package:living_room/service/authentication/authentication_base.dart';
import 'package:living_room/service/authentication/firebase/firebase_authentication.dart';

class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._();
  static late AuthenticationBase _authenticationBase;

  AuthenticationService._();

  factory AuthenticationService({AuthenticationBase? authenticationBase}) {
    _authenticationBase = authenticationBase ?? AuthenticationImp();
    return _instance;
  }

  Stream<AuthUser?> get authStateChange => _authenticationBase.authStateChange;

  AuthUser? get currentUser => _authenticationBase.currentUser;

  void signIn(
          {required String email,
          required String password,
          Function(AuthException)? onError,
          Function()? onSuccess}) =>
      _authenticationBase.signIn(
          email: email,
          password: password,
          onError: onError,
          onSuccess: onSuccess);

  void signUp(
          {required String email,
          required String password,
          Function(SignUpException)? onError,
          Function(SuccessMessage)? onSuccess}) =>
      _authenticationBase.signUp(
          email: email,
          password: password,
          onError: onError,
          onSuccess: onSuccess);

  void signOut() => _authenticationBase.signOut();

  void changePassword(
          {required String pasword,
          required String newPassword,
          Function()? onError,
          Function(SuccessMessage)? onSuccess}) =>
      _authenticationBase.changePassword(
          currentPassword: pasword,
          newPassword: newPassword,
          onError: onError,
          onSuccess: onSuccess);

  void verifyEmail(
          {Function(VerifyEmailException)? onError,
          Function(SuccessMessage)? onSuccess}) =>
      _authenticationBase.verifyEmail(onError: onError, onSuccess: onSuccess);
}
