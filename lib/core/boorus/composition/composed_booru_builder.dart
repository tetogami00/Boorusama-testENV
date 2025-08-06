// Project imports:
import '../../home/custom_home.dart';
import '../engine/src/booru_builder.dart';
import '../engine/src/booru_builder_types.dart';
import 'booru_capabilities.dart';

/// BooruBuilder implementation that composes capabilities
class ComposedBooruBuilder implements BooruBuilder {
  const ComposedBooruBuilder({required this.capabilities});

  final BooruCapabilities capabilities;

  // Search-related builders (from SearchCapability)
  @override
  SearchPageBuilder get searchPageBuilder => capabilities.search.searchPageBuilder;

  @override
  TagSuggestionItemBuilder get tagSuggestionItemBuilder => capabilities.search.tagSuggestionItemBuilder;

  @override
  MetatagExtractorBuilder? get metatagExtractorBuilder => capabilities.search.metatagExtractorBuilder;

  // Post-related builders (from PostCapability)
  @override
  PostDetailsPageBuilder get postDetailsPageBuilder => capabilities.posts.postDetailsPageBuilder;

  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder => capabilities.posts.postImageDetailsUrlBuilder;

  @override
  PostStatisticsPageBuilder get postStatisticsPageBuilder => capabilities.posts.postStatisticsPageBuilder;

  @override
  PostGestureHandlerBuilder get postGestureHandlerBuilder => capabilities.posts.postGestureHandlerBuilder;

  @override
  PostDetailsUIBuilder get postDetailsUIBuilder => capabilities.posts.postDetailsUIBuilder;

  @override
  GranularRatingFilterer? get granularRatingFilterer => capabilities.posts.granularRatingFilterer;

  @override
  GranularRatingOptionsBuilder? get granularRatingOptionsBuilder => capabilities.posts.granularRatingOptionsBuilder;

  // Favorites-related builders (from FavoritesCapability)
  @override
  FavoritesPageBuilder? get favoritesPageBuilder => capabilities.favorites?.favoritesPageBuilder;

  @override
  QuickFavoriteButtonBuilder? get quickFavoriteButtonBuilder => capabilities.favorites?.quickFavoriteButtonBuilder;

  // Stubs for capabilities not yet implemented - these would come from other capabilities
  @override
  HomePageBuilder get homePageBuilder => throw UnimplementedError('HomeCapability not implemented yet');

  @override
  CreateConfigPageBuilder get createConfigPageBuilder => throw UnimplementedError('ConfigCapability not implemented yet');

  @override
  UpdateConfigPageBuilder get updateConfigPageBuilder => throw UnimplementedError('ConfigCapability not implemented yet');

  @override
  ArtistPageBuilder? get artistPageBuilder => null; // Optional capability

  @override
  CharacterPageBuilder? get characterPageBuilder => null; // Optional capability

  @override
  CommentPageBuilder? get commentPageBuilder => null; // Optional capability

  @override
  HomeViewBuilder get homeViewBuilder => throw UnimplementedError('HomeCapability not implemented yet');

  @override
  MultiSelectionActionsBuilder? get multiSelectionActionsBuilder => null; // Optional capability

  @override
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders => const {};

  @override
  ViewTagListBuilder get viewTagListBuilder => throw UnimplementedError('TagCapability not implemented yet');

  @override
  CreateUnknownBooruWidgetsBuilder get unknownBooruWidgetsBuilder => throw UnimplementedError('ConfigCapability not implemented yet');
}
