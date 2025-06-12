import 'package:cartie/features/dashboard/certificate_info_screen.dart';
import 'package:flutter/material.dart';

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onBackground),
        title: Text(
          'Certificate',
          style: theme.textTheme.displayLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: 4,
          itemBuilder: (context, index) {
            bool isSelected = index == 0; // Highlight the first one
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CertificateResultScreen(),
                ));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.secondary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active',
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Certificate',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onBackground.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Issued : March 2025 | Exp : 2026',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.remove_red_eye_outlined,
                        color: colors.error,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
