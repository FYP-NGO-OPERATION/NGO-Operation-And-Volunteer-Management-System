import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/banner_model.dart';
import '../../services/banner_service.dart';
import '../../config/app_colors.dart';
import '../../screens/campaigns/campaign_detail_screen.dart';
import '../../screens/sessions/session_details_screen.dart';
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
  late Stream<List<BannerModel>> _bannersStream;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _bannersStream = BannerService().getActiveBanners();
  }

  void _startTimer(int itemCount) {
    _timer?.cancel();
    if (itemCount <= 1) return;
    
    // Change banner every 3 seconds as requested
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % itemCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000), // Smooth 1-second transition
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<List<BannerModel>>(
      stream: _bannersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AspectRatio(
            aspectRatio: 4 / 3, // Premium taller aspect ratio (16:12)
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Limit to 5 banners as requested
        final banners = (snapshot.data ?? []).take(5).toList();
        
        if (banners.isEmpty) {
          return const SizedBox.shrink(); 
        }

        // Restart timer if count changes
        _startTimer(banners.length);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              // High-end glowing effect
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.3 : 0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: isDark ? Colors.black45 : Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 4 / 3, // Premium taller aspect ratio
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
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double pageOffset = 0.0;
                          if (_pageController.position.haveDimensions) {
                            pageOffset = (_pageController.page ?? _pageController.initialPage.toDouble()) - index;
                          } else {
                            pageOffset = _currentPage.toDouble() - index;
                          }

                          // Magical smooth zoom-fade transition
                          double scale = (1 - (pageOffset.abs() * 0.15)).clamp(0.85, 1.0);
                          double opacity = (1 - (pageOffset.abs() * 0.5)).clamp(0.0, 1.0);

                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () => _handleBannerClick(context, banner),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ]
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: CachedNetworkImage(
                                imageUrl: banner.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  decoration: const BoxDecoration(
                                    gradient: AppColors.darkShimmerGradient,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
                                  child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Dark gradient overlay at bottom for indicator and arrows
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    height: 60,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
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
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: banners.length,
                          effect: CustomizableEffect(
                            activeDotDecoration: DotDecoration(
                              width: 24,
                              height: 6,
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                              dotBorder: const DotBorder(color: Colors.white, width: 1),
                            ),
                            dotDecoration: DotDecoration(
                              width: 8,
                              height: 6,
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            spacing: 6,
                          ),
                        ),
                      ),
                    ),

                  // Sleek Navigation Arrows (Only show if multiple banners exist)
                  if (banners.length > 1) ...[
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildNavArrow(Icons.chevron_left_rounded, () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
                          } else {
                            _pageController.animateToPage(banners.length - 1, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
                          }
                        }),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _buildNavArrow(Icons.chevron_right_rounded, () {
                          if (_currentPage < banners.length - 1) {
                            _pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
                          } else {
                            _pageController.animateToPage(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
                          }
                        }),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavArrow(IconData icon, VoidCallback onTap) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.black.withValues(alpha: 0.3), // Glassmorphism feel
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
