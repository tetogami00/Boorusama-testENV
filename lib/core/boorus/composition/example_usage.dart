// This file demonstrates how the new composition approach simplifies booru creation

// Example: Creating a simple Gelbooru-style booru with composition
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../configs/config.dart';
import '../../posts/post/post.dart';
import '../../tags/autocompletes/autocomplete_repository.dart';
import '../engine/src/booru_builder_types.dart';
import 'booru_capabilities.dart';
import 'capabilities/favorites_capability.dart';
import 'capabilities/post_capability.dart';
import 'capabilities/search_capability.dart';

// BEFORE (Inheritance-heavy approach):
/*
class GelbooruBuilder
    with
        UnknownMetatagsMixin,
        DefaultUnknownBooruWidgetsBuilderMixin,
        DefaultViewTagListBuilderMixin,
        DefaultTagSuggestionsItemBuilderMixin,
        DefaultMultiSelectionActionsBuilderMixin,
        DefaultHomeMixin,
        DefaultQuickFavoriteButtonBuilderMixin,
        DefaultPostImageDetailsUrlMixin,
        DefaultGranularRatingFiltererMixin,
        DefaultPostStatisticsPageBuilderMixin
    implements BooruBuilder {
  
  // 20+ method implementations required...
  @override
  SearchPageBuilder get searchPageBuilder => (context, params) => GelbooruSearchPage(params: params);
  
  @override 
  PostDetailsPageBuilder get postDetailsPageBuilder => (context, detailsContext) => GelbooruPostDetailsPage(context: detailsContext);
  
  // ... 18 more methods
}
*/

// AFTER (Composition approach):

/// Example: Simple Gelbooru implementation using composition
class SimpleGelbooruFactory {
  static BooruCapabilities create() {
    return BooruCapabilities(
      // Required capabilities
      search: DefaultSearchCapability(
        searchPageBuilder: _buildSearchPage,
        tagSuggestionItemBuilder: _buildTagSuggestion,
        autocompleteFactory: _createAutocomplete,
      ),
      
      posts: DefaultPostCapability(
        postDetailsPageBuilder: _buildPostDetails,
        postImageDetailsUrlBuilder: _buildImageUrl,
        postStatisticsPageBuilder: _buildPostStats,
        postGestureHandlerBuilder: _handlePostGesture,
        postDetailsUIBuilder: _buildPostDetailsUI(),
        postRepositoryFactory: _createPostRepository,
      ),
      
      // Optional capabilities - only include what's supported
      favorites: DefaultFavoritesCapability(
        favoritesPageBuilder: _buildFavoritesPage,
        quickFavoriteButtonBuilder: _buildQuickFavoriteButton,
        favoriteRepositoryFactory: _createFavoriteRepository,
      ),
    );
  }

  // Builder functions can be simple delegates or custom implementations
  static Widget _buildSearchPage(BuildContext context, SearchParams params) {
    return Container(); // Your search page implementation
  }

  static Widget _buildTagSuggestion(
    BooruConfigAuth config,
    AutocompleteData tag,
    bool dense,
    String currentQuery,
    ValueChanged<AutocompleteData> onItemTap,
  ) {
    return ListTile(title: Text(tag.value));
  }

  static AutocompleteRepository _createAutocomplete(BooruConfigAuth config) {
    return EmptyAutocompleteRepository(); // Your autocomplete implementation
  }

  static Widget _buildPostDetails(BuildContext context, DetailsRouteContext detailsContext) {
    return Container(); // Your post details implementation
  }

  static String _buildImageUrl(ImageQuality quality, Post post, BooruConfigViewer config) {
    return post.sampleImageUrl; // Your URL logic
  }

  static Widget _buildPostStats(BuildContext context, Iterable<Post> posts) {
    return Container(); // Your stats implementation
  }

  static bool _handlePostGesture(WidgetRef ref, String? action, Post post) {
    return false; // Your gesture handling
  }

  static PostDetailsUIBuilder _buildPostDetailsUI() {
    return const PostDetailsUIBuilder(); // Your UI configuration
  }

  static PostRepository<Post> _createPostRepository(BooruConfigSearch config) {
    throw UnimplementedError(); // Your repository implementation
  }

  static Widget _buildFavoritesPage(BuildContext context) {
    return Container(); // Your favorites page
  }

  static Widget _buildQuickFavoriteButton(BuildContext context, Post post) {
    return IconButton(
      icon: const Icon(Icons.favorite_border),
      onPressed: () {}, // Your favorite logic
    );
  }

  static FavoriteRepository<Post> _createFavoriteRepository(BooruConfigAuth config) {
    throw UnimplementedError(); // Your favorite repository
  }
}

/// Usage example:
void exampleUsage() {
  // Create booru with composition
  final capabilities = SimpleGelbooruFactory.create();
  
  // Validate dependencies
  if (!capabilities.areAllDependenciesMet) {
    print('Missing dependencies: ${capabilities.missingDependencies}');
    return;
  }
  
  // Compose into a BooruBuilder
  final builder = capabilities.compose();
  
  // The builder can now be used like any BooruBuilder
  // but was created through composition instead of inheritance
}

/// Example: Even simpler booru with minimal features
class MinimalBooruFactory {
  static BooruCapabilities createMinimal() {
    return BooruCapabilities(
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
      
      // No favorites capability - not supported by this booru
    );
  }
}

/// Benefits of composition approach:
/// 1. Only implement what you need - no 20+ method requirement
/// 2. Type-safe feature checking - capabilities.favorites?.favoritesPageBuilder
/// 3. Dependency validation - automatic checking of capability dependencies  
/// 4. Reusable components - capabilities can be shared between boorus
/// 5. Testing isolation - each capability can be unit tested separately
/// 6. Future extensibility - new capabilities don't break existing code