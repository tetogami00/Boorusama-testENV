// This file provides a migration guide from the old inheritance-heavy
// BooruBuilder approach to the new composition-based approach

import 'package:flutter/material.dart';

import '../../../configs/config.dart';
import '../../../posts/post/post.dart';
import '../../../tags/autocompletes/autocomplete_repository.dart';
import '../../engine/src/booru_builder_types.dart';
import '../booru_capabilities.dart';
import '../capabilities/favorites_capability.dart';
import '../capabilities/post_capability.dart';
import '../capabilities/search_capability.dart';
import '../config/booru_config_composition.dart';

/// Migration helper that converts old BooruBuilder implementations
/// to new composition-based approach
class BooruMigrationHelper {
  /// Convert existing mixin-heavy builder to composition approach
  /// 
  /// Example usage:
  /// ```dart
  /// // OLD: 
  /// class GelbooruBuilder with DefaultMultiSelectionActionsBuilderMixin, ...
  /// 
  /// // NEW:
  /// final capabilities = BooruMigrationHelper.fromLegacyBuilder(
  ///   legacyBuilder: oldGelbooruBuilder,
  ///   config: BooruConfigCompositions.basicImageboard(),
  /// );
  /// final newBuilder = capabilities.compose();
  /// ```
  static BooruCapabilities fromLegacyBuilder({
    required dynamic legacyBuilder, // The old BooruBuilder implementation
    required BooruFeatureConfig config,
  }) {
    return BooruCapabilities(
      search: _extractSearchCapability(legacyBuilder, config),
      posts: _extractPostCapability(legacyBuilder, config),
      favorites: config.hasFeature(BooruFeature.favorites)
          ? _extractFavoritesCapability(legacyBuilder, config)
          : null,
    );
  }

  /// Extract search capability from legacy builder
  static SearchCapability _extractSearchCapability(
    dynamic legacyBuilder,
    BooruFeatureConfig config,
  ) {
    return DefaultSearchCapability(
      searchPageBuilder: _getSearchPageBuilder(legacyBuilder),
      tagSuggestionItemBuilder: _getTagSuggestionItemBuilder(legacyBuilder),
      autocompleteFactory: _getAutocompleteFactory(legacyBuilder),
      metatagExtractorBuilder: _getMetatagExtractorBuilder(legacyBuilder),
    );
  }

  /// Extract post capability from legacy builder
  static PostCapability _extractPostCapability(
    dynamic legacyBuilder,
    BooruFeatureConfig config,
  ) {
    return DefaultPostCapability(
      postDetailsPageBuilder: _getPostDetailsPageBuilder(legacyBuilder),
      postImageDetailsUrlBuilder: _getPostImageDetailsUrlBuilder(legacyBuilder),
      postStatisticsPageBuilder: _getPostStatisticsPageBuilder(legacyBuilder),
      postGestureHandlerBuilder: _getPostGestureHandlerBuilder(legacyBuilder),
      postDetailsUIBuilder: _getPostDetailsUIBuilder(legacyBuilder),
      postRepositoryFactory: _getPostRepositoryFactory(legacyBuilder),
      granularRatingFilterer: _getGranularRatingFilterer(legacyBuilder),
      granularRatingOptionsBuilder: _getGranularRatingOptionsBuilder(legacyBuilder),
    );
  }

  /// Extract favorites capability from legacy builder
  static FavoritesCapability? _extractFavoritesCapability(
    dynamic legacyBuilder,
    BooruFeatureConfig config,
  ) {
    // Only extract if legacy builder supports favorites
    if (!_hasMethod(legacyBuilder, 'favoritesPageBuilder')) {
      return null;
    }

    return DefaultFavoritesCapability(
      favoritesPageBuilder: _getFavoritesPageBuilder(legacyBuilder),
      quickFavoriteButtonBuilder: _getQuickFavoriteButtonBuilder(legacyBuilder),
      favoriteRepositoryFactory: _getFavoriteRepositoryFactory(legacyBuilder),
    );
  }

  // Helper methods to extract specific builders from legacy implementations
  // These would use reflection or manual delegation in a real implementation

