import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/banner_model.dart';
import '../../services/banner_service.dart';
import '../../theme/app_tokens.dart';
import '../../config/app_colors.dart';
import '../../screens/campaigns/campaign_detail_screen.dart';
import '../../screens/sessions/session_details_screen.dart';
import '../../models/campaign_model.dart';
import '../../services/campaign_service.dart';
import '../../services/virtual_session_service.dart';
import '../../utils/snackbar_helper.dart';

class DynamicBannerCarousel extends StatefulWidget {
  const DynamicBannerCarousel({super.key});

  @override
  State<DynamicBannerCarousel> createState() => _DynamicBannerCarouselState();
}

class _DynamicBannerCarouselState extends State<DynamicBannerCarousel> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  void _startTimer(int itemCount) {
    _timer?.cancel();
    if (itemCount <= 1) return;
    
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % itemCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleBannerClick(BuildContext context, BannerModel banner) async {
    if (banner.targetType == 'none') return;

    if (banner.targetType == 'external' && banner.targetUrl != null) {
      final url = Uri.parse(banner.targetUrl!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) SnackbarHelper.showError(context, 'Could not launch URL');
      }
    } else if (banner.targetType == 'campaign' && banner.targetId != null) {
      // Need to fetch campaign object first
      try {
        final campaign = await CampaignService().getCampaignById(banner.targetId!);
        if (context.mounted && campaign != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: campaign)));
        } else {
          if (context.mounted) SnackbarHelper.showError(context, 'Campaign not found');
        }
      } catch (e) {
        if (context.mounted) SnackbarHelper.showError(context, 'Error loading campaign');
      }
    } else if (banner.targetType == 'session' && banner.targetId != null) {
      try {
        final session = await VirtualSessionService().getSessionById(banner.targetId!);
        if (context.mounted && session != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => SessionDetailsScreen(session: session)));
        } else {
          if (context.mounted) SnackbarHelper.showError(context, 'Session not found');
        }
      } catch (e) {
        if (context.mounted) SnackbarHelper.showError(context, 'Error loading session');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BannerModel>>(
      stream: BannerService().getActiveBanners(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AspectRatio(
            aspectRatio: 1.0,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final banners = snapshot.data ?? [];
        if (banners.isEmpty) {
          return const SizedBox.shrink(); // Don't show anything if no banners exist
        }

        // Restart timer if count changes
        _startTimer(banners.length);

        return AspectRatio(
          aspectRatio: 1.0,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return GestureDetector(
                    onTap: () => _handleBannerClick(context, banner),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: AppColors.neutral900,
                      child: CachedNetworkImage(
                        imageUrl: banner.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.darkShimmerGradient,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
              
              // Dark gradient at bottom for indicator visibility
              Positioned(
                bottom: 0, left: 0, right: 0,
                height: 80,
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black87, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),

              // Page Indicator
              if (banners.length > 1)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: banners.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: AppColors.primary,
                        dotColor: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),

              // Navigation Arrows
              if (banners.length > 1)
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_left, color: Colors.white, size: 30)
                      ),
                      onPressed: () {
                        if (_currentPage > 0) {
                          _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        } else {
                          _pageController.animateToPage(banners.length - 1, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                ),
              if (banners.length > 1)
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_right, color: Colors.white, size: 30)
                      ),
                      onPressed: () {
                        if (_currentPage < banners.length - 1) {
                          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        } else {
                          _pageController.animateToPage(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
