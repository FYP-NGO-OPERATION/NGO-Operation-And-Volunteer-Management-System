import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../enums/app_enums.dart';
import '../../../../widgets/common/custom_text_field.dart';

class CampaignLogisticsForm extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController targetGoalController;
  final TextEditingController itemsNeededController;
  final TextEditingController volunteerLimitController;
  final DateTime startDate;
  final DateTime? eventDate;
  final DateTime? endDate;
  final Function(bool) onSelectDate;
  final VoidCallback onSelectEventDate;
  final bool isEditing;
  final CampaignStatus selectedStatus;
  final Function(CampaignStatus?) onStatusChanged;
  final Function() onClearEndDate;
  final VoidCallback onClearEventDate;

  const CampaignLogisticsForm({
    super.key,
    required this.locationController,
    required this.latitudeController,
    required this.longitudeController,
    required this.targetGoalController,
    required this.itemsNeededController,
    required this.volunteerLimitController,
    required this.startDate,
    required this.eventDate,
    required this.endDate,
    required this.onSelectDate,
    required this.onSelectEventDate,
    required this.isEditing,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearEndDate,
    required this.onClearEventDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: locationController,
          label: 'Location Name',
          hint: 'e.g., Lahore, Gulberg',
          prefixIcon: Icons.location_on,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Location is required' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: latitudeController,
                label: 'Lat (Optional)',
                hint: 'e.g. 24.8607',
                prefixIcon: Icons.map,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: longitudeController,
                label: 'Lng (Optional)',
                hint: 'e.g. 67.0011',
                prefixIcon: Icons.map,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: targetGoalController,
          label: 'Target Goal',
          hint: 'e.g., Distribute 500 ration packs',
          prefixIcon: Icons.flag,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Target is required' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: itemsNeededController,
          label: 'Items Needed (Optional)',
          hint: 'e.g., 500 packs, 50 volunteers, 100K PKR',
          prefixIcon: Icons.list_alt,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: volunteerLimitController,
          label: 'Volunteer Limit (Optional)',
          hint: 'Max volunteers (leave empty for no limit)',
          prefixIcon: Icons.people,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        Text('Event Date', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => onSelectDate(true),
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(dateFormat.format(startDate)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Event Date (Optional)',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onSelectEventDate,
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.event),
              suffixIcon: eventDate != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClearEventDate,
                    )
                  : null,
            ),
            child: Text(
              eventDate != null
                  ? dateFormat.format(eventDate!)
                  : 'Select event date',
              style: eventDate == null
                  ? TextStyle(color: Theme.of(context).hintColor)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'End Date (Optional)',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => onSelectDate(false),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: endDate != null
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClearEndDate,
                    )
                  : null,
            ),
            child: Text(
              endDate != null ? dateFormat.format(endDate!) : 'Select end date',
              style: endDate == null
                  ? TextStyle(color: Theme.of(context).hintColor)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isEditing) ...[
          Text('Status', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<CampaignStatus>(
            initialValue: selectedStatus,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.flag_circle),
            ),
            items: CampaignStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text('${status.icon} ${status.label}'),
              );
            }).toList(),
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}
