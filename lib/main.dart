// lib/main.dart

import 'package:cartie/core/utills/notification_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/theme/theme_provider.dart';
import 'package:cartie/core/utills/constants.dart';
import 'package:cartie/core/utills/db_manager.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/firebase_options.dart'; // ✅ Required for FirebaseOptions
import 'package:cartie/features/login_signup_flow/splash_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:cartie/features/providers/course_provider.dart';
import 'package:cartie/features/providers/dash_board_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.showNotification(message);
  debugPrint('🔕 Background message handled: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SharedPrefUtil.init();
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  DbManager().cache = await DbManager().initCacheUsingName(localCacheName);
  DbManager().pendingCache =
      await DbManager().initCacheUsingName(localPendingCacheName);

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  // 🔔 Foreground & terminated notification handling
  final RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => DashBoardProvider()),
      ],
      child: MyApp(message: initialMessage),
    ),
  );
}

class MyApp extends StatefulWidget {
  final RemoteMessage? message;
  const MyApp({super.key, this.message});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    NotificationService().messageInit(navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
