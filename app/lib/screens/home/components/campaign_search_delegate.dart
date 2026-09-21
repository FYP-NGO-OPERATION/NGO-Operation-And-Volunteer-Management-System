import 'package:flutter/material.dart';
import '../../../../config/app_colors.dart';
import '../../../../providers/campaign_provider.dart';
import '../../campaigns/campaign_detail_screen.dart';

class CampaignSearchDelegate extends SearchDelegate<String> {
  final CampaignProvider _provider;

  CampaignSearchDelegate(this._provider);

  @override
  String get searchFieldLabel => 'Search campaigns...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final q = query.toLowerCase();
    final results = _provider.allCampaigns
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.description.toLowerCase().contains(q) ||
              c.location.toLowerCase().contains(q),
        )
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text(
          'No campaigns found',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final campaign = results[index];
        return ListTile(
          leading: const Icon(Icons.campaign, color: AppColors.primary),
          title: Text(campaign.title),
          subtitle: Text(
            campaign.location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            close(context, '');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CampaignDetailScreen(campaign: campaign),
              ),
            );
          },
        );
      },
    );
  }
}
