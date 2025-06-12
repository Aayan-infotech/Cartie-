import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/core/theme/theme_provider.dart';
import 'package:cartie/core/utills/constants.dart';
import 'package:cartie/core/utills/db_manager.dart';
import 'package:cartie/core/utills/shared_pref_util.dart';
import 'package:cartie/features/login_signup_flow/splash_screen.dart';
import 'package:cartie/features/login_signup_flow/welcome_screen.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:cartie/features/providers/course_provider.dart';
import 'package:cartie/features/providers/dash_board_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Shared Preferences
  await SharedPrefUtil.init();

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  // Initialize custom DbManager caches
  DbManager().cache = await DbManager().initCacheUsingName(localCacheName);
  DbManager().pendingCache =
  await DbManager().initCacheUsingName(localPendingCacheName);

  // Initialize ThemeProvider before runApp
  final themeProvider = ThemeProvider();
  await themeProvider.init();

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => DashBoardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode, // Default to system setting
      home: const SplashScreen(),
    );
  }
}
