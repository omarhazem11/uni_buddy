import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.taskId,
    required super.title,
    required super.body,
    required super.scheduledFor,
    required super.wasRead,
    required super.createdAt,
  });

  factory NotificationModel.fromEntity(NotificationEntity e) => NotificationModel(
        id: e.id,
        taskId: e.taskId,
        title: e.title,
        body: e.body,
        scheduledFor: e.scheduledFor,
        wasRead: e.wasRead,
        createdAt: e.createdAt,
      );

  factory NotificationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return NotificationModel(
      id: doc.id,
      taskId: d['taskId'] as String,
      title: d['title'] as String,
      body: d['body'] as String,
      scheduledFor: (d['scheduledFor'] as Timestamp).toDate(),
      wasRead: d['wasRead'] as bool? ?? false,
      createdAt: (d['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'taskId': taskId,
        'title': title,
        'body': body,
        'scheduledFor': Timestamp.fromDate(scheduledFor),
        'wasRead': wasRead,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
