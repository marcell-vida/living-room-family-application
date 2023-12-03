import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:living_room/model/authentication/auth_user.dart';
import 'package:living_room/model/database/users/database_user.dart';

enum NetworkConnectionStatus { notConnected, connected, connectedNoInternet }

enum CurrentUserStatus {
  userBanned,
  signedOut,
  signedIn,
  signedInEmailNotVerified
}

enum ConnectionFetchStatus { initial, processing }

class AppBaseState extends Equatable {
  final AuthUser? currentAuthUser;
  final DatabaseUser? currentDbUser;
  final CurrentUserStatus? currentUserStatus;
  final NetworkConnectionStatus? networkConnectionStatus;
  final ConnectionFetchStatus connectionFetchStatus;
  final RemoteMessage? foregroundMessage;
  final String? fcmToken;

  const AppBaseState(
      {this.currentAuthUser,
      this.currentDbUser,
      this.currentUserStatus,
      this.networkConnectionStatus,
      this.connectionFetchStatus = ConnectionFetchStatus.initial,
      this.foregroundMessage,
      this.fcmToken});

  AppBaseState copyWith(
      {bool? clearUser,
      AuthUser? currentAuthUser,
      DatabaseUser? currentDbUser,
      CurrentUserStatus? currentUserStatus,
      NetworkConnectionStatus? networkConnectionStatus,
      ConnectionFetchStatus? connectionFetchStatus,
      RemoteMessage? foregroundMessage,
      String? fcmToken}) {
    return AppBaseState(
        currentAuthUser: clearUser == true
            ? null
            : (currentAuthUser ?? this.currentAuthUser),
        currentDbUser:
            clearUser == true ? null : (currentDbUser ?? this.currentDbUser),
        currentUserStatus: currentUserStatus ?? this.currentUserStatus,
        networkConnectionStatus:
            networkConnectionStatus ?? this.networkConnectionStatus,
        connectionFetchStatus:
            connectionFetchStatus ?? this.connectionFetchStatus,
        foregroundMessage: foregroundMessage ?? this.foregroundMessage,
        fcmToken: fcmToken ?? this.fcmToken);
  }

  @override
  List<Object?> get props => [
        currentAuthUser,
        currentDbUser,
        currentUserStatus,
        networkConnectionStatus,
        connectionFetchStatus,
        foregroundMessage,
        fcmToken,
      ];
}
