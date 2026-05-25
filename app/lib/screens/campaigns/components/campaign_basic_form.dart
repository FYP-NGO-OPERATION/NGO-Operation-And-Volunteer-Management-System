import 'package:flutter/material.dart';
import '../../../../enums/app_enums.dart';
import '../../../../widgets/common/custom_text_field.dart';

class CampaignBasicForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final CampaignType selectedType;
  final Function(CampaignType?) onTypeChanged;

  const CampaignBasicForm({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Campaign Type', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<CampaignType>(
          value: selectedType,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.category),
          ),
          items: CampaignType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text('${type.icon}  ${type.label}'),
            );
          }).toList(),
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: titleController,
          label: 'Campaign Title',
          hint: 'e.g., Ramadan Dastarkhan 2026',
          prefixIcon: Icons.title,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: descriptionController,
          label: 'Description',
          hint: 'Describe the campaign purpose and goals...',
          prefixIcon: Icons.description,
          maxLines: 4,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Description is required' : null,
        ),
      ],
    );
  }
}
