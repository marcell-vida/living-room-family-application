import 'package:flutter/material.dart';
import 'package:living_room/screen/authentication/sign_in_screen.dart';
import 'package:living_room/screen/authentication/sign_up_screen.dart';
import 'package:living_room/screen/authentication/verify_email_screen.dart';
import 'package:living_room/screen/living_room/living_room_main_screen.dart';
import 'package:living_room/screen/util/banned_screen.dart';
import 'package:living_room/screen/util/loading_screen.dart';
import 'package:living_room/screen/util/no_connection_screen.dart';
import 'package:living_room/screen/util/wrong_route_screen.dart';
import 'package:living_room/util/constants.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    final args = routeSettings.arguments;

    switch (routeSettings.name) {
      case AppRoutes.signIn:
        return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.signIn),
            builder: (_) => SignInScreen());
      case AppRoutes.signUp:
        return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.signUp),
            builder: (_) => SignUpScreen());
      case AppRoutes.verify:
        return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.verify),
            builder: (_) => const VerifyEmailScreen());
      case AppRoutes.home:
        return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.home),
            builder: (_) => const LivingRoomMainScreen());
      case AppRoutes.noConnection:
        return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.noConnection),
            builder: (_) => const NoConnectionScreen());
      case AppRoutes.loading:
        return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.loading),
            builder: (_) => const LoadingScreen());
      case AppRoutes.banned:
        return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.banned),
            builder: (_) => const BannedScreen());
      default:
        return MaterialPageRoute(
            settings: const RouteSettings(name: AppRoutes.wrong),
            builder: (_) => const WrongRouteScreen());
    }
  }
}
