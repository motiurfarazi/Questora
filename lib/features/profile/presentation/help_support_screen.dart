import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@questora.com', // Placeholder email
      query: 'subject=Help%20and%20Support%20Request',
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Icon(Icons.help_outline, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'How can we help you?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'If you are experiencing issues or have any questions about the Questora app, please do not hesitate to reach out to us.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          const Text(
            'Contact Us',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.email_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Email Support'),
              subtitle: const Text('support@questora.com'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _launchEmail,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.language, color: AppColors.primary),
              title: const Text('Visit our Website'),
              subtitle: const Text('www.questora.com'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final Uri url = Uri.parse('https://www.questora.com');
                if (!await launchUrl(url)) {
                  debugPrint('Could not launch url');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