  static SearchPageBuilder _getSearchPageBuilder(dynamic legacyBuilder) {
    return (context, params) {
      // In real implementation, this would call legacyBuilder.searchPageBuilder
      return Container(); // Placeholder
    };
  }

  static TagSuggestionItemBuilder _getTagSuggestionItemBuilder(dynamic legacyBuilder) {
    return (config, tag, dense, query, onTap) {
      // In real implementation, this would call legacyBuilder.tagSuggestionItemBuilder
      return ListTile(title: Text(tag.value));
    };
  }

  static AutocompleteRepository Function(BooruConfigAuth) _getAutocompleteFactory(dynamic legacyBuilder) {
    return (config) {
      // In real implementation, this would use the legacy builder's autocomplete logic
      return EmptyAutocompleteRepository();
    };
  }

  static MetatagExtractorBuilder? _getMetatagExtractorBuilder(dynamic legacyBuilder) {
    if (!_hasMethod(legacyBuilder, 'metatagExtractorBuilder')) return null;
    // Return extracted builder
    return null; // Placeholder
  }

  static PostDetailsPageBuilder _getPostDetailsPageBuilder(dynamic legacyBuilder) {
    return (context, detailsContext) => Container(); // Placeholder
  }

  static PostImageDetailsUrlBuilder _getPostImageDetailsUrlBuilder(dynamic legacyBuilder) {
    return (quality, post, config) => post.sampleImageUrl; // Placeholder
  }

  static PostStatisticsPageBuilder _getPostStatisticsPageBuilder(dynamic legacyBuilder) {
    return (context, posts) => Container(); // Placeholder
  }

  static PostGestureHandlerBuilder _getPostGestureHandlerBuilder(dynamic legacyBuilder) {
    return (ref, action, post) => false; // Placeholder
  }

  static PostDetailsUIBuilder _getPostDetailsUIBuilder(dynamic legacyBuilder) {
    return const PostDetailsUIBuilder(); // Placeholder
  }

  static PostRepository<Post> Function(BooruConfigSearch) _getPostRepositoryFactory(dynamic legacyBuilder) {
    return (config) => throw UnimplementedError(); // Placeholder
  }

  static GranularRatingFilterer? _getGranularRatingFilterer(dynamic legacyBuilder) {
    return null; // Placeholder
  }

  static GranularRatingOptionsBuilder? _getGranularRatingOptionsBuilder(dynamic legacyBuilder) {
    return null; // Placeholder
  }

  static FavoritesPageBuilder _getFavoritesPageBuilder(dynamic legacyBuilder) {
    return (context) => Container(); // Placeholder
  }

  static QuickFavoriteButtonBuilder _getQuickFavoriteButtonBuilder(dynamic legacyBuilder) {
    return (context, post) => Container(); // Placeholder
  }

  static FavoriteRepository<Post> Function(BooruConfigAuth) _getFavoriteRepositoryFactory(dynamic legacyBuilder) {
    return (config) => throw UnimplementedError(); // Placeholder
  }

  /// Check if a dynamic object has a specific method
  static bool _hasMethod(dynamic obj, String methodName) {
    // In real implementation, this would use reflection
    return false; // Placeholder
  }
}

