// Project imports:
import '../../../configs/config.dart';
import '../../../posts/post/post.dart';
import '../../engine/src/booru_builder_types.dart';
import 'base_capability.dart';

/// Capability for post-related functionality
abstract class PostCapability extends BooruCapability {
  @override
  String get id => 'posts';
  
  @override
  String get name => 'Posts';
  
  @override
  bool get isRequired => true;

  /// Builder for the post details page
  PostDetailsPageBuilder get postDetailsPageBuilder;
  
  /// Builder for post image details URL
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder;
  
  /// Builder for post statistics page
  PostStatisticsPageBuilder get postStatisticsPageBuilder;
  
  /// Post gesture handler builder
  PostGestureHandlerBuilder get postGestureHandlerBuilder;
  
  /// Post details UI builder
  PostDetailsUIBuilder get postDetailsUIBuilder;
  
  /// Post repository factory
  PostRepository<Post> postRepository(BooruConfigSearch config);
  
  /// Optional granular rating filterer
  GranularRatingFilterer? get granularRatingFilterer => null;
  
  /// Optional granular rating options builder
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => null;
}

/// Default implementation of PostCapability
class DefaultPostCapability extends PostCapability {
  DefaultPostCapability({
    required this.postDetailsPageBuilder,
    required this.postImageDetailsUrlBuilder,
    required this.postStatisticsPageBuilder,
    required this.postGestureHandlerBuilder,
    required this.postDetailsUIBuilder,
    required this.postRepositoryFactory,
    this.granularRatingFilterer,
    this.granularRatingOptionsBuilder,
  });

  @override
  final PostDetailsPageBuilder postDetailsPageBuilder;
  
  @override
  final PostImageDetailsUrlBuilder postImageDetailsUrlBuilder;
  
  @override
  final PostStatisticsPageBuilder postStatisticsPageBuilder;
  
  @override
  final PostGestureHandlerBuilder postGestureHandlerBuilder;
  
  @override
  final PostDetailsUIBuilder postDetailsUIBuilder;
  
  @override
  final GranularRatingFilterer? granularRatingFilterer;
  
  @override
  final GranularRatingOptionsBuilder? granularRatingOptionsBuilder;
  
  final PostRepository<Post> Function(BooruConfigSearch config) postRepositoryFactory;
  
  @override
  PostRepository<Post> postRepository(BooruConfigSearch config) => postRepositoryFactory(config);
}
