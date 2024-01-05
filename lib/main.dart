import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:living_room/extension/dart/context_extension.dart';
import 'package:living_room/service/authentication/authentication_service.dart';
import 'package:living_room/service/database/database_service.dart';
import 'package:living_room/service/messaging/messaging_service.dart';
import 'package:living_room/service/storage/storage_service.dart';
import 'package:living_room/state/app/navigator_bar_bloc.dart';
import 'package:living_room/state/screen/app_base/app_base_cubit.dart';
import 'package:living_room/util/constants.dart';
import 'package:living_room/util/navigator.dart';
import 'package:logger/logger.dart';

import 'firebase_options.dart';

/// package to log general events
Logger log = Logger(
    printer: PrettyPrinter(
        methodCount: 5,
        errorMethodCount: 8,
        lineLength: 40,
        colors: true,
        printEmojis: true,
        printTime: true));

String? appOpenedByNotificationKey;

void _handleNotification(String? id) async {
  appOpenedByNotificationKey = id;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await MessagingService().initNotifications(onClicked: _handleNotification);
  RemoteMessage? initialMessage = await MessagingService().getInitialMessage();
  if (initialMessage != null) {
    _handleNotification(initialMessage.data['id']);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthenticationService>(
            create: (_) => AuthenticationService()),
        RepositoryProvider<DatabaseService>(create: (_) => DatabaseService()),
        RepositoryProvider<StorageService>(create: (_) => StorageService()),
        RepositoryProvider<MessagingService>(create: (_) => MessagingService())
      ],
      child: Builder(builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AppBaseCubit>(
                create: (context) => AppBaseCubit(
                    authenticationService: context.services.authentication,
                    databaseService: context.services.database,
                    messagingService: context.services.messaging)),
            BlocProvider<NavigatorBarCubit>(
                create: (context) => NavigatorBarCubit()),
          ],
          child: Builder(builder: (context) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateRoute: RouteGenerator.generateRoute,
              initialRoute: AppRoutes.loading,
              title: AppLocalizations.of(context)?.appName ?? '',
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('en'), Locale('hu')],
              theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
            );
          }),
        );
      }),
    );
  }
}
