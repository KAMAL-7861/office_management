import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.userId,
    required super.organizationId,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.status,
    super.feedback,
    super.assignedTo,
    super.assignedToName,
    super.assignedBy,
    super.assignedByName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      organizationId: json['organizationId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String? ?? ''),
        orElse: () => TaskStatus.pending,
      ),
      feedback: json['feedback'] as String?,
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      assignedBy: json['assignedBy'] as String?,
      assignedByName: json['assignedByName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'organizationId': organizationId,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.toString().split('.').last,
      'feedback': feedback,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'assignedBy': assignedBy,
      'assignedByName': assignedByName,
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      userId: entity.userId,
      organizationId: entity.organizationId,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      status: entity.status,
      feedback: entity.feedback,
      assignedTo: entity.assignedTo,
      assignedToName: entity.assignedToName,
      assignedBy: entity.assignedBy,
      assignedByName: entity.assignedByName,
    );
  }
}
