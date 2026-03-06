import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_service.dart';

/// [StorageService] backed by [SharedPreferences].
///
/// Use for non-sensitive data: theme preference, locale, UI settings.
/// All errors are caught and logged — callers never see exceptions.
class PrefsStorageService implements StorageService {
  @override
  Future<void> write(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('PrefsStorage error [write]: $e');
    }
  }

  @override
  Future<String?> read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      debugPrint('PrefsStorage error [read]: $e');
      return null;
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } catch (e) {
      debugPrint('PrefsStorage error [delete]: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('PrefsStorage error [clear]: $e');
    }
  }
}
