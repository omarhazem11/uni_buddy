import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/solar_service.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

/// Solar-aware greeting. Falls back to clock-only if offline or on first load.
final greetingProvider = FutureProvider<String>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  try {
    final solar = await SolarService.getTodaySolar(prefs);
    return _solarGreeting(solar.sunrise, solar.sunset);
  } catch (_) {
    return clockGreeting();
  }
});

/// Clock-only fallback — safe to call synchronously anywhere.
String clockGreeting() {
  final h = DateTime.now().hour;
  if (h < 5) return 'Good night';
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  if (h < 21) return 'Good evening';
  return 'Good night';
}

String _solarGreeting(DateTime sunrise, DateTime sunset) {
  final now = DateTime.now();
  final noon = DateTime(now.year, now.month, now.day, 12);

  // Before sunrise → night
  if (now.isBefore(sunrise)) return 'Good night';
  // Sunrise → noon → morning
  if (now.isBefore(noon)) return 'Good morning';
  // Noon → 2 h before sunset → afternoon
  if (now.isBefore(sunset.subtract(const Duration(hours: 2)))) return 'Good afternoon';
  // 2 h before sunset → 1 h after sunset → evening
  if (now.isBefore(sunset.add(const Duration(hours: 1)))) return 'Good evening';
  // Beyond 1 h after sunset → night
  return 'Good night';
}
