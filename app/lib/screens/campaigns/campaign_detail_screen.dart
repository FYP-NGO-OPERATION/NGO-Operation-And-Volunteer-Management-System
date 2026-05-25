import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_colors.dart';
import '../../config/feature_flags.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/campaign_model.dart';
import '../../models/donation_model.dart';
import '../../models/expense_model.dart';
import '../../models/volunteer_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/campaign_provider.dart';
import '../../services/campaign_service.dart';
import '../../services/donation_service.dart';
import '../../services/volunteer_service.dart';
import '../../enums/app_enums.dart';
import '../../utils/responsive.dart';
import '../../utils/snackbar_helper.dart';
import 'photo_gallery_screen.dart';
import 'qr_generate_screen.dart';
import '../donations/add_donation_screen.dart';
import '../expenses/add_expense_screen.dart';
import '../volunteers/volunteer_list_screen.dart';
import '../beneficiaries/beneficiary_list_screen.dart';
import 'create_campaign_screen.dart';
import 'tabs/campaign_tasks_tab.dart';
import 'tabs/campaign_chat_tab.dart';
import 'tabs/campaign_highlights_tab.dart';
import 'components/campaign_info_tab.dart';
import 'components/campaign_record_tab.dart';
import '../admin/expense_tracking_screen.dart';
import '../admin/feedback_list_screen.dart';
import '../../models/feedback_model.dart';
import '../../services/feedback_service.dart';

/// Campaign Detail — Tabbed view (Info | Record | Highlights)
/// As per NGO leader: "Click project → Record + Highlights"
class CampaignDetailScreen extends StatefulWidget {
  final CampaignModel campaign;

  const CampaignDetailScreen({super.key, required this.campaign});

  @override
  State<CampaignDetailScreen> createState() => _CampaignDetailScreenState();
}

