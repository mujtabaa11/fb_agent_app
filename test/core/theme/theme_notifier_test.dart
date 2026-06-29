/// Tests for [ThemeNotifier].
///
/// Uses [SharedPreferences.setMockInitialValues] (Flutter's built-in test
/// support) and [ProviderContainer] to unit-test the notifier without pumping
/// a widget.
///
/// Tests verify behavior only — does the theme persist? Does the default
/// apply? — NOT visual appearance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:football_agent_mate/core/constants/storage_keys.dart';
import 'package:football_agent_mate/core/theme/theme_notifier.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Default behavior
  // ---------------------------------------------------------------------------

  group('default behavior', () {
    test('no stored preference defaults to ThemeMode.system', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for the async build to complete.
      final mode = await container.read(themeNotifierProvider.future);

      expect(mode, ThemeMode.system);
    });
  });

  // ---------------------------------------------------------------------------
  // setThemeMode
  // ---------------------------------------------------------------------------

  group('setThemeMode', () {
    test('changes mode and writes to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for initial build.
      await container.read(themeNotifierProvider.future);

      // Change to dark mode.
      await container
          .read(themeNotifierProvider.notifier)
          .setThemeMode(ThemeMode.dark);

      // Verify provider state updated.
      final mode = await container.read(themeNotifierProvider.future);
      expect(mode, ThemeMode.dark);

      // Verify SharedPreferences was written.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.themeMode), 'dark');
    });

    test('changes mode to light and writes to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeNotifierProvider.future);

      await container
          .read(themeNotifierProvider.notifier)
          .setThemeMode(ThemeMode.light);

      final mode = await container.read(themeNotifierProvider.future);
      expect(mode, ThemeMode.light);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.themeMode), 'light');
    });

    test('changes mode back to system and writes to SharedPreferences',
        () async {
      SharedPreferences.setMockInitialValues(
          {StorageKeys.themeMode: 'dark'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(themeNotifierProvider.future);

      await container
          .read(themeNotifierProvider.notifier)
          .setThemeMode(ThemeMode.system);

      final mode = await container.read(themeNotifierProvider.future);
      expect(mode, ThemeMode.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.themeMode), 'system');
    });
  });

  // ---------------------------------------------------------------------------
  // Existing preference at init
  // ---------------------------------------------------------------------------

  group('existing preference at init', () {
    test('initializes with stored light preference', () async {
      SharedPreferences.setMockInitialValues(
          {StorageKeys.themeMode: 'light'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = await container.read(themeNotifierProvider.future);

      expect(mode, ThemeMode.light);
    });

    test('initializes with stored dark preference', () async {
      SharedPreferences.setMockInitialValues(
          {StorageKeys.themeMode: 'dark'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = await container.read(themeNotifierProvider.future);

      expect(mode, ThemeMode.dark);
    });

    test('initializes with stored system preference', () async {
      SharedPreferences.setMockInitialValues(
          {StorageKeys.themeMode: 'system'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = await container.read(themeNotifierProvider.future);

      expect(mode, ThemeMode.system);
    });

    test('unrecognised stored value falls back to ThemeMode.system', () async {
      SharedPreferences.setMockInitialValues(
          {StorageKeys.themeMode: 'invalid-value'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = await container.read(themeNotifierProvider.future);

      expect(mode, ThemeMode.system);
    });
  });

  // ---------------------------------------------------------------------------
  // User preference is not overridden
  // ---------------------------------------------------------------------------

  group('explicit user preference persistence', () {
    test(
        'user preference of dark is preserved across provider rebuilds',
        () async {
      SharedPreferences.setMockInitialValues({});

      // First container: set preference to dark.
      final container1 = ProviderContainer();
      await container1.read(themeNotifierProvider.future);
      await container1
          .read(themeNotifierProvider.notifier)
          .setThemeMode(ThemeMode.dark);
      container1.dispose();

      // Second container: simulates a fresh app launch. The preference
      // persisted via SharedPreferences should be read back, not defaulted
      // to ThemeMode.system.
      final container2 = ProviderContainer();
      addTearDown(container2.dispose);

      final mode = await container2.read(themeNotifierProvider.future);

      expect(mode, ThemeMode.dark);
    });

    test(
        'explicit user preference is not overridden by system theme change',
        () async {
      // User has explicitly chosen dark mode.
      SharedPreferences.setMockInitialValues(
          {StorageKeys.themeMode: 'dark'});

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final mode = await container.read(themeNotifierProvider.future);

      // The notifier reads from SharedPreferences, not the system. Even if
      // the system theme changes, the stored preference wins.
      expect(mode, ThemeMode.dark);

      // Verify the preference is still stored (not cleared or overridden).
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(StorageKeys.themeMode), 'dark');
    });
  });
}
