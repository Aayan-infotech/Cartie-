import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartie/core/models/lsv_model.dart';
import 'package:cartie/core/models/carting_rules_model.dart';
import 'package:cartie/features/providers/dash_board_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';

class CartingRulesScreen extends StatefulWidget {
  const CartingRulesScreen({super.key});

  @override
  State<CartingRulesScreen> createState() => _CartingRulesScreenState();
}

class _CartingRulesScreenState extends State<CartingRulesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DashBoardProvider>(context, listen: false);
      provider.fetchCartingRules();
    });
  }

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
          "Carting Rules",
          style: theme.textTheme.displayLarge,
        ),
        elevation: 0,
      ),
      body: Consumer<DashBoardProvider>(
        builder: (context, provider, _) {
          if (provider.isCartingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.cartingError != null) {
            return Center(child: Text(provider.cartingError!));
          }

          if (provider.cartingRules == null) {
            return const Center(child: Text('No carting rules found'));
          }

          final cartingRules = provider.cartingRules!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTabs(provider, cartingRules.questions),
                  const SizedBox(height: 20),
                  _buildQuestionContent(
                      cartingRules.questions, provider.selectedQuestionTab),
                  const SizedBox(height: 20),
                  _buildRulesList(cartingRules.sections),
                  const SizedBox(height: 30),
                  Text('Guidelines',
                      style: textTheme.bodyLarge?.copyWith(
                          color: colors.onBackground,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...cartingRules.guidelines
                      .map((guideline) =>
                          _buildGuidelineButton(context, guideline))
                      .toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGuidelineButton(BuildContext context, LSVGuideline guideline) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    Html(
                      data: guideline.description,
                      style: {
                        "body": Style(
                          fontSize: FontSize(12),
                          color: colors.onBackground.withOpacity(0.7),
                          margin: Margins.zero,
                          // padding: EdgeInsets.zero,
                        ),
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(DashBoardProvider provider, CartingQuestions questions) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildTab("Carting Rule", 'cartingRule', provider),
          const SizedBox(width: 10),
          _buildTab("Tips", 'tips', provider),
          const SizedBox(width: 10),
          _buildTab("Safety", 'safety', provider),
        ],
      ),
    );
  }

  Widget _buildTab(String title, String tabKey, DashBoardProvider provider) {
    final colors = Theme.of(context).colorScheme;
    final isSelected = provider.selectedQuestionTab == tabKey;

    return GestureDetector(
      onTap: () => provider.selectQuestionTab(tabKey),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                    color: isSelected ? colors.onPrimary : colors.primary)),
            const SizedBox(width: 5),
            Icon(Icons.arrow_forward,
                color: isSelected ? colors.onPrimary : colors.primary,
                size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent(CartingQuestions questions, String selectedTab) {
    final colors = Theme.of(context).colorScheme;
    String content;

    switch (selectedTab) {
      case 'cartingRule':
        content = questions.cartingRule;
        break;
      case 'tips':
        content = questions.tips;
        break;
      case 'safety':
        content = questions.safety;
        break;
      default:
        content = '';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Html(
        data: content,
        style: {
          "body": Style(
            fontSize: FontSize(14),
            color: colors.onBackground,
            margin: Margins.zero,
            // padding: EdgeInsets.zero,
          ),
        },
      ),
    );
  }

  Widget _buildRulesList(List<CartingSection> sections) {
    return Column(
      children: sections.map((section) => _buildRuleCard(section)).toList(),
    );
  }

  Widget _buildRuleCard(CartingSection section) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                Text(section.title,
                    style: TextStyle(
                        color: colors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Html(
                  data: section.description,
                  style: {
                    "body": Style(
                      fontSize: FontSize(13),
                      color: colors.onBackground,
                      margin: Margins.zero,
                      //   padding: EdgeInsets.zero,
                    ),
                  },
                ),
                const SizedBox(height: 4),
                Text("Status: ${section.isActive ? 'Active' : 'Inactive'}",
                    style: TextStyle(color: colors.primary)),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(section.isActive ? Icons.check : Icons.close,
                color: section.isActive ? Colors.green : Colors.red),
          ),
        ],
      ),
    );
  }
}
