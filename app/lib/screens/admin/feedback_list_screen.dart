import 'package:flutter/material.dart';
import '../../models/campaign_model.dart';
import '../../models/feedback_model.dart';
import '../../services/feedback_service.dart';
import '../../config/app_colors.dart';
import 'package:intl/intl.dart';

class FeedbackListScreen extends StatelessWidget {
  final CampaignModel campaign;

  const FeedbackListScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final feedbackService = FeedbackService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Feedback'),
      ),
      body: StreamBuilder<List<FeedbackModel>>(
        stream: feedbackService.streamCampaignFeedbacks(campaign.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No feedback received yet.'));
          }

          final feedbacks = snapshot.data!;
          final avgRating = feedbacks.map((f) => f.rating).reduce((a, b) => a + b) / feedbacks.length;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                color: AppColors.primarySurface,
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < avgRating.round() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text('Based on ${feedbacks.length} reviews', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: feedbacks.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final feedback = feedbacks[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(feedback.volunteerName[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(feedback.volunteerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Text(feedback.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Icon(Icons.star, color: Colors.amber, size: 16),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(feedback.comment),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(feedback.createdAt),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
