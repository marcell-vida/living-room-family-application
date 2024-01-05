import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/extension/dart/navigator_state_extension.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/state/screen/app_base/app_base_state.dart';
import 'package:living_room/util/constants.dart';

/// This screen provides tha basic functions of the application.
///
/// If the user state changes, or a network error occurs, this screen handles it
/// by navigating to the correct screen. Because this screen is the parent of
/// every other one it will always have the sufficient resources.
abstract class AppBaseScreen extends StatelessWidget {
  const AppBaseScreen({super.key});

  @nonVirtual
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(listeners: [
      // receiving push notification from Firebase
      BlocListener<AppBaseCubit, AppBaseState>(
          listenWhen: (previous, current) =>
              previous.foregroundMessage != current.foregroundMessage,
          listener: (context, state) {
            context.hidePreviousShowNewSnackBar(
                state.foregroundMessage?.notification?.body ?? '',
                duration: const Duration(seconds: 10));
          }),
      // user signs in, -out, -up or other changes occur
      BlocListener<AppBaseCubit, AppBaseState>(
        listenWhen: (previous, current) =>
            previous.currentUserStatus != current.currentUserStatus,
        listener: (context, state) async {
          debugPrint(
              'BaseScreen: state.authenticationState == ${state.currentUserStatus}');
          debugPrint(
              'BaseScreen: state.internetConnectivityState == ${state.networkConnectionStatus}');

          if (state.currentUserStatus == null) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.loading);
          } else if (state.currentUserStatus ==
              CurrentUserStatus.signedInEmailNotVerified) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.verify);
          } else if (state.currentUserStatus == CurrentUserStatus.signedIn) {
            // navigate to home
            if (context.mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.home, (route) => false);
            }
          } else if (state.currentUserStatus == CurrentUserStatus.signedOut) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.signIn, (route) => false);
          } else if (state.currentUserStatus == CurrentUserStatus.userBanned) {
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.banned, (route) => false);
          } else {
            Navigator.of(context).pushNamed(AppRoutes.wrong);
          }
        },
      ),
      // network connection status changes
      BlocListener<AppBaseCubit, AppBaseState>(
        listenWhen: (previous, current) =>
            previous.networkConnectionStatus != current.networkConnectionStatus,
        listener: (context, state) {
          debugPrint(
              'BaseScreen: state.authenticationState == ${state.currentUserStatus}');
          debugPrint(
              'BaseScreen: state.internetConnectivityState == ${state.networkConnectionStatus}');

          if (state.networkConnectionStatus ==
              NetworkConnectionStatus.connectedNoInternet) {
            Navigator.of(context).pushNamedIfNotCurrent(AppRoutes.noConnection);
          } else if (state.networkConnectionStatus ==
              NetworkConnectionStatus.notConnected) {
            Navigator.of(context).pushNamedIfNotCurrent(AppRoutes.noConnection);
          }
        },
      ),
    ], child: body(context));
  }

  Widget body(BuildContext context);
}
