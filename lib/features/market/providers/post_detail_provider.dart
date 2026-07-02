library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/data/result.dart';
import '../models/market_post_model.dart';
import 'market_feed_provider.dart';

part 'post_detail_provider.g.dart';

@riverpod
Stream<MarketPostModel?> postDetail(PostDetailRef ref, String postId) {
  final repo = ref.watch(marketRepositoryProvider);
  return repo.watchPost(postId).map((result) {
    return switch (result) {
      Success(:final value) => value,
      Failure(:final exception) => throw exception,
    };
  });
}
