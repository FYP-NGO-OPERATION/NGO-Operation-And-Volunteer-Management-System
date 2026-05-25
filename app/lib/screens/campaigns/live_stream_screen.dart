import 'package:flutter/material.dart';
import '../../models/campaign_model.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';

class LiveStreamScreen extends StatefulWidget {
  final CampaignModel campaign;
  final bool isHost;

  const LiveStreamScreen({super.key, required this.campaign, this.isHost = false});

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final List<String> _comments = [
    'User1: Great cause!',
    'User2: Donated \$20!',
    'User3: Keep up the good work!',
  ];
  final _commentController = TextEditingController();

  void _sendComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _comments.add('You: ${_commentController.text}');
      });
      _commentController.clear();
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Mock Video Background
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey.shade900,
              child: const Center(
                child: Icon(Icons.videocam, size: 100, color: Colors.white24),
              ),
            ),
            
            // Header
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      children: [
                        Icon(Icons.visibility, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('1.2k', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),

            // Live Chat and Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campaign Info
                    Text(widget.campaign.title, style: AppTextStyles.titleMedium(color: Colors.white)),
                    const SizedBox(height: 16),

                    // Chat List
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _comments[index],
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          );
                        },
                      ),
                    ),

                    // Input Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.white24,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send, color: AppColors.primary),
                          onPressed: _sendComment,
                        ),
                        if (!widget.isHost)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.favorite, color: Colors.white, size: 16),
                            label: const Text('Donate'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donation link triggered')));
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
