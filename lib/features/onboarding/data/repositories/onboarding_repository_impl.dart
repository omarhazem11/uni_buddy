import '../../domain/entities/user_type.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserType?> getUserType() async {
    final value = await remoteDataSource.getUserType();
    return UserType.fromStorageValue(value);
  }

  @override
  Future<void> setUserType(UserType type) async {
    await remoteDataSource.setUserType(type.storageValue);
  }
}
