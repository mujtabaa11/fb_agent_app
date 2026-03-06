/// Riverpod provider for cloud file storage.
///
/// Registers [FirebaseStorageService] against the [BaseStorageService]
/// interface. Feature code must inject [BaseStorageService] — never
/// [FirebaseStorageService].
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'base_storage_service.dart';
import 'firebase_storage_service.dart';

part 'cloud_storage_providers.g.dart';

@Riverpod(keepAlive: true)
BaseStorageService cloudStorage(CloudStorageRef ref) {
  return FirebaseStorageService();
}
