import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:living_room/model/database/base/firestore_item.dart';
import 'package:living_room/model/database/families/family.dart';
//
// /// Bővítmény a [QuerySnapshot] osztálynak
// extension QuerySnapshotExtension on QuerySnapshot<Object?> {
//   Map<DocumentReference, Map<String, dynamic>>? data() {
//     try {
//       return {
//         for (var v in docs)
//           v.reference: (v.data() as Map).cast<String, dynamic>()};
//     } catch (e) {
//       return null;
//     }
//   }
// }
//
// /// típus definició
// typedef FirestoreItemMapFunction = FirestoreItem Function(
//     MapEntry<DocumentReference<Object?>, Map<String, dynamic>>);
//
// FirestoreItemMapFunction _mapFamily = (doc) => Family.fromSnapshot(doc);
//
// /// Visszaadja a [T] típus megfelelő map funkcióját
// FirestoreItemMapFunction? _firestoreItemMapFunction<T>() {
//   if (T == Family) {
//     return _mapFamily;
//   }
//   return null;
// }
//
// /// Visszaadja az alapértelemezett beállításokkal a [FirebaseFirestore]
// /// egyedét
// FirebaseFirestore get _firestoreInstance {
//   FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
//   /// az adatok lokális tárolása nem lesz engedályezve
//   firebaseFirestore.settings = const Settings(persistenceEnabled: false);
//   return firebaseFirestore;
// }
//
// /// Alapértelmezett kollekció referencia
// CollectionReference collection(String path) {
//   return _firestoreInstance.collection(path);
// }
//
// /// Visszaad egy folyamot, amire a kódon belül bárhol lehet figyelni
// ///
// /// A folyam [T] típusú elemekből álló [List] objektumot ad vissza.
// /// [T] típusnak [FirestoreItem] ősből kell származnia, az objektum
// /// elkészítésekor az elemek fromSnapshot metódusa lesz meghívva.
// Stream<List<T>?> streamCollection<T>(String path) {
//   return collection(path).snapshots().asyncMap((QuerySnapshot<Object?> event) {
//     return event
//         .data() /// kifejtése a QuerySnapshotExtension-ban található
//         ?.entries
//         .map((entry) => _firestoreItemMapFunction<T>()?.call(entry) as T)
//         .toList();
//   });
// }


// import 'package:collection/collection.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:living_room/extension/dart/context_extension.dart';
// import 'package:logger/logger.dart';
//
// /// azonosítás közben fellépő hibatípusok
// enum AuthException { userNotFound, unknown }
//
// /// Egy kiterjesztése az [AuthException] típusnak
// extension AuthExceptionExtension on AuthException {
//
//   /// Visszaadja a hibához tartozó lokalizált üzenetet
//   String getErrorMessage(BuildContext context) {
//     try {
//       /// nyelvi csomag
//       AppLocalizations appLocalizations = context.loc!;
//       switch (this) {
//         case AuthException.userNotFound:
//           return appLocalizations.signInExceptionUserNotFound;
//         default:
//           return appLocalizations.globalExceptionUnknownError;
//       }
//     } catch (e) {
//       /// nem elérhető a nyelvi csomag
//       return '';
//     }
//   }
// }
//
// /// A fájlban használt naplózó objektum
// Logger logger = Logger();
//
// /// Egy [Map] objektum, ami a [FirebaseAuth] által visszaadott nyers
// /// hibaüzenetekhez általam kezelhető [AuthException] típust rendel
// final Map<String, AuthException> rawSignInExceptions = {
//   "firebase_auth/INVALID_LOGIN_CREDENTIALS": AuthException.userNotFound,
// };
//
// /// Emaillel és jelszóval bejelentkeztető metódus.
// ///
// /// Hiba esetén az onError függvény kerül meghívásra a megfelelő hibatípussal.
// /// Siker esetén az onSuccess függvény kerül meghívásra.
// void signIn(
//     {required String email,
//     required String password,
//     Function(AuthException)? onError,
//     Function()? onSuccess}) {
//   try {
//     /// Firebase hívás
//     FirebaseAuth.instance
//         .signInWithEmailAndPassword(email: email, password: password)
//         .then(
//
//             /// ha lefutott az aszinkron hívás
//             (_) {
//       /// sikeres bejelentkezés
//       onSuccess?.call();
//     }, onError: (e) {
//       /// sikertelen bejelentkezés
//       if (e is FirebaseAuthException) {
//         /// Firebase által ismert hiba
//         /// a nyers hibaüzenet kulcsok közül megkeressük az egyezőt
//         var key = rawSignInExceptions.keys.firstWhereOrNull(
//             (element) => e.toString().contains(element) == true);
//
//         /// a kulcsnak megfelelő értékkel vagy egy ismeretlen hiba értékkel
//         /// meghívjuk az onError függvényt
//         onError?.call(key != null
//             ? rawSignInExceptions[key] ?? AuthException.unknown
//             : AuthException.unknown);
//       } else {
//         /// ismeretlen hiba
//         onError?.call(AuthException.unknown);
//       }
//     });
//   } catch (e) {
//     /// hibás működés, naplózzuk fejlesztés közben
//     logger.e("Outer exception: ${e.toString()}");
//   }
// }
