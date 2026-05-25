import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../enums/app_enums.dart';
import '../../utils/responsive.dart';
import '../../widgets/campaign_card.dart';
import 'campaign_detail_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Shows all campaigns with search, filter, and FAB for admin.
class CampaignListScreen extends StatefulWidget {
  const CampaignListScreen({super.key});

  @override
  State<CampaignListScreen> createState() => _CampaignListScreenState();
}

class _CampaignListScreenState extends State<CampaignListScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _listen(CampaignProvider provider) async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => debugPrint('onStatus: $val'),
        onError: (val) => debugPrint('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _searchController.text = val.recognizedWords;
              provider.setSearchQuery(val.recognizedWords);
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignProvider = Provider.of<CampaignProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final isAdmin = user?.isAdmin == true;

    return Column(
      children: [
        // ─── Search & Filter Bar ───
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search campaigns...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? AppColors.error : null),
                      onPressed: () => _listen(campaignProvider),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        campaignProvider.setSearchQuery('');
                        setState(() {
                          _showSearch = false;
                          _isListening = false;
                        });
                        _speech.stop();
                      },
                    ),
                  ],
                ),
              ),
              onChanged: (value) => campaignProvider.setSearchQuery(value),
            ),
          ),

        // ─── Filter Chips ───
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: [
              _buildFilterChip(null, '${'all'.tr()} (${campaignProvider.totalCampaigns})', campaignProvider),
              _buildFilterChip(CampaignStatus.active, '🟢 ${'active'.tr()} (${campaignProvider.activeCampaigns})', campaignProvider),
              _buildFilterChip(CampaignStatus.upcoming, '🔵 ${'upcoming'.tr()} (${campaignProvider.upcomingCampaigns})', campaignProvider),
              _buildFilterChip(CampaignStatus.completed, '✅ ${'completed_status'.tr()} (${campaignProvider.completedCampaigns})', campaignProvider),
            ],
          ),
        ),

        // ─── Campaign List ───
        Expanded(
          child: campaignProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : campaignProvider.campaigns.isEmpty
                  ? _buildEmptyState(isAdmin)
                  : Responsive.isDesktop(context)
                      // ─── DESKTOP: Grid layout ───
                      ? LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
                            return GridView.builder(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: AppSpacing.lg,
                                mainAxisSpacing: AppSpacing.lg,
                                childAspectRatio: 1.6,
                              ),
                              itemCount: campaignProvider.campaigns.length,
                              itemBuilder: (context, index) {
                                final campaign = campaignProvider.campaigns[index];
                                return CampaignCard(
                                  campaign: campaign,
                                  onTap: () {
                                    campaignProvider.selectCampaign(campaign);
                                    Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: campaign)));
                                  },
                                );
                              },
                            );
                          },
                        )
                      // ─── MOBILE: List layout ───
                      : RefreshIndicator(
                          onRefresh: () async {
                            final ngoId = user?.currentNgoId ?? 'HRAS_DEFAULT_ID';
                            campaignProvider.init(ngoId);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 80),
                            itemCount: campaignProvider.campaigns.length,
                            itemBuilder: (context, index) {
                              final campaign = campaignProvider.campaigns[index];
                              return CampaignCard(
                                campaign: campaign,
                                onTap: () {
                                  campaignProvider.selectCampaign(campaign);
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: campaign)));
                                },
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(CampaignStatus? status, String label, CampaignProvider provider) {
    final isSelected = provider.statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: isSelected,
        onSelected: (_) => provider.setStatusFilter(isSelected ? null : status),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildEmptyState(bool isAdmin) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 80, color: AppColors.lightTextHint),
          AppSpacing.vGapLg,
          Text('No Campaigns Yet', style: AppTextStyles.titleLarge()),
          AppSpacing.vGapSm,
          Text(
            isAdmin ? 'Tap + to create your first campaign.' : 'No campaigns available right now.',
            style: AppTextStyles.bodyMedium(color: AppColors.lightTextSecondary),
          ),
        ],
      ),
    );
  }
}
