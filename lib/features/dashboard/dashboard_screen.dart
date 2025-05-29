import 'package:cartie/core/theme/theme_provider.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:cartie/features/dashboard/certificate_screen.dart';
import 'package:cartie/features/dashboard/home_page.dart';
import 'package:cartie/features/notification_screen.dart';
import 'package:provider/provider.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CertificateScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userProvider, child) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;

        return userProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: _currentIndex == 0
                    ? AppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        elevation: 0,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hey There!",
                              style: textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Let's get certified for cart",
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          IconButton(
                            onPressed: () async {
                              // await userProvider.getUserProfile();
                            },
                            icon: Icon(
                              Icons.notifications,
                              size: 28,
                              color: colorScheme.secondary,
                            ),
                          ),
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, child) {
                              return IconButton(
                                icon: Icon(
                                  themeProvider.themeMode == ThemeMode.dark
                                      ? Icons.light_mode
                                      : Icons.dark_mode,
                                  size: 28,
                                ),
                                color: colorScheme.primary,
                                onPressed: () {
                                  final newMode =
                                      themeProvider.themeMode == ThemeMode.dark
                                          ? ThemeMode.light
                                          : ThemeMode.dark;
                                  themeProvider.setThemeMode(newMode);
                                },
                              );
                            },
                          ),
                        ],
                      )
                    : null,
                body: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
                bottomNavigationBar: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: BottomNavigationBar(
                    backgroundColor: colorScheme.primary,
                    currentIndex: _currentIndex,
                    onTap: (index) => setState(() => _currentIndex = index),
                    selectedItemColor: colorScheme.onPrimary,
                    unselectedItemColor: colorScheme.onPrimary.withOpacity(0.6),
                    showSelectedLabels: false,
                    showUnselectedLabels: false,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home, size: 30),
                        label: "",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.description, size: 30),
                        label: "",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline, size: 30),
                        label: "",
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
