/// Riverpod providers for Firestore-backed repositories.
///
/// Each feature registers its repository here, exposing the abstract
/// [BaseRepository<T>] interface while wiring the concrete
/// [FirestoreRepository<T>] behind the scenes.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/profile/data/user_profile_model.dart';
import 'base_repository.dart';
import 'firestore_repository.dart';

part 'repository_providers.g.dart';

/// Provides a [BaseRepository] for [UserProfileModel] documents
/// stored in the `users` Firestore collection.
@Riverpod(keepAlive: true)
BaseRepository<UserProfileModel> userProfileRepository(
  UserProfileRepositoryRef ref,
) =>
    FirestoreRepository<UserProfileModel>(
      collectionPath: 'users',
      fromJson: UserProfileModel.fromJson,
      toJson: (model) => model.toJson(),
    );
