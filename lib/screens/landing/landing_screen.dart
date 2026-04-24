import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/campaign_provider.dart';
import '../../models/campaign_model.dart';
import '../../utils/responsive.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HRAS NGO', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text('Login', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Join Us'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildImpactNumbers(context),
            _buildAboutUs(context),
            _buildRecentCampaigns(context),
            _buildTeam(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1593113514676-5f502479e0ee?q=80&w=2000&auto=format&fit=crop'), // Placeholder charity image
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.volunteer_activism, size: isMobile ? 60 : 80, color: Colors.white),
          const SizedBox(height: 24),
          Text(
            'Hamesha Rahein Apke Saath',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Join our community of volunteers and make a real difference today.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 16 : 20,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
            },
            icon: const Icon(Icons.favorite),
            label: const Text('Become a Volunteer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactNumbers(BuildContext context) {
    return Consumer<CampaignProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          color: Colors.white,
          child: Responsive.isMobile(context)
              ? Column(
                  children: [
                    _statItem('${provider.totalCampaigns}', 'Campaigns'),
                    const SizedBox(height: 24),
                    _statItem('${provider.totalBeneficiariesOverall}+', 'Families Helped'),
                    const SizedBox(height: 24),
                    _statItem('${provider.totalItemsDistributedOverall}+', 'Items Donated'),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statItem('${provider.totalCampaigns}', 'Campaigns'),
                    _statItem('${provider.totalBeneficiariesOverall}+', 'Families Helped'),
                    _statItem('${provider.totalItemsDistributedOverall}+', 'Items Donated'),
                  ],
                ),
        );
      },
    );
  }

  Widget _statItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAboutUs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              const Text(
                'About Our Mission',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'HRAS (Hamesha Rahein Apke Saath) is dedicated to bringing hope, aid, and sustainable change to communities in need. We believe in the power of collective volunteerism to transform lives and build a better future for everyone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.6, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCampaigns(BuildContext context) {
    return Consumer<CampaignProvider>(
      builder: (context, provider, child) {
        final campaigns = provider.allCampaigns.take(3).toList();

        if (campaigns.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
          color: Colors.white,
          child: Column(
            children: [
              const Text(
                'Our Recent Campaigns',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: campaigns.map((c) => _buildCampaignCard(context, c)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCampaignCard(BuildContext context, CampaignModel campaign) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: campaign.coverImageUrl != null && campaign.coverImageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: campaign.coverImageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: AppColors.primarySurface,
                      child: const Center(child: Icon(Icons.campaign, size: 60, color: AppColors.primary)),
                    ),
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.primarySurface,
                    child: const Center(child: Icon(Icons.campaign, size: 60, color: AppColors.primary)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  campaign.description,
                  style: const TextStyle(color: AppColors.textSecondary),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        campaign.location,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeam(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: Colors.white,
      child: Column(
        children: [
          const Text(
            'Our Core Team',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _teamMember('Admin', 'Founder & Director', Icons.person),
              _teamMember('Volunteer', 'Field Coordinator', Icons.person_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _teamMember(String name, String role, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primarySurface,
          child: Icon(icon, size: 50, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(role, style: const TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFF1A1A1A),
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            'HRAS NGO',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(Icons.camera_alt, 'https://www.instagram.com/hras_hamesharaheinapkesaath?igsh=eWRhdzBld2tnMXRk'),
              const SizedBox(width: 20),
              _socialIcon(Icons.facebook, 'https://www.facebook.com/share/18JqaHAKdM/'),
              const SizedBox(width: 20),
              _socialIcon(Icons.music_note, 'https://www.tiktok.com/@hras_official?_r=1&_t=ZS-95mfeOBr0tt'),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            '© 2026 HRAS NGO. All rights reserved.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (!await launchUrl(uri)) {
          debugPrint('Could not launch $url');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
