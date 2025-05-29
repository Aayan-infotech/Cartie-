import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String content;
  
  const InfoScreen({
    super.key,
    required this.title,
    required this.content,
  });

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
          title, // Dynamic title
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
                title, // Dynamic heading
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onBackground,
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// Subheading (kept static as per original design)
            Text(
              "Key Information",
              style: textTheme.bodyLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// Info Cards (kept static as per original UI)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildInfoCard("Priority", "High", colors),
                buildInfoCard("Category", "Safety", colors),
                buildInfoCard("Updated", "2024", colors),
              ],
            ),

            const SizedBox(height: 24),

            /// About Section with dynamic content
            Text(
              "Detailed Information",
              style: textTheme.bodyLarge?.copyWith(
                color: colors.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content, // Dynamic content
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

  // Kept unchanged from original implementation
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