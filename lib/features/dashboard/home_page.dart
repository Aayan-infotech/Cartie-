import 'package:cartie/core/utills/dashboard_card.dart';
import 'package:cartie/features/dashboard/LSV_practics_screen.dart';
import 'package:cartie/features/dashboard/cart_rules_screen.dart';
import 'package:cartie/features/dashboard/certificate_screen.dart';
import 'package:cartie/features/dashboard/local_map_area.dart';
import 'package:cartie/features/providers/auth_provider.dart';
import 'package:cartie/features/video_player/training_details.dart';
import 'package:cartie/features/video_player/traning_video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
 

  @override
  void initState() {
    // TODO: implement initState
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   asyncInit();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Responsive grid configuration
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
                      return FullScreenVideoScreen(
                        videoUrl:
                            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                      );
                    }));
                  },
                  child: const DashboardCard(
                      icon: Icons.play_circle, label: "Watch Safety Video")),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return TrainingDetailScreen();
                    }));
                  },
                  child: const DashboardCard(
                      icon: Icons.quiz, label: "   Attempt Test     ")),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return CartingRulesScreen();
                  }));
                },
                child: DashboardCard(
                    icon: Icons.list_alt,
                    label: "Rules and regulations for LSVs"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return LSVPracticesScreen();
                  }));
                },
                child: DashboardCard(
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
                  child: DashboardCard(
                      icon: Icons.map, label: "Map of local area")),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return CertificateScreen();
                    }));
                  },
                  child: DashboardCard(
                      icon: Icons.verified, label: "All Certifications")),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridItem(
      BuildContext context, IconData icon, String label, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: _responsiveIconSize(context)),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: _responsiveTextSize(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _responsiveIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 600 ? 40 : 32;
  }

  double _responsiveTextSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 600 ? 18 : 14;
  }
}
