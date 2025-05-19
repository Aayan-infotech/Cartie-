import 'package:cartie/features/carting_lesson.dart';
import 'package:cartie/features/dashboard/info_screen.dart';
import 'package:cartie/features/helmet_screen.dart';
import 'package:cartie/features/sefty_article.dart';
import 'package:flutter/material.dart';

class CartingRulesScreen extends StatelessWidget {
  const CartingRulesScreen({super.key});

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
        title:
            Text("Carting Rules", style: TextStyle(color: colors.onBackground)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              const SizedBox(height: 20),
              _buildTabs(context),
              const SizedBox(height: 20),
              _buildRulesList(context),
              const SizedBox(height: 30),
              _buildImportantSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.primary),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: colors.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: colors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.mic, color: colors.onPrimary),
        ),
      ],
    );
  }

  Widget _buildTabs(BuildContext context) {
    return Row(
      children: [
        _buildTab("Carting Rule", context),
        const SizedBox(width: 10),
        _buildTab("Tips", context),
        const SizedBox(width: 10),
        _buildTab("Safety", context),
      ],
    );
  }

  Widget _buildTab(String title, BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const InfoScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            Text(title, style: TextStyle(color: colors.onPrimary)),
            const SizedBox(width: 5),
            Icon(Icons.arrow_forward, color: colors.onPrimary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesList(BuildContext context) {
    return Column(
      children: [
        _buildRuleCard(context),
        const SizedBox(height: 12),
        _buildRuleCard(context),
      ],
    );
  }

  Widget _buildRuleCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
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
                Text("Speed Limit",
                    style: TextStyle(
                        color: colors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("Maximum speed of 25 m",
                    style: TextStyle(color: Colors.greenAccent)),
                const SizedBox(height: 4),
                Text("Category: Speed",
                    style: TextStyle(color: colors.primary)),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white24, // optional: can be theme adjusted
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Important",
            style: textTheme.bodyLarge?.copyWith(
              color: colors.onBackground,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        const SizedBox(height: 16),
        _buildImportantItem(Icons.sports_motorsports, "Try a helmet", context,
            const HelmetScreen()),
        const SizedBox(height: 12),
        _buildImportantItem(Icons.sports_soccer, "Read a safety article",
            context, const SafetyArticle()),
        const SizedBox(height: 12),
        _buildImportantItem(Icons.calendar_month, "Take a carting lesson",
            context, const CartingLesson()),
      ],
    );
  }

  Widget _buildImportantItem(
      IconData icon, String title, BuildContext context, Widget destination) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => destination));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.greenAccent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.greenAccent),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(
                    color: Colors.greenAccent, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
