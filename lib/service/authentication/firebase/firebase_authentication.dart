import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:living_room/extension/result/auth_exception_extension.dart';
import 'package:living_room/extension/result/sign_up_exception_extension.dart';
import 'package:living_room/extension/result/success_message_extension.dart';
import 'package:living_room/extension/result/verify_email_exception_extension.dart';
import 'package:living_room/main.dart';
import 'package:living_room/model/authentication/auth_user.dart';
import 'package:living_room/service/authentication/authentication_base.dart';

class AuthenticationImp extends AuthenticationBase {
  final rawSignInExceptions = {
    "auth/invalid-email": AuthException.invalidEmail,
    "auth/user-disabled": AuthException.userDisabled,
    "auth/user-not-found": AuthException.userNotFound,
    "auth/wrong-password": AuthException.wrongPassword,
    "auth/too-many-requests": AuthException.tooManyRequests,
    "firebase_auth/INVALID_LOGIN_CREDENTIALS": AuthException.userNotFound,
    "firebase_auth/network-request-failed": AuthException.networkRequestFailed
  };

  final rawSignUpExceptions = {
    "auth/email-already-in-use": SignUpException.emailAlreadyInUse,
    "auth/invalid-email": SignUpException.invalidEmail,
    "auth/operation-not-allowed": SignUpException.operationNotAllowed,
    "auth/weak-password": SignUpException.weakPassword
  };

  final rawVerifyEmailExceptions = {
    "firebase_auth/too-many-requests": VerifyEmailException.tooManyRequests
  };

  static final AuthenticationImp _instance = AuthenticationImp._();

  AuthenticationImp._();

  factory AuthenticationImp() {
    return _instance;
  }

  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;

  @override
  Stream<AuthUser?> get authStateChange => _firebaseAuth
      .userChanges()
      .map((user) => user == null ? null : AuthUser.fromFirebase(user));

  @override
  AuthUser? get currentUser {
    var firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return AuthUser.fromFirebase(firebaseUser);
    }
    return null;
  }

  @override
  void signIn(
      {required String email,
      required String password,
      Function(AuthException)? onError,
      Function()? onSuccess}) {
    try {
      _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((_) => onSuccess?.call(), // onSuccess
              onError: (e) {
        log.e("Exception type: ${e.runtimeType}, message: ${e.toString()}");
        if (e is FirebaseAuthException) {
          var key = rawSignInExceptions.keys.firstWhereOrNull(
              (element) => e.toString().contains(element) == true);
          onError?.call(key != null
              ? rawSignInExceptions[key] ?? AuthException.unknown
              : AuthException.unknown);
        } else {
          onError?.call(AuthException.unknown);
        }
      });
    } catch (e) {
      log.e("Outer exception: ${e.toString()}");
    }
  }

  @override
  void signOut() => _firebaseAuth.signOut();

  @override
  void signUp(
      {required String email,
      required String password,
      Function(SignUpException)? onError,
      Function(SuccessMessage)? onSuccess}) {
    try {
      _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((_) {
        onSuccess?.call(SuccessMessage.signUpComplete);
      }, onError: (e) {
        debugPrint(
            "Exception type: ${e.runtimeType}, message: ${e.toString()}");
        if (e is FirebaseAuthException) {
          var key = rawSignUpExceptions.keys.firstWhereOrNull(
              (element) => e.toString().contains(element) == true);
          onError?.call(key != null
              ? rawSignUpExceptions[key] ?? SignUpException.unknown
              : SignUpException.unknown);
        } else {
          onError?.call(SignUpException.unknown);
        }
      });
    } catch (e) {
      debugPrint("Outer exception: ${e.toString()}");
    }
  }

  @override
  void verifyEmail(
      {Function(VerifyEmailException)? onError,
      Function(SuccessMessage)? onSuccess}) {
    try {
      if (!_firebaseAuth.currentUser!.emailVerified) {
        _firebaseAuth.currentUser!.sendEmailVerification().then((_) async {
          onSuccess?.call(SuccessMessage.verificationEmailSent);
          while (_firebaseAuth.currentUser?.emailVerified != true) {
            debugPrint(
                "Reloading user data, waiting for user email verification");
            await Future.delayed(const Duration(seconds: 4),
                () => FirebaseAuth.instance.currentUser?.reload());
          }
        }, onError: (e) {
          debugPrint(
              "Exception type: ${e.runtimeType}, message: ${e.toString()}");
          if (e is FirebaseAuthException) {
            var key = rawVerifyEmailExceptions.keys.firstWhereOrNull(
                (element) => e.toString().contains(element) == true);
            onError?.call(key != null
                ? rawVerifyEmailExceptions[key] ??
                    VerifyEmailException.emailNotSent
                : VerifyEmailException.emailNotSent);
          } else {
            onError?.call(VerifyEmailException.emailNotSent);
          }
        });
      }
    } catch (e) {
      debugPrint("Outer exception: ${e.toString()}");
    }
  }

  @override
  Future<void> changePassword(
      {required String currentPassword,
      required String newPassword,
      Function()? onError,
      Function(SuccessMessage)? onSuccess}) async {
    User? user = _firebaseAuth.currentUser;

    if (user == null) {
      onError?.call();
      return;
    }

    _firebaseAuth
        .signInWithEmailAndPassword(
            email: user.email ?? '', password: currentPassword)
        .then((value) {
      _firebaseAuth.currentUser?.updatePassword(newPassword).then(
        (value) => onSuccess?.call(SuccessMessage.passwordChangeComplete),
        onError: (error) {
          log.d('Change password error: ${error.toString()}');
          onError?.call();
        },
      );
    }, onError: (_) {
      onError?.call();
    });
  }
}
