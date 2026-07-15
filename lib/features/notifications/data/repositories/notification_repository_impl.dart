import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;

  const NotificationRepositoryImpl({required NotificationRemoteDataSource dataSource})
      : _dataSource = dataSource; // ignore: prefer_initializing_formals

  @override
  Stream<List<NotificationEntity>> watchNotifications() {
    try {
      return _dataSource.watchNotifications();
    } catch (e) {
      return Stream.error(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addNotificationRecord(NotificationEntity notification) async {
    try {
      await _dataSource.addNotificationRecord(notification);
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _dataSource.markAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(NotificationFailure(e.toString()));
    }
  }
}
