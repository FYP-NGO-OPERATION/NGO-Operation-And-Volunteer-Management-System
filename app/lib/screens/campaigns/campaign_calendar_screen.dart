import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/campaign_provider.dart';
import '../../models/campaign_model.dart';
import '../../config/app_colors.dart';
import '../../widgets/campaign_card.dart';
import 'campaign_detail_screen.dart';

class CampaignCalendarScreen extends StatefulWidget {
  const CampaignCalendarScreen({super.key});

  @override
  State<CampaignCalendarScreen> createState() => _CampaignCalendarScreenState();
}

class _CampaignCalendarScreenState extends State<CampaignCalendarScreen> {
  late final ValueNotifier<List<CampaignModel>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<CampaignModel> _getEventsForDay(DateTime day) {
    final campaigns = Provider.of<CampaignProvider>(
      context,
      listen: false,
    ).campaigns;
    return campaigns.where((campaign) {
      return isSameDay(campaign.startDate, day) ||
          (campaign.endDate != null &&
              day.isAfter(
                campaign.startDate.subtract(const Duration(days: 1)),
              ) &&
              day.isBefore(campaign.endDate!.add(const Duration(days: 1))));
    }).toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Campaign Calendar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          Consumer<CampaignProvider>(
            builder: (context, provider, child) {
              return TableCalendar<CampaignModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: (day) {
                  return provider.campaigns.where((campaign) {
                    return isSameDay(campaign.startDate, day) ||
                        (campaign.endDate != null &&
                            day.isAfter(
                              campaign.startDate.subtract(
                                const Duration(days: 1),
                              ),
                            ) &&
                            day.isBefore(
                              campaign.endDate!.add(const Duration(days: 1)),
                            ));
                  }).toList();
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonDecoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  formatButtonTextStyle: const TextStyle(color: Colors.white),
                  titleTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  markerDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                onDaySelected: _onDaySelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() => _calendarFormat = format);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              );
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<CampaignModel>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No campaigns on this day',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final campaign = value[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: CampaignCard(
                        campaign: campaign,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CampaignDetailScreen(campaign: campaign),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
