import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/campaign_model.dart';
import '../../../config/app_colors.dart';

class CampaignHighlightsTab extends StatefulWidget {
  final CampaignModel campaign;

  const CampaignHighlightsTab({super.key, required this.campaign});

  @override
  State<CampaignHighlightsTab> createState() => _CampaignHighlightsTabState();
}

class _CampaignHighlightsTabState extends State<CampaignHighlightsTab> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _isVideoError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.campaign.videoUrl != null &&
        widget.campaign.videoUrl!.isNotEmpty) {
      try {
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.campaign.videoUrl!),
        );
        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                'Error loading video',
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );

        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isVideoError = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _launchPdf() async {
    if (widget.campaign.documentUrl != null) {
      final url = Uri.parse(widget.campaign.documentUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open PDF file')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo =
        widget.campaign.videoUrl != null &&
        widget.campaign.videoUrl!.isNotEmpty;
    final hasGallery = widget.campaign.galleryUrls.isNotEmpty;
    final hasDoc =
        widget.campaign.documentUrl != null &&
        widget.campaign.documentUrl!.isNotEmpty;

    if (!hasVideo && !hasGallery && !hasDoc) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 60,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextHint
                  : AppColors.lightTextHint,
            ),
            const SizedBox(height: 12),
            Text(
              'Highlights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('No media uploaded yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasVideo) ...[
            const Text(
              'Highlight Video',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isVideoError
                    ? const Center(
                        child: Text(
                          'Failed to load video',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : _isVideoInitialized
                    ? Chewie(controller: _chewieController!)
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (hasDoc) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchPdf,
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  'View Project Record (PDF)',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (hasGallery) ...[
            const Text(
              'Photo Gallery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: widget.campaign.galleryUrls.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: widget.campaign.galleryUrls[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
