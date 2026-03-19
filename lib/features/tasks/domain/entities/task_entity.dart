import 'package:equatable/equatable.dart';

enum TaskStatus { pending, inProgress, submitted, approved, rejected }

class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final TaskStatus status;
  final String? feedback;
  final String? assignedTo;
  final String? assignedToName;
  final String? assignedBy;
  final String? assignedByName;

  final String organizationId;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.status,
    this.feedback,
    this.assignedTo,
    this.assignedToName,
    this.assignedBy,
    this.assignedByName,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        organizationId,
        title,
        description,
        createdAt,
        status,
        feedback,
        assignedTo,
        assignedToName,
        assignedBy,
        assignedByName,
      ];
}