class _CampaignDetailScreenState extends State<CampaignDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CampaignModel _campaign;
  final VolunteerService _volunteerService = VolunteerService();
  VolunteerModel? _myVolunteerRecord;
  bool _isJoining = false;

  @override
  void initState() {
    super.initState();
    _campaign = widget.campaign;
    _tabController = TabController(length: 5, vsync: this);
    _checkJoinStatus();
  }

  /// Check if current user already joined this campaign
  Future<void> _checkJoinStatus() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;
    final record = await _volunteerService.getUserVolunteerRecord(
      _campaign.id,
      user.uid,
    );
    if (mounted) {
      setState(() => _myVolunteerRecord = record);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool get _hasJoined => _myVolunteerRecord != null && (_myVolunteerRecord!.isRegistered || _myVolunteerRecord!.isConfirmed || _myVolunteerRecord!.hasAttended);
  bool get _isPending => _myVolunteerRecord != null && _myVolunteerRecord!.isPending;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final isAdmin = user?.isAdmin == true;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_campaign.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'share_campaign'.tr(),
            onPressed: () {
              final String shareText = "🌟 Join this amazing campaign: ${_campaign.title}!\n\n"
                  "${_campaign.description}\n\n"
                  "📍 Location: ${_campaign.location}\n"
                  "🎯 Goal: ${_campaign.targetGoal}\n\n"
                  "📱 Download the HRAS App now to join as a volunteer or donate!";
              Share.share(shareText, subject: _campaign.title);
            },
          ),
          if (!isAdmin && _hasJoined && _campaign.status == CampaignStatus.active)
            IconButton(
              icon: const Icon(Icons.emergency, color: AppColors.error),
              tooltip: 'emergency_sos'.tr(),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Row(
                      children: [
                        const Icon(Icons.warning, color: AppColors.error),
                        const SizedBox(width: 8),
                        Text('emergency_sos'.tr(), style: const TextStyle(color: AppColors.error)),
                      ],
                    ),
                    content: Text('sos_desc'.tr()),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('sos_alert_sent'.tr()),
                              backgroundColor: AppColors.error,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                        child: Text('send_sos_alarm'.tr()),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (isAdmin)
            PopupMenuButton<String>(
              onSelected: (action) => _handleAction(action),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('✏️ Edit Campaign')),
                const PopupMenuItem(value: 'expenses', child: Text('💸 Expense Log')),
                if (_campaign.isCompleted) const PopupMenuItem(value: 'feedback', child: Text('⭐ View Feedback')),
                const PopupMenuItem(value: 'status', child: Text('🔄 Change Status')),
                if (FeatureFlags.isQrAttendanceEnabled)
                  const PopupMenuItem(value: 'qr', child: Text('📱 Generate QR Code')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('🗑️ Delete', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: const Icon(Icons.info_outline), text: 'info'.tr()),
            Tab(icon: const Icon(Icons.assignment), text: 'tasks'.tr()),
            Tab(icon: const Icon(Icons.forum), text: 'chat'.tr()),
            Tab(icon: const Icon(Icons.receipt_long), text: 'record'.tr()),
            Tab(icon: const Icon(Icons.photo_library), text: 'highlights'.tr()),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: Responsive.isDesktop(context) ? 1100 : double.infinity),
          child: TabBarView(
            controller: _tabController,
            children: [
              CampaignInfoTab(campaign: _campaign),
              CampaignTasksTab(campaign: _campaign, isAdmin: isAdmin),
              (!isAdmin && !_hasJoined) 
                  ? const Center(child: Text('You must join this campaign to access the chat room.')) 
                  : CampaignChatTab(campaign: _campaign),
              CampaignRecordTab(campaign: _campaign, isAdmin: isAdmin),
              CampaignHighlightsTab(campaign: _campaign),
            ],
          ),
        ),
      ),
      // Join / Leave / Feedback button for volunteers
      floatingActionButton: (!isAdmin)
          ? _campaign.isCompleted
              ? (_myVolunteerRecord?.status == VolunteerStatus.attended)
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: FloatingActionButton.extended(
                        onPressed: () => _showFeedbackDialog(context),
                        icon: const Icon(Icons.star),
                        label: Text('leave_feedback'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    )
                  : (_myVolunteerRecord == null)
                      ? Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          child: FloatingActionButton.extended(
                            onPressed: _isJoining ? null : _joinCampaign,
                            icon: _isJoining 
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.history_edu),
                            label: Text(
                              _isJoining ? 'please_wait'.tr() : 'i_participated'.tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                            ),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        )
                      : _isPending
                          ? Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              child: FloatingActionButton.extended(
                                onPressed: _isJoining ? null : _leaveCampaign,
                                icon: _isJoining
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.cancel_schedule_send),
                                label: Text(
                                  _isJoining ? 'please_wait'.tr() : 'cancel_request'.tr(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                                ),
                                backgroundColor: AppColors.warning,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            )
                          : null
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: FloatingActionButton.extended(
                    onPressed: _isJoining
                        ? null
                        : _hasJoined
                            ? _leaveCampaign
                            : _joinCampaign,
                    icon: _isJoining
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(_hasJoined ? Icons.exit_to_app : (_campaign.status == CampaignStatus.upcoming ? Icons.notifications_active : Icons.how_to_reg)),
                    label: Text(
                      _isJoining
                          ? 'please_wait'.tr()
                          : _hasJoined
                              ? (_campaign.status == CampaignStatus.upcoming ? 'cancel_request'.tr() : 'leave_campaign'.tr())
                              : _campaign.isFull
                                  ? 'campaign_full'.tr()
                                  : (_campaign.status == CampaignStatus.upcoming ? 'pre_register'.tr() : 'join_campaign'.tr()),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
                    ),
                    backgroundColor: _hasJoined
                        ? AppColors.error
                        : _campaign.isFull
                            ? AppColors.lightTextHint
                            : AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // VOLUNTEER JOIN / LEAVE
  // ═══════════════════════════════════════════

  Future<void> _joinCampaign() async {
    if (_campaign.isFull) {
      SnackbarHelper.showWarning(context, 'This campaign is full.');
      return;
    }
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _isJoining = true);
    try {
      final record = await _volunteerService.joinCampaign(
        campaignId: _campaign.id,
        campaignTitle: _campaign.title,
        userId: user.uid,
        userName: user.name,
        userEmail: user.email,
        userPhone: user.phone,
      );
      if (mounted) {
        setState(() {
          _myVolunteerRecord = record;
          _isJoining = false;
        });
        final isUpcoming = _campaign.status == CampaignStatus.upcoming;
        SnackbarHelper.showSuccess(
          context,
          isUpcoming
              ? 'Pre-registered! You will be notified when it starts.'
              : 'Your request to join ${_campaign.title} has been sent! 🚀',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        SnackbarHelper.showError(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _leaveCampaign() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Campaign'),
        content: Text('Are you sure you want to leave "${_campaign.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null || _myVolunteerRecord == null) return;

    setState(() => _isJoining = true);
    try {
      await _volunteerService.leaveCampaign(
        volunteerId: _myVolunteerRecord!.id,
        campaignId: _campaign.id,
        userId: user.uid,
      );
      if (mounted) {
        setState(() {
          _myVolunteerRecord = null;
          _isJoining = false;
        });
        final isUpcoming = _campaign.status == CampaignStatus.upcoming;
        SnackbarHelper.showInfo(
          context,
          isUpcoming ? 'You cancelled your interest.' : 'You left the campaign.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        SnackbarHelper.showError(context, 'Failed: $e');
      }
    }
  }

  // ═══════════════════════════════════════════
  // ACTIONS
  // ═══════════════════════════════════════════
  void _handleAction(String action) async {
    switch (action) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateCampaignScreen(campaign: _campaign),
          ),
        );
        break;

      case 'expenses':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ExpenseTrackingScreen(campaign: _campaign)),
        );
        break;

      case 'feedback':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FeedbackListScreen(campaign: _campaign)),
        );
        break;

      case 'status':
        _showStatusDialog();
        break;

      case 'qr':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QrGenerateScreen(
              campaignId: _campaign.id,
              campaignTitle: _campaign.title,
            ),
          ),
        );
        break;

      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CampaignStatus.values.map((status) {
            final isSelected = _campaign.status == status;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: AppColors.primary,
              ),
              title: Text('${status.icon} ${status.label}'),
              onTap: () async {
                Navigator.pop(ctx);
                final provider = Provider.of<CampaignProvider>(context, listen: false);
                final success = await provider.updateStatus(_campaign.id, status);
                if (mounted && success) {
                  setState(() {
                    _campaign = _campaign.copyWith(status: status);
                  });
                  SnackbarHelper.showSuccess(context, 'Status updated to ${status.label}');
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDeleteDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: Text('Are you sure you want to delete "${_campaign.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final provider = Provider.of<CampaignProvider>(context, listen: false);
      final success = await provider.deleteCampaign(_campaign.id);
      if (mounted && success) {
        SnackbarHelper.showSuccess(context, 'Campaign deleted.');
        Navigator.pop(context);
      }
    }
  }

  void _showFeedbackDialog(BuildContext context) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final feedbackService = FeedbackService();
    final hasSubmitted = await feedbackService.hasUserSubmittedFeedback(_campaign.id, user.uid);

    if (hasSubmitted && mounted) {
      SnackbarHelper.showError(context, 'You have already submitted feedback for this campaign.');
      return;
    }

    if (!mounted) return;

    double rating = 5.0;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate Your Experience'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setState(() => rating = index + 1.0),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Share your thoughts about this campaign...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (commentCtrl.text.trim().isEmpty) return;

                    final feedback = FeedbackModel(
                      id: feedbackService.generateId(),
                      campaignId: _campaign.id,
                      volunteerId: user.uid,
                      volunteerName: user.name,
                      rating: rating,
                      comment: commentCtrl.text.trim(),
                      createdAt: DateTime.now(),
                    );

                    await feedbackService.submitFeedback(feedback);
                    if (mounted) {
                      Navigator.pop(ctx);
                      SnackbarHelper.showSuccess(context, 'Thank you for your feedback!');
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
