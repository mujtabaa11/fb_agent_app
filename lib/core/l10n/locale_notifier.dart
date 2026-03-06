/// Riverpod notifier that manages the app-wide [Locale] preference.
///
/// Reads the persisted value from [SharedPreferences] on startup and exposes
/// [setLocale] to update + persist the selection. A `null` value means
/// "use the device default".
library;

import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:template_app/l10n/app_localizations.dart';

import '../constants/storage_keys.dart';

part 'locale_notifier.g.dart';

@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Future<Locale?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(StorageKeys.locale);
    if (stored == null) return null;

    final locale = Locale(stored);
    // If the stored locale is no longer supported, fall back to device default.
    if (!AppLocalizations.supportedLocales.contains(locale)) {
      return null;
    }
    return locale;
  }

  /// Persists [locale] to [SharedPreferences] and updates provider state.
  ///
  /// Pass `null` to revert to the device default locale.
  Future<void> setLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(StorageKeys.locale);
    } else {
      await prefs.setString(StorageKeys.locale, locale.languageCode);
    }
    state = AsyncData(locale);
  }
}
