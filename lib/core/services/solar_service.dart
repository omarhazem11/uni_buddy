import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Fetches today's sunrise and sunset in local time.
/// Results are cached in SharedPreferences and re-fetched once per day.
///
/// Data sources (both free, no API key required):
///   - ipinfo.io  → device's approximate lat/lng from IP
///   - sunrise-sunset.org → accurate solar times for those coords
class SolarService {
  static const _cacheKey = 'solar_data_v1';

  static Future<({DateTime sunrise, DateTime sunset})> getTodaySolar(
    SharedPreferences prefs,
  ) async {
    final today = _dateStr(DateTime.now());

    // Return cached value if still valid for today
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      final m = jsonDecode(cached) as Map<String, dynamic>;
      if (m['date'] == today) {
        return (
          sunrise: DateTime.parse(m['sunrise'] as String),
          sunset: DateTime.parse(m['sunset'] as String),
        );
      }
    }

    // Fetch approximate coordinates from IP
    final locRes = await http
        .get(Uri.parse('https://ipinfo.io/json'))
        .timeout(const Duration(seconds: 6));
    final locData = jsonDecode(locRes.body) as Map<String, dynamic>;
    final loc = locData['loc'] as String; // "lat,lng"
    final parts = loc.split(',');
    final lat = parts[0].trim();
    final lng = parts[1].trim();

    // Fetch sunrise/sunset in UTC ISO 8601 (formatted=0)
    final sunRes = await http
        .get(Uri.parse(
            'https://api.sunrise-sunset.org/json?lat=$lat&lng=$lng&date=$today&formatted=0'))
        .timeout(const Duration(seconds: 6));
    final sunData = (jsonDecode(sunRes.body) as Map<String, dynamic>)['results']
        as Map<String, dynamic>;

    final sunrise = DateTime.parse(sunData['sunrise'] as String).toLocal();
    final sunset = DateTime.parse(sunData['sunset'] as String).toLocal();

    // Cache for today
    await prefs.setString(
      _cacheKey,
      jsonEncode({
        'date': today,
        'sunrise': sunrise.toIso8601String(),
        'sunset': sunset.toIso8601String(),
      }),
    );

    return (sunrise: sunrise, sunset: sunset);
  }

  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
