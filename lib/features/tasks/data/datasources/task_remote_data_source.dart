import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/task_entity.dart';

abstract class TaskRemoteDataSource {
  Future<void> submitTask(TaskModel task);
  Future<List<TaskModel>> getTasks(String userId);
  Future<List<TaskModel>> getAllTasks(String organizationId);
  Future<void> updateTaskStatus(String taskId, TaskStatus status,
      {String? feedback});
  Future<List<TaskModel>> getAssignedTasks(String employeeId);
  Future<List<TaskModel>> getTasksAssignedByManager(String managerId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> submitTask(TaskModel task) async {
    try {
      await firestore.collection('tasks').doc(task.id).set(task.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      final query = await firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      // Sort in memory instead of using Firestore orderBy
      final tasks =
          query.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getAllTasks(String organizationId) async {
    try {
      final query = await firestore
          .collection('tasks')
          .where('organizationId', isEqualTo: organizationId)
          .orderBy('createdAt', descending: true)
          .get();
      return query.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus status,
      {String? feedback}) async {
    try {
      final data = <String, dynamic>{
        'status': status.toString().split('.').last,
      };
      if (feedback != null) {
        data['feedback'] = feedback;
      }
      await firestore.collection('tasks').doc(taskId).update(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getAssignedTasks(String employeeId) async {
    try {
      final query = await firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: employeeId)
          .get();

      // Sort in memory instead of using Firestore orderBy
      final tasks =
          query.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<TaskModel>> getTasksAssignedByManager(String managerId) async {
    try {
      final query = await firestore
          .collection('tasks')
          .where('assignedBy', isEqualTo: managerId)
          .get();

      // Sort in memory instead of using Firestore orderBy
      final tasks =
          query.docs.map((doc) => TaskModel.fromJson(doc.data())).toList();
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
