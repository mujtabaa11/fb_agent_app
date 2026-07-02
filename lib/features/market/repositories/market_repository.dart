library;

import '../../../core/data/result.dart';
import '../models/market_post_model.dart';

abstract class MarketRepository {
  Stream<Result<List<MarketPostModel>>> watchMarketFeed();
}
