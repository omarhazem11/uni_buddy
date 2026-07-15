import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/notification_entity.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationEntity>> watchNotifications();
  Future<void> addNotificationRecord(NotificationEntity notification);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _col {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationModel.fromFirestore).toList());
  }

  @override
  Future<void> addNotificationRecord(NotificationEntity notification) async {
    await _col.doc(notification.id).set(NotificationModel.fromEntity(notification).toFirestore());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _col.doc(notificationId).update({'wasRead': true});
  }

  @override
  Future<void> markAllAsRead() async {
    final snap = await _col.where('wasRead', isEqualTo: false).get();
    if (snap.docs.isEmpty) return;
    final batch = _firestore.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'wasRead': true});
    }
    await batch.commit();
  }
}
