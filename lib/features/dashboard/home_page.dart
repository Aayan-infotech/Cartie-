import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cartie/core/utills/dashboard_card.dart';
import 'package:cartie/features/dashboard/LSV_practics_screen.dart';
import 'package:cartie/features/dashboard/cart_rules_screen.dart';
import 'package:cartie/features/dashboard/certificate_screen.dart';
import 'package:cartie/features/dashboard/local_map_area.dart';
import 'package:cartie/features/video_player/assisment_screen.dart';
import 'package:cartie/features/video_player/training_details.dart';
import 'package:cartie/features/video_player/traning_video.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  PermissionStatus _locationPermissionStatus = PermissionStatus.denied;
  bool _isCheckingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    setState(() => _isCheckingPermission = true);

    final status = await Permission.location.status;
    setState(() {
      _locationPermissionStatus = status;
      _isCheckingPermission = false;
    });
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    setState(() => _locationPermissionStatus = status);

    if (status.isPermanentlyDenied) {
      _showPermanentDenialDialog();
    }
  }

  void _showPermanentDenialDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Location Access Required'),
        content: const Text(
          'You have permanently denied location permission. '
          'Please enable it from app settings to use all features of this app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCheckingPermission
          ? const Center(child: CircularProgressIndicator())
          : _locationPermissionStatus.isGranted
              ? _buildDashboard()
              : _buildPermissionDeniedCard(),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              final crossAxisCount = screenWidth > 600 ? 3 : 2;
              final aspectRatio = screenWidth > 600 ? 1.1 : 0.9;
              final spacing = screenWidth * 0.14;

              return Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: aspectRatio,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const FullScreenVideoScreen(
                            videoUrl:
                                'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                          );
                        }));
                      },
                      child: const DashboardCard(
                          icon: Icons.play_circle, label: "Watch Safety Video"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AssessmentScreen(
                              locationId: '',
                              sectionId: '',
                              sectionNumber: 0,
                            ),
                          ),
                        );
                      },
                      child: const DashboardCard(
                          icon: Icons.quiz, label: "   Attempt Test     "),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const CartingRulesScreen();
                        }));
                      },
                      child: const DashboardCard(
                          icon: Icons.list_alt,
                          label: "Rules and regulations for LSVs"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const LSVPracticesScreen();
                        }));
                      },
                      child: const DashboardCard(
                          icon: Icons.psychology,
                          label: "Good LSV practices for the area"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return TrainingMapScreen();
                        }));
                      },
                      child: const DashboardCard(
                          icon: Icons.map, label: "Map of local area"),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return CertificateScreen();
                        }));
                      },
                      child: const DashboardCard(
                          icon: Icons.verified, label: "All Certifications"),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Contact information at the bottom
        Container(
          padding: const EdgeInsets.all(16),
          child: const Text(
            'For any issues, contact: cartiesafe@gmail.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyInstructionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.lightBlue.shade400,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Safety First!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: '• Please ',
                      ),
                      TextSpan(
                        text: 'watch the safety video',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' carefully\n',
                      ),
                      TextSpan(
                        text: '• Then ',
                      ),
                      TextSpan(
                        text: 'complete the assessment',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: ' to proceed',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.safety_check,
              size: 28,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedCard() {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 80,
                color: _locationPermissionStatus.isPermanentlyDenied
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Location Access Required',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _locationPermissionStatus.isPermanentlyDenied
                    ? 'You have permanently denied location permission. This app requires location access to provide its full functionality.'
                    : 'This app needs access to your location to work properly. Please grant location permission to continue.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (_locationPermissionStatus.isPermanentlyDenied)
                ElevatedButton.icon(
                  onPressed: () => openAppSettings(),
                  icon: const Icon(Icons.settings),
                  label: const Text('Open App Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _requestLocationPermission,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Grant Location Permission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  if (_locationPermissionStatus.isPermanentlyDenied) {
                    openAppSettings();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                child: Text(
                  _locationPermissionStatus.isPermanentlyDenied
                      ? 'I\'ll enable it later'
                      : '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'For any issues, contact: carting@gmail.com',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