/// Step-by-step migration examples
class MigrationExamples {
  /// Example 1: Migrating a simple Gelbooru-style booru
  /// 
  /// BEFORE:
  /// ```dart
  /// class MyGelbooruBuilder
  ///     with
  ///         DefaultMultiSelectionActionsBuilderMixin,
  ///         DefaultHomeMixin,
  ///         DefaultQuickFavoriteButtonBuilderMixin,
  ///         DefaultPostImageDetailsUrlMixin,
  ///         DefaultGranularRatingFiltererMixin
  ///     implements BooruBuilder {
  ///   
  ///   @override
  ///   SearchPageBuilder get searchPageBuilder => ...;
  ///   // ... 20+ more method implementations
  /// }
  /// ```
  /// 
  /// AFTER:
  static BooruCapabilities migrateSimpleGelbooru() {
    return BooruCapabilities(
      search: DefaultSearchCapability(
        searchPageBuilder: (context, params) => Container(), // Your search page
        tagSuggestionItemBuilder: (config, tag, dense, query, onTap) => 
          ListTile(title: Text(tag.value)), // Your tag suggestions
        autocompleteFactory: (config) => EmptyAutocompleteRepository(), // Your autocomplete
      ),
      
      posts: DefaultPostCapability(
        postDetailsPageBuilder: (context, details) => Container(), // Your post details
        postImageDetailsUrlBuilder: (quality, post, config) => post.sampleImageUrl,
        postStatisticsPageBuilder: (context, posts) => Container(),
        postGestureHandlerBuilder: (ref, action, post) => false,
        postDetailsUIBuilder: const PostDetailsUIBuilder(),
        postRepositoryFactory: (config) => throw UnimplementedError(),
      ),
      
      // Only include features that are actually supported
      favorites: DefaultFavoritesCapability(
        favoritesPageBuilder: (context) => Container(),
        quickFavoriteButtonBuilder: (context, post) => 
          IconButton(icon: const Icon(Icons.favorite), onPressed: () {}),
        favoriteRepositoryFactory: (config) => throw UnimplementedError(),
      ),
    );
  }

  /// Example 2: Benefits of composition approach
  static void demonstrateBenefits() {
    // 1. Mix and match capabilities
    final basicBooru = BooruCapabilities(
      search: DefaultSearchCapability(
        searchPageBuilder: (context, params) => Container(),
        tagSuggestionItemBuilder: (config, tag, dense, query, onTap) => ListTile(title: Text(tag.value)),
        autocompleteFactory: (config) => EmptyAutocompleteRepository(),
      ),
      posts: DefaultPostCapability(
        postDetailsPageBuilder: (context, details) => Container(),
        postImageDetailsUrlBuilder: (quality, post, config) => post.sampleImageUrl,
        postStatisticsPageBuilder: (context, posts) => Container(),
        postGestureHandlerBuilder: (ref, action, post) => false,
        postDetailsUIBuilder: const PostDetailsUIBuilder(),
        postRepositoryFactory: (config) => throw UnimplementedError(),
      ),
      // No favorites capability - not supported
    );

    // 2. Validate dependencies automatically
    if (!basicBooru.areAllDependenciesMet) {
      print('Missing dependencies: ${basicBooru.missingDependencies}');
      return;
    }

    // 3. Type-safe feature checking
    final hasFavorites = basicBooru.favorites != null;
    print('Supports favorites: $hasFavorites');

    // 4. Easy to extend with new capabilities
    // Just add them to the BooruCapabilities constructor!
    
    // 5. Reusable components
    final searchCapability = basicBooru.search; // Can be reused in other boorus
    
    // 6. Clean composition
    final builder = basicBooru.compose();
    // builder is now a fully functional BooruBuilder created through composition
  }
}

/// Migration checklist for converting existing BooruBuilder implementations
/// 
/// Step 1: Identify Required Capabilities
/// - Does your booru support search? -> SearchCapability required
/// - Does your booru support posts? -> PostCapability required (always)
/// - Does your booru support favorites? -> FavoritesCapability optional
/// - Does your booru support artists? -> ArtistCapability optional
/// - Does your booru support comments? -> CommentCapability optional
/// 
/// Step 2: Extract Implementation Methods
/// - Move searchPageBuilder logic to SearchCapability
/// - Move postDetailsPageBuilder logic to PostCapability
/// - Move favorites logic to FavoritesCapability (if supported)
/// 
/// Step 3: Create Configuration
/// - Define BooruFeatureConfig with supported features
/// - Use predefined compositions or create custom config
/// 
/// Step 4: Compose Capabilities
/// - Create BooruCapabilities with your capability implementations
/// - Validate dependencies with areAllDependenciesMet
/// - Call compose() to get final BooruBuilder
/// 
/// Step 5: Test and Validate
/// - Ensure all features work as expected
/// - Verify that unsupported features are properly excluded
/// - Test capability dependency validation
/// 
/// Benefits After Migration:
/// - Reduced boilerplate (no more 20+ method implementations)
/// - Type-safe feature detection
/// - Automatic dependency validation
/// - Easier testing (test capabilities in isolation)
/// - Better code reuse between boorus
/// - Clear separation of concerns