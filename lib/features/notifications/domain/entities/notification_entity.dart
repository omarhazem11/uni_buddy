import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String taskId;
  final String title;
  final String body;
  final DateTime scheduledFor;
  final bool wasRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.taskId,
    required this.title,
    required this.body,
    required this.scheduledFor,
    required this.wasRead,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? wasRead}) => NotificationEntity(
        id: id,
        taskId: taskId,
        title: title,
        body: body,
        scheduledFor: scheduledFor,
        wasRead: wasRead ?? this.wasRead,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, taskId, title, body, scheduledFor, wasRead, createdAt];
}
