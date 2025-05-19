import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.onBackground),
        title: Text(
          "Lorem Ipsum",
          style: textTheme.titleLarge?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Centered heading
            Center(
              child: Text(
                "Lorem",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onBackground,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Subheading
            Text(
              "Lorem Ipsum",
              style: textTheme.bodyLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// Info Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildInfoCard("Lorem", "10", colors),
                buildInfoCard("Lorem", "30", colors),
                buildInfoCard("Lorem", "32", colors),
              ],
            ),

            const SizedBox(height: 24),

            /// About Section
            Text(
              "About",
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This article provides principles and steps for creating a realistic and achievable plan, including clarifying goals, breaking down big goals, creating a specific plan, establishing time management skills, setting up feedback mechanisms, and maintaining perseverance and discipline.",
              style: textTheme.bodyMedium?.copyWith(
                color: colors.onBackground.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard(String title, String value, ColorScheme colors) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: colors.onPrimary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
