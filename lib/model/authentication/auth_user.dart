import 'package:firebase_auth/firebase_auth.dart';

class AuthUser {
  String? uid;
  String? email;
  String? displayName;
  String? photoURL;
  bool? isEmailVerified;
  DateTime? creationTime;

  AuthUser(
      {this.email,
      this.displayName,
      this.photoURL,
      this.isEmailVerified,
      this.uid})
      : creationTime = DateTime.now();

  AuthUser.fromFirebase(User user) {
    email = user.email;
    displayName = user.displayName;
    isEmailVerified = user.emailVerified;
    photoURL = user.photoURL;
    uid = user.uid;
    creationTime = user.metadata.creationTime?.toLocal();
  }

  bool get isNewlyRegistered => creationTime != null
      ? DateTime.now().difference(creationTime!.toLocal()) <
          const Duration(milliseconds: 2000)
      : false;
}
