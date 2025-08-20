import 'package:cartie/core/models/certificate_model.dart';
import 'package:cartie/core/theme/app_theme.dart';
import 'package:cartie/features/providers/course_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CertificateDetailScreen extends StatefulWidget {
  final Certificate certificate;
  bool isAssisment;

  CertificateDetailScreen(
      {this.isAssisment = false, super.key, required this.certificate});

  @override
  State<CertificateDetailScreen> createState() =>
      _CertificateDetailScreenState();
}

class _CertificateDetailScreenState extends State<CertificateDetailScreen> {
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<CourseProvider>(context, listen: false).getAllCertificate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              if (widget.isAssisment) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(widget.certificate.certificateName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCertificateCard(context),
            const SizedBox(height: 24),
            _buildDetailSection(context),
            const SizedBox(height: 32),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Image Preview Section
          if (widget.certificate.certificateUrl.isNotEmpty)
            _buildImagePreview(context)
          else
            _buildImagePlaceholder(context),

          // Certificate Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  widget.certificate.certificateName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Certificate #${widget.certificate.certificateNumber}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const Divider(height: 32),
                _buildInfoRow(
                  context,
                  'Issued by',
                  widget.certificate.certificateIssuedBy,
                  Icons.business_center,
                ),
                _buildInfoRow(
                  context,
                  'Issue Date',
                  _formatDate(widget.certificate.issueDate),
                  Icons.calendar_month,
                ),
                _buildInfoRow(
                  context,
                  'Valid Until',
                  _formatDate(widget.certificate.validUntil),
                  Icons.event_available,
                ),
                _buildInfoRow(
                  context,
                  'Location ID',
                  widget.certificate.locationId,
                  Icons.location_pin,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: widget.certificate.certificateUrl,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 220,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => _buildImagePlaceholder(context),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.image, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Certificate Image',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certificate Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDetailItem(
                context,
                'Certificate ID',
                widget.certificate.id,
              ),
              const Divider(height: 24),
              _buildDetailItem(
                context,
                'User ID',
                widget.certificate.userId,
              ),
              const Divider(height: 24),
              _buildDetailItem(
                context,
                'Issued At',
                _formatDateTime(widget.certificate.issuedAt),
              ),
              const Divider(height: 24),
              _buildDetailItem(
                context,
                'Created',
                _formatDateTime(widget.certificate.createdAt),
              ),
              const Divider(height: 24),
              _buildDetailItem(
                context,
                'Updated',
                _formatDateTime(widget.certificate.updatedAt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        if (widget.certificate.certificateUrl.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Download PDF Certificate'),
              onPressed: () => _launchUrl(
                  context, widget.certificate.certificateUrl, 'certificate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        if (widget.certificate.certificateUrl.isNotEmpty)
          const SizedBox(height: 12),
        if (widget.certificate.certificateUrl.isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Download Image'),
              onPressed: () => _launchUrl(
                  context, widget.certificate.certificateUrl, 'image'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
      ],
    );
  }

  void _launchUrl(BuildContext context, String url, String type) {
    if (url.isEmpty) {
      AppTheme.showErrorDialog(
          context, '${type.capitalize()} URL is not available');
      return;
    }

    try {
      launchUrl(Uri.parse(url));
    } catch (e) {
      AppTheme.showErrorDialog(
        context,
        'Could not open ${type}: ${e.toString()}',
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
