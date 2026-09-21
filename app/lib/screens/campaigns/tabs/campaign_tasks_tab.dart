import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/campaign_model.dart';
import '../../../models/task_model.dart';
import '../../../models/volunteer_model.dart';
import '../../../enums/app_enums.dart';
import '../../../services/task_service.dart';
import '../../../services/volunteer_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../config/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../utils/snackbar_helper.dart';

class CampaignTasksTab extends StatelessWidget {
  final CampaignModel campaign;
  final bool isAdmin;

  const CampaignTasksTab({
    super.key,
    required this.campaign,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<TaskModel>>(
        stream: taskService.streamCampaignTasks(campaign.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                isAdmin
                    ? 'No tasks created yet. Click + to add.'
                    : 'No tasks assigned yet.',
              ),
            );
          }

          var allTasks = snapshot.data!;
          // Sort tasks: My tasks / All tasks first, then others
          allTasks.sort((a, b) {
            bool aIsMine =
                a.assignedToIds.contains(user?.uid) ||
                a.assignedToIds.contains('all');
            bool bIsMine =
                b.assignedToIds.contains(user?.uid) ||
                b.assignedToIds.contains('all');
            if (aIsMine && !bIsMine) return -1;
            if (!aIsMine && bIsMine) return 1;
            return b.createdAt.compareTo(a.createdAt);
          });
          var openTasks = allTasks.where((t) => !t.isCompleted).toList();
          var completedTasks = allTasks.where((t) => t.isCompleted).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'To Do (${openTasks.length})',
                    style: AppTextStyles.titleLarge(color: AppColors.primary),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTaskCard(
                    context,
                    openTasks[index],
                    taskService,
                    user,
                    isAdmin,
                  ),
                  childCount: openTasks.length,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Done (${completedTasks.length})',
                    style: AppTextStyles.titleLarge(color: AppColors.success),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildTaskCard(
                    context,
                    completedTasks[index],
                    taskService,
                    user,
                    isAdmin,
                  ),
                  childCount: completedTasks.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddTaskSheet(context),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add),
              label: const Text('Add Task'),
            )
          : null,
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    TaskModel task,
    TaskService taskService,
    user,
    bool isAdmin,
  ) {
    final isMe =
        task.assignedToIds.contains(user?.uid) ||
        task.assignedToIds.contains('all');
    final isUnassigned = task.assignedToIds.isEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isMe && !task.isCompleted
            ? BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      color: task.isCompleted
          ? (isDark ? Colors.green.withOpacity(0.1) : Colors.green.shade50)
          : (isDark ? Colors.grey[800] : Colors.white),
      elevation: task.isCompleted ? 0 : 2,
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (isAdmin || isMe)
              ? (bool? value) async {
                  if (value != null) {
                    await taskService.updateTask(
                      task.copyWith(isCompleted: value),
                    );
                  }
                }
              : null,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(task.description),
            const SizedBox(height: 8),
            if (isUnassigned)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Unassigned',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              Text(
                task.assignedToIds.contains('all')
                    ? 'Assigned to: All Volunteers'
                    : 'Assigned to: ${task.assignedToNames.join(', ')}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAdmin && isUnassigned)
              TextButton(
                onPressed: () async {
                  if (user != null) {
                    await taskService.updateTask(
                      task.copyWith(
                        assignedToIds: [user.uid],
                        assignedToNames: [user.name],
                      ),
                    );
                    if (context.mounted)
                      SnackbarHelper.showSuccess(context, 'Task Claimed!');
                  }
                },
                child: const Text('Claim'),
              ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () => taskService.deleteTask(campaign.id, task.id),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    List<VolunteerModel> selectedVolunteers = [];
    bool assignToAll = false;

    // Cache future to prevent rebuilding when keyboard opens
    final volunteersFuture = VolunteerService()
        .getVolunteersStream(campaign.id)
        .first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return FutureBuilder<List<VolunteerModel>>(
          future: volunteersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final volunteers = snapshot.data ?? [];
            final eligibleVolunteers = volunteers
                .where(
                  (v) =>
                      v.status == VolunteerStatus.confirmed ||
                      v.status == VolunteerStatus.registered,
                )
                .toList();

            return StatefulBuilder(
              builder: (context, setState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                    left: 16,
                    right: 16,
                    top: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Assign New Task',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Task Title (e.g., Setup Stage)',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (eligibleVolunteers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'No registered volunteers to assign tasks to.',
                            style: TextStyle(color: AppColors.error),
                          ),
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assign To:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilterChip(
                                  label: const Text('All Volunteers'),
                                  selected: assignToAll,
                                  onSelected: (val) {
                                    setState(() {
                                      assignToAll = val;
                                      if (val) selectedVolunteers.clear();
                                    });
                                  },
                                ),
                                if (!assignToAll)
                                  ...eligibleVolunteers.map((v) {
                                    final isSelected = selectedVolunteers
                                        .contains(v);
                                    return FilterChip(
                                      label: Text(v.userName),
                                      selected: isSelected,
                                      onSelected: (val) {
                                        setState(() {
                                          if (val) {
                                            selectedVolunteers.add(v);
                                          } else {
                                            selectedVolunteers.remove(v);
                                          }
                                        });
                                      },
                                    );
                                  }),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleCtrl.text.isEmpty || descCtrl.text.isEmpty)
                              return;

                            final taskService = TaskService();

                            List<String> assignedIds = [];
                            List<String> assignedNames = [];

                            if (assignToAll) {
                              assignedIds = ['all'];
                              assignedNames = ['All Volunteers'];
                            } else {
                              assignedIds = selectedVolunteers
                                  .map((v) => v.userId)
                                  .toList();
                              assignedNames = selectedVolunteers
                                  .map((v) => v.userName)
                                  .toList();
                            }

                            final task = TaskModel(
                              id: taskService.generateId(),
                              campaignId: campaign.id,
                              title: titleCtrl.text,
                              description: descCtrl.text,
                              assignedToIds: assignedIds,
                              assignedToNames: assignedNames,
                              createdAt: DateTime.now(),
                            );

                            await taskService.createTask(task);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              SnackbarHelper.showSuccess(ctx, 'Task Assigned!');
                            }
                          },
                          child: const Text('Assign Task'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
