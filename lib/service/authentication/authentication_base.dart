import 'package:living_room/extension/result/auth_exception_extension.dart';
import 'package:living_room/extension/result/sign_up_exception_extension.dart';
import 'package:living_room/extension/result/success_message_extension.dart';
import 'package:living_room/extension/result/verify_email_exception_extension.dart';
import 'package:living_room/model/authentication/auth_user.dart';

abstract class AuthenticationBase {
  Stream<AuthUser?> get authStateChange;

  AuthUser? get currentUser;

  void signIn(
      {required String email,
      required String password,
      Function(AuthException)? onError,
      Function()? onSuccess});

  void signUp(
      {required String email,
      required String password,
      Function(SignUpException)? onError,
      Function(SuccessMessage)? onSuccess});

  void signOut();

  void changePassword(
      {required String newPassword,
      required String currentPassword,
      Function()? onError,
      Function(SuccessMessage)? onSuccess});

  void verifyEmail(
      {Function(VerifyEmailException)? onError,
      Function(SuccessMessage)? onSuccess});
}
