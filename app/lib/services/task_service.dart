import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import 'package:uuid/uuid.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream tasks for a specific campaign
  Stream<List<TaskModel>> streamCampaignTasks(String campaignId) {
    return _firestore
        .collection('campaigns')
        .doc(campaignId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Stream tasks assigned to a specific volunteer across all campaigns
  Stream<List<TaskModel>> streamVolunteerTasks(String volunteerId) {
    return _firestore
        .collectionGroup('tasks')
        .where('assignedToId', isEqualTo: volunteerId)
        .where('isCompleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Create a new task
  Future<void> createTask(TaskModel task) async {
    final taskRef = _firestore
        .collection('campaigns')
        .doc(task.campaignId)
        .collection('tasks')
        .doc(task.id);

    await taskRef.set(task.toMap());
  }

  // Update a task (e.g., mark as completed)
  Future<void> updateTask(TaskModel task) async {
    final taskRef = _firestore
        .collection('campaigns')
        .doc(task.campaignId)
        .collection('tasks')
        .doc(task.id);

    await taskRef.update(task.toMap());
  }

  // Delete a task
  Future<void> deleteTask(String campaignId, String taskId) async {
    final taskRef = _firestore
        .collection('campaigns')
        .doc(campaignId)
        .collection('tasks')
        .doc(taskId);

    await taskRef.delete();
  }

  // Generate ID
  String generateId() {
    return const Uuid().v4();
  }
}
