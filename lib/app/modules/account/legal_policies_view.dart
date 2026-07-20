import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'legal_webview.dart';

class LegalPoliciesView extends StatelessWidget {
  const LegalPoliciesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).scaffoldBackgroundColor
          : const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.iconTheme?.color ?? Theme.of(context).textTheme.titleLarge?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Legal, Terms & Conditions',
          style: GoogleFonts.poppins(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                _buildPolicyRow(
                  context,
                  title: 'Terms & Conditions',
                  subtitle: 'Our user agreements and site regulations',
                  url: 'https://ironstreets.com/terms-conditions/',
                ),
                // const Divider(height: 1),
                _buildPolicyRow(
                  context,
                  title: 'Privacy Policy',
                  subtitle: 'How we manage and protect user data',
                  url: 'https://ironstreets.com/privacy-policy/',
                ),
                // const Divider(height: 1),
                _buildPolicyRow(
                  context,
                  title: 'Refund Policy',
                  subtitle: 'Return, refund, and replacement criteria',
                  url: 'https://ironstreets.com/refund-policy/',
                ),
                // const Divider(height: 1),
                _buildPolicyRow(
                  context,
                  title: 'Furniture Insurance Policy',
                  subtitle: 'Damage coverage and shipping guarantees',
                  url:
                      'https://ironstreets.com/insurance-policy-for-furniture/',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String url,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.titleSmall?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 9,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 12),
      onTap: () => Get.to(
        () => LegalWebView(
          title: title,
          url: url,
        ),
      ),
    );
  }
}
