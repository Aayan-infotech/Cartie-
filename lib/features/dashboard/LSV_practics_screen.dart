import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartie/core/utills/branded_text_filed.dart';
import 'package:cartie/features/dashboard/info_screen.dart';
import 'package:cartie/features/providers/dash_board_provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:cartie/core/api_services/server_calls/dashboard_api.dart';
import 'package:cartie/core/models/lsv_model.dart';
import 'package:provider/provider.dart';

class LSVPracticesScreen extends StatefulWidget {
  const LSVPracticesScreen({Key? key}) : super(key: key);

  @override
  _LSVPracticesScreenState createState() => _LSVPracticesScreenState();
}

class _LSVPracticesScreenState extends State<LSVPracticesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<DashBoardProvider>(context, listen: false);
    //  if (provider.lsvInfo == null) {
    provider.fetchLSVData();
    // }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<DashBoardProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Scaffold(
            backgroundColor: colors.background,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: colors.background,
              elevation: 0,
            ),
            backgroundColor: colors.background,
            body: Center(child: Text(provider.error!)),
          );
        }

        final lsvInfo = provider.lsvInfo;
        if (lsvInfo == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: colors.background,
              elevation: 0,
            ),
            backgroundColor: colors.background,
            body: const Center(child: Text('No LSV data available')),
          );
        }

        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            elevation: 0,
            title: Text(
              'LSV practices',
              style: theme.textTheme.displayLarge,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: BrandedTextField(
                  //         controller: _searchController,
                  //         labelText: "Search",
                  //         isFilled: false,
                  //         prefix: Icon(Icons.search, color: colors.primary),
                  //         keyboardType: TextInputType.text,
                  //         backgroundColor: Colors.transparent,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 10),
                  //     Container(
                  //       decoration: BoxDecoration(
                  //         color: colors.primary,
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       padding: const EdgeInsets.all(12),
                  //       child: Icon(Icons.mic, color: colors.onPrimary),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildQuestionChip(
                          context,
                          label: 'What is LSV',
                          content: lsvInfo.questions.whatIsLSV,
                          colors: colors,
                        ),
                        const SizedBox(width: 10),
                        _buildQuestionChip(
                          context,
                          label: 'Importance',
                          content: lsvInfo.questions.importance,
                          colors: colors,
                        ),
                        const SizedBox(width: 10),
                        _buildQuestionChip(
                          context,
                          label: 'Safety',
                          content: lsvInfo.questions.safety,
                          colors: colors,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...lsvInfo.sections.map((section) {
                    final parts = section.description.split('\n');
                    return _buildInfoCard(
                      context,
                      title: section.title,
                      subtitle: parts.isNotEmpty ? parts[0] : '',
                      highlight: parts.length > 1 ? parts[1] : '',
                    );
                  }).toList(),
                  const SizedBox(height: 16),

                  const SizedBox(height: 12),
                  Text('Guidelines',
                      style: textTheme.bodyLarge?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...lsvInfo.guidelines
                      .map((guideline) =>
                          _buildGuidelineButton(context, guideline))
                      .toList(),
                  // _buildLinkButton(context, 'Handling & Maneuvering'),
                  // _buildLinkButton(context, 'Communication'),
                  // _buildLinkButton(context, 'Load Management'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuidelineButton(BuildContext context, LSVGuideline guideline) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        // Navigate to detail screen or handle tap
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (guideline.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: guideline.imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.error)),
                  ),
                ),
              ),

            // Text content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guideline.title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (guideline.description.isNotEmpty)
                    Text(
                      guideline.description,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: colors.onBackground.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionChip(
    BuildContext context, {
    required String label,
    required String content,
    required ColorScheme colors,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InfoScreen(
            title: label,
            content: content,
          ),
        ),
      ),
      child: Chip(
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
