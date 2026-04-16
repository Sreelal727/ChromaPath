import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: April 2025',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white38),
            ),
            const SizedBox(height: 24),
            _section(
              'Overview',
              'ChromaPath ("we", "our", or "the app") is a free color-flow puzzle game. '
              'This policy explains what data is collected when you use the app.',
            ),
            _section(
              'Data We Collect',
              'We do not directly collect any personal information. '
              'The app stores your game progress and coin balance locally on your device using shared preferences. '
              'This data never leaves your device.',
            ),
            _section(
              'Advertising (Google AdMob)',
              'ChromaPath uses Google AdMob to display advertisements. '
              'AdMob may collect and use data to show personalized ads, including:\n\n'
              '• Device identifiers (advertising ID)\n'
              '• IP address\n'
              '• General location (country/region)\n'
              '• App usage and interaction data\n\n'
              'This data is collected and processed by Google in accordance with their privacy policy. '
              'You can opt out of personalized advertising in your device settings:\n\n'
              '• Android: Settings → Google → Ads → Opt out of Ads Personalization\n'
              '• iOS: Settings → Privacy → Tracking → disable for ChromaPath',
            ),
            _section(
              'Third-Party Services',
              'The following third-party service is used:\n\n'
              '• Google AdMob — advertising platform\n'
              '  Privacy policy: https://policies.google.com/privacy',
            ),
            _section(
              'Children\'s Privacy',
              'ChromaPath is not directed at children under 13. '
              'We do not knowingly collect personal data from children.',
            ),
            _section(
              'Data Retention',
              'Local game data (progress and coins) is stored on your device until you uninstall the app or clear its data.',
            ),
            _section(
              'Contact',
              'If you have questions about this privacy policy, please contact us at:\n'
              'varunsatheesh24@gmail.com',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
