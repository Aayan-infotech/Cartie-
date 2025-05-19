import 'package:cartie/features/dashboard/info_screen.dart';
import 'package:flutter/material.dart';

class LSVPracticesScreen extends StatelessWidget {
  const LSVPracticesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onBackground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'LSV practices',
          style: textTheme.titleLarge?.copyWith(
            color: colors.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: colors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: TextStyle(color: colors.onBackground),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: colors.onBackground.withOpacity(0.7),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.mic, color: colors.onPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InfoScreen())),
                      child: _buildChip('what is LSV', colors)),
                  const SizedBox(width: 10),
                  GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InfoScreen())),
                      child: _buildChip('importance', colors)),
                  const SizedBox(width: 10),
                  GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InfoScreen())),
                      child: _buildChip('Safety', colors)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info Cards
            _buildInfoCard(
              context,
              title: 'Vehicle Inspection',
              subtitle:
                  'Regularly inspect brakes, tires, lights, and steering before use.',
              highlight: 'Ensure proper maintenance and repairs.',
            ),
            _buildInfoCard(
              context,
              title: 'Personal Safety Gear',
              subtitle: 'Wear helmets, gloves, and other protective equipment.',
              highlight: 'Ensure seatbelts are secured if applicable.',
            ),

            const SizedBox(height: 16),

            Text('Resources & Links',
                style: textTheme.bodyLarge?.copyWith(
                    color: colors.onBackground, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            _buildLinkButton(context, 'Handling & Maneuvering'),
            _buildLinkButton(context, 'Communication'),
            _buildLinkButton(context, 'Load Management'),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, ColorScheme colors) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_ios, size: 14),
        ],
      ),
      backgroundColor: colors.primary,
      shape: const StadiumBorder(),
      labelStyle: TextStyle(
        color: colors.onPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String highlight,
  }) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: textTheme.bodyLarge?.copyWith(
                        color: colors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                        color: colors.onBackground.withOpacity(0.7))),
                const SizedBox(height: 8),
                Text(highlight,
                    style: textTheme.bodyMedium?.copyWith(
                        color: colors.secondary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: colors.surfaceVariant,
            child: Icon(Icons.image, color: colors.onSurfaceVariant),
          )
        ],
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context, String title) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(title,
            style: textTheme.bodyLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            )),
        onTap: () {},
      ),
    );
  }
}
