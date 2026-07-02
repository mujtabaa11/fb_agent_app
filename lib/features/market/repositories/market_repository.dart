library;

import '../../../core/data/result.dart';
import '../models/market_post_model.dart';

abstract class MarketRepository {
  Stream<Result<List<MarketPostModel>>> watchMarketFeed();

  /// Streams a single post by [postId]. Emits `Success(null)` if the
  /// document does not exist.
  Stream<Result<MarketPostModel?>> watchPost(String postId);

  /// Reserves a new document id for a post before it is created, so callers
  /// can upload post-scoped assets (e.g. a player photo) to a storage path
  /// keyed by the id ahead of the Firestore write.
  String generatePostId();

  Future<Result<MarketPostModel>> createPost(MarketPostModel post);
}
