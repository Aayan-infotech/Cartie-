import 'package:cartie/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;
        final cardHeight = cardWidth * 1.2; // 1:1.2 aspect ratio
        final iconSize = cardWidth * 0.3;
        final fontSize = cardWidth * 0.08;
        final padding = cardWidth * 0.05;
        final theme = Theme.of(context);
        final colors = theme.colorScheme;
        final textTheme = theme.textTheme;
        final provider = Provider.of<ThemeProvider>(context, listen: false);

        return Container(
          //color: Colors.yellow,
          child: Stack(
            children: [
              // Background
              Positioned(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: cardHeight * 0.6,
                    decoration: BoxDecoration(
                      color: provider.themeMode == ThemeMode.dark
                          ? colors.primary
                          : colors.primary.withOpacity(.3),
                      borderRadius: BorderRadius.circular(cardWidth * 0.1),
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon Container
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        color: provider.themeMode == ThemeMode.dark
                            ? Colors.white
                            : Colors.red,
                        borderRadius: BorderRadius.circular(cardWidth * 0.08),
                      ),
                      child: Icon(
                        icon,
                        size: iconSize,
                        color: provider.themeMode == ThemeMode.dark
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 70,
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        color: provider.themeMode == ThemeMode.dark
                            ? Colors.white
                            : Colors.red,
                        borderRadius: BorderRadius.circular(cardWidth * 0.08),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                            color: provider.themeMode == ThemeMode.dark
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
