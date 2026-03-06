// Use secureStorageProvider for: auth tokens, credentials, sensitive user data
// Use prefsStorageProvider for: theme preference, locale, non-sensitive settings
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'prefs_storage_service.dart';
import 'secure_storage_service.dart';
import 'storage_service.dart';

part 'storage_providers.g.dart';

@Riverpod(keepAlive: true)
StorageService secureStorage(SecureStorageRef ref) => SecureStorageService();

@Riverpod(keepAlive: true)
StorageService prefsStorage(PrefsStorageRef ref) => PrefsStorageService();
