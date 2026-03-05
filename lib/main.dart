import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/core/utils/app_router.dart';
import 'package:reelify/firebase_options.dart';
import 'package:reelify/services/notification_service.dart';
import 'package:reelify/services/offline/sqlite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize SQLite
  await SqliteService.instance.database;

  // Initialize Notifications
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: ReelifyApp(),
    ),
  );
}

class ReelifyApp extends ConsumerWidget {
  const ReelifyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'RAY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('ta'),
        Locale('te'),
      ],
    );
  }
}
