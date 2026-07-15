import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

final packageInfoProvider = FutureProvider<PackageInfo?>((ref) async {
  try {
    return await PackageInfo.fromPlatform();
  } catch (_) {
    return null;
  }
});

class NotificationsEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences? _prefs;

  NotificationsEnabledNotifier(this._prefs)
      : super(_prefs?.getBool('notifications_enabled') ?? true);

  Future<void> toggle() async {
    state = !state;
    await _prefs?.setBool('notifications_enabled', state);
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsEnabledNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).valueOrNull;
  return NotificationsEnabledNotifier(prefs);
});
