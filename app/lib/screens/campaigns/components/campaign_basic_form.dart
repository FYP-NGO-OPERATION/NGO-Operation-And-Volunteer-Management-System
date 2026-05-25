import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Description', style: Theme.of(context).textTheme.labelMedium),
            TextButton.icon(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('please_enter_title'.tr())),
                  );
                  return;
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('ai_generating'.tr())),
                );
                
                Future.delayed(const Duration(seconds: 2), () {
                  final title = titleController.text;
                  final type = selectedType.label;
                  descriptionController.text = "Join us for our upcoming '$title' campaign! This $type initiative aims to create a lasting impact in our community. We are looking for dedicated volunteers to support our mission. Your participation will help us bring hope and essential resources to those who need them the most. Let's work together to make a difference!";
                });
              },
              icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
              label: Text('auto_generate_ai'.tr(), style: const TextStyle(color: Colors.purple, fontSize: 12)),
            ),
          ],
        ),
        CustomTextField(
          controller: descriptionController,
          label: '',
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
