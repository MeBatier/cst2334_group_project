import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

/// Handles saving and retrieving the last event using encrypted preferences.
class EventPreferences {
  static final _storage = EncryptedSharedPreferences();

  /// Saves the last event data to encrypted storage.
  static Future<void> saveLastEvent(Map<String, String> data) async {
    for (var entry in data.entries) {
      await _storage.setString(entry.key, entry.value);
    }
  }

  /// Loads the last saved event data from encrypted storage.
  static Future<Map<String, String>> loadLastEvent() async {
    final keys = ['name', 'location', 'description', 'date', 'time'];
    final Map<String, String> data = {};
    for (var key in keys) {
      try {
        final value = await _storage.getString(key);
        if (value != null) data[key] = value;
      } catch (_) {
        // Ignore missing key errors
      }
    }
    return data;
  }

  /// Clears all saved event data.
  static Future<void> clearLastEvent() async {
    await _storage.clear();
  }
}
