import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/donation_model.dart';
import '../../config/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_tokens.dart';
import '../../utils/responsive.dart';
import '../../widgets/web/premium_data_table.dart';
import '../../services/pdf_report_service.dart';
import '../donations/donation_tracker_screen.dart';
import '../donations/donation_ledger_screen.dart';

class AdminDonationsScreen extends StatefulWidget {
  const AdminDonationsScreen({super.key});

  @override
  State<AdminDonationsScreen> createState() => _AdminDonationsScreenState();
}

class _AdminDonationsScreenState extends State<AdminDonationsScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'Rs. ',
    decimalDigits: 0,
  );
  final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: Responsive.isMobile(context)
          ? AppBar(
              title: Text('All Donations', style: AppTextStyles.titleLarge()),
            )
          : null,
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('donations')
              .orderBy('receivedAt', descending: true)
              .limit(50)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error.withValues(alpha: 0.6),
                    ),
                    AppSpacing.vGapMd,
                    Text(
                      'Something went wrong',
                      style: AppTextStyles.bodyMedium(color: AppColors.error),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: isDark
                          ? AppColors.darkTextHint
                          : AppColors.lightTextHint,
                    ),
                    AppSpacing.vGapLg,
                    Text('No Donations Yet', style: AppTextStyles.titleLarge()),
                    AppSpacing.vGapSm,
                    Text(
                      'Donations will appear here once recorded.',
                      style: AppTextStyles.bodyMedium(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final donations = docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return DonationModel.fromMap(data);
            }).toList();

            // ─── DESKTOP: Premium Data Table ───
            if (isDesktop) {
              return SingleChildScrollView(
                child: PremiumDataTable<DonationModel>(
                  data: donations,
                  title: 'Donation Reports',
                  searchHint: 'Search by donor name...',
                  searchFilter: (d, q) =>
                      d.donorName.toLowerCase().contains(q.toLowerCase()) ||
                      d.campaignTitle.toLowerCase().contains(q.toLowerCase()),
                  columns: [
                    PremiumColumn<DonationModel>(
                      header: 'DATE',
                      flex: 2,
                      builder: (d) => Text(
                        _dateFormat.format(d.receivedAt),
                        style: AppTextStyles.bodySmall(),
                      ),
                    ),
                    PremiumColumn<DonationModel>(
                      header: 'DONOR',
                      flex: 3,
                      builder: (d) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(d.donorName, style: AppTextStyles.bodyMedium()),
                          Text(
                            d.campaignTitle,
                            style: AppTextStyles.caption(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PremiumColumn<DonationModel>(
                      header: 'AMOUNT',
                      flex: 2,
                      builder: (d) => Text(
                        d.isMoney
                            ? _currencyFormat.format(d.amount)
                            : d.quantity,
                        style: AppTextStyles.titleMedium(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    PremiumColumn<DonationModel>(
                      header: 'METHOD',
                      flex: 2,
                      builder: (d) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: d.isMoney
                              ? AppColors.accent.withValues(alpha: 0.1)
                              : AppColors.info.withValues(alpha: 0.1),
                          borderRadius: AppTokens.borderRadiusPill,
                        ),
                        child: Text(
                          d.isMoney
                              ? d.paymentMethod.name.toUpperCase()
                              : 'IN-KIND',
                          style: AppTextStyles.labelSmall(
                            color: d.isMoney
                                ? AppColors.accent
                                : AppColors.info,
                          ),
                        ),
                      ),
                    ),
                    PremiumColumn<DonationModel>(
                      header: 'ACTIONS',
                      flex: 1,
                      builder: (d) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.currency_bitcoin,
                              size: 18,
                              color: Colors.orange,
                            ),
                            tooltip: 'Web3 Explorer',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DonationLedgerScreen(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.track_changes, size: 18),
                            tooltip: 'Track Donation',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DonationTrackerScreen(
                                    donationId: d.id,
                                    amount: d.amount,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.receipt_outlined, size: 18),
                            tooltip: 'Download Receipt',
                            onPressed: d.isMoney
                                ? () async {
                                    try {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Generating Receipt...',
                                          ),
                                        ),
                                      );
                                      await PdfReportService.generateDonationReceipt(
                                        donorName: d.donorName,
                                        donorPhone: d.donorPhone ?? '',
                                        amount: d.amount,
                                        campaignTitle: d.campaignTitle,
                                        paymentMethod: d.paymentMethod.name,
                                        date: d.receivedAt,
                                        receiptId: d.id,
                                      );
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to generate receipt: $e',
                                            ),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.red,
                            ),
                            tooltip: 'Delete Donation',
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Donation?'),
                                  content: const Text(
                                    'Are you sure you want to delete this donation record? This cannot be undone.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('donations')
                                    .doc(d.id)
                                    .delete();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // ─── MOBILE: Premium list view ───
            return ListView.separated(
              itemCount: donations.length,
              separatorBuilder: (context, index) => Divider(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final donation = donations[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: donation.isMoney
                                ? AppColors.accent.withValues(alpha: 0.1)
                                : AppColors.info.withValues(alpha: 0.1),
                            child: Icon(
                              donation.isMoney
                                  ? Icons.attach_money
                                  : Icons.inventory,
                              color: donation.isMoney
                                  ? AppColors.accent
                                  : AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation.donorName,
                                  style: AppTextStyles.titleSmall(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  donation.campaignTitle,
                                  style: AppTextStyles.caption(
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  _dateFormat.format(donation.receivedAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            donation.isMoney
                                ? _currencyFormat.format(donation.amount)
                                : donation.quantity,
                            style: AppTextStyles.titleMedium(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(
                              Icons.currency_bitcoin,
                              size: 16,
                              color: Colors.orange,
                            ),
                            label: const Text(
                              'Ledger',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DonationLedgerScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: Icon(
                              Icons.track_changes,
                              size: 16,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                            label: Text(
                              'Track',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DonationTrackerScreen(
                                    donationId: donation.id,
                                    amount: donation.amount,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                            label: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Donation?'),
                                  content: const Text(
                                    'Are you sure you want to delete this donation record?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('donations')
                                    .doc(donation.id)
                                    .delete();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
