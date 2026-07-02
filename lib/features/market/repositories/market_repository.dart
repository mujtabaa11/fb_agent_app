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

  /// Streams every post owned by [agentId], regardless of status or
  /// expiry, ordered by most recently created first.
  Stream<Result<List<MarketPostModel>>> watchMyPosts(String agentId);

  /// Streams active (non-closed) posts owned by [agentId], ordered by most
  /// recently created first. Expiry is not filtered server-side — callers
  /// should exclude expired posts client-side.
  Stream<Result<List<MarketPostModel>>> watchAgentActivePosts(
    String agentId,
  );

  /// Marks the post at [postId] as closed. Does not delete the document.
  Future<Result<void>> closePost(String postId);

  /// Deletes the post at [postId] and best-effort deletes its photo from
  /// storage. Storage failures never fail the overall result.
  Future<Result<void>> deletePost(String postId);
}
