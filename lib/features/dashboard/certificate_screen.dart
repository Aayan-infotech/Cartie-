import 'package:cartie/features/providers/course_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cartie/core/api_services/call_helper.dart';
import 'package:cartie/core/api_services/server_calls/course_section_api.dart';
import 'package:cartie/core/models/certificate_model.dart';
import 'package:cartie/core/models/course_model.dart';
import 'package:cartie/core/models/question_submition.dart';
import 'package:cartie/core/models/quiz_model.dart';
import 'package:cartie/features/view_certificate.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch certificates when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseProvider>(context, listen: false).getAllCertificate();
    });
  }

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
          'Certificates',
          style: theme.textTheme.displayLarge,
        ),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.lstCertificate.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.lstCertificate.isEmpty) {
            return Center(
              child: Text(
                'No certificates available',
                style: textTheme.bodyLarge?.copyWith(
                  color: colors.onBackground.withOpacity(0.5),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              itemCount: provider.lstCertificate.length,
              itemBuilder: (context, index) {
                final certificate = provider.lstCertificate[index];
                final isActive = certificate.validUntil.isAfter(DateTime.now());

                return CertificateItem(
                  certificate: certificate,
                  isActive: isActive,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CertificateDetailScreen(
                        certificate: certificate,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CertificateItem extends StatelessWidget {
  final Certificate certificate;
  final bool isActive;
  final VoidCallback onTap;

  const CertificateItem({
    super.key,
    required this.certificate,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? colors.primary : Colors.grey,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Active' : 'Expired',
                    style: textTheme.bodyLarge?.copyWith(
                      color: isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    certificate.certificateName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: colors.onBackground,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.business, size: 16, color: colors.primary),
                      const SizedBox(width: 4),
                      Text(
                        certificate.certificateIssuedBy,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onBackground.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Issued: ${_formatDate(certificate.issueDate)} | '
                    'Exp: ${_formatDate(certificate.validUntil, showYearOnly: true)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onTap,
              icon: Icon(
                Icons.remove_red_eye_outlined,
                color: colors.primary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, {bool showYearOnly = false}) {
    return showYearOnly
        ? DateFormat('yyyy').format(date)
        : DateFormat('MMM yyyy').format(date);
  }
}

// Provider class remains the same as in your original code
