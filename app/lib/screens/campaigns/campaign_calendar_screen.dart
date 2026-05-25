import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/campaign_provider.dart';
import '../../models/campaign_model.dart';
import '../../config/app_colors.dart';
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
    final campaigns = Provider.of<CampaignProvider>(context, listen: false).campaigns;
    return campaigns.where((campaign) {
      return isSameDay(campaign.startDate, day) ||
          (campaign.endDate != null &&
              day.isAfter(campaign.startDate.subtract(const Duration(days: 1))) &&
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
        title: const Text('Campaign Calendar'),
        centerTitle: true,
      ),
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
                            day.isAfter(campaign.startDate.subtract(const Duration(days: 1))) &&
                            day.isBefore(campaign.endDate!.add(const Duration(days: 1))));
                  }).toList();
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  markerDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.5),
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
                        Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No campaigns on this day', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final campaign = value[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(campaign.type.icon),
                        ),
                        title: Text(campaign.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(child: Text(campaign.location, style: const TextStyle(color: Colors.grey), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('MMM dd').format(campaign.startDate)} ${campaign.endDate != null ? '- ${DateFormat('MMM dd').format(campaign.endDate!)}' : ''}',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CampaignDetailScreen(campaign: campaign)),
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
