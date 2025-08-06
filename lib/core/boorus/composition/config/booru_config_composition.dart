// Project imports:
import '../../../configs/config.dart';
import '../../../posts/rating/rating.dart';

/// Composable configuration for booru features
class BooruFeatureConfig {
  const BooruFeatureConfig({
    this.search,
    this.posts,
    this.favorites,
    this.auth,
    this.rating,
    this.comments,
    this.artists,
    this.characters,
  });

  /// Search configuration
  final SearchConfig? search;
  
  /// Post configuration
  final PostConfig? posts;
  
  /// Favorites configuration
  final FavoriteConfig? favorites;
  
  /// Authentication configuration
  final AuthConfig? auth;
  
  /// Rating configuration
  final RatingConfig? rating;
  
  /// Comments configuration
  final CommentConfig? comments;
  
  /// Artists configuration
  final ArtistConfig? artists;
  
  /// Characters configuration
  final CharacterConfig? characters;

  /// Get set of available features based on configured components
  Set<BooruFeature> get availableFeatures {
    final features = <BooruFeature>{};
    
    if (search != null) features.add(BooruFeature.search);
    if (posts != null) features.add(BooruFeature.posts);
    if (favorites != null) features.add(BooruFeature.favorites);
    if (auth != null) features.add(BooruFeature.auth);
    if (rating != null) features.add(BooruFeature.rating);
    if (comments != null) features.add(BooruFeature.comments);
    if (artists != null) features.add(BooruFeature.artists);
    if (characters != null) features.add(BooruFeature.characters);
    
    return features;
  }

  /// Check if a specific feature is available
  bool hasFeature(BooruFeature feature) => availableFeatures.contains(feature);

  /// Merge with another configuration, preferring values from other
  BooruFeatureConfig merge(BooruFeatureConfig other) {
    return BooruFeatureConfig(
      search: other.search ?? search,
      posts: other.posts ?? posts,
      favorites: other.favorites ?? favorites,
      auth: other.auth ?? auth,
      rating: other.rating ?? rating,
      comments: other.comments ?? comments,
      artists: other.artists ?? artists,
      characters: other.characters ?? characters,
    );
  }

  /// Create a copy with some values replaced
  BooruFeatureConfig copyWith({
    SearchConfig? search,
    PostConfig? posts,
    FavoriteConfig? favorites,
    AuthConfig? auth,
    RatingConfig? rating,
    CommentConfig? comments,
    ArtistConfig? artists,
    CharacterConfig? characters,
  }) {
    return BooruFeatureConfig(
      search: search ?? this.search,
      posts: posts ?? this.posts,
      favorites: favorites ?? this.favorites,
      auth: auth ?? this.auth,
      rating: rating ?? this.rating,
      comments: comments ?? this.comments,
      artists: artists ?? this.artists,
      characters: characters ?? this.characters,
    );
  }
}

/// Available booru features
enum BooruFeature {
  search,
  posts,
  favorites,
  auth,
  rating,
  comments,
  artists,
  characters,
}

/// Configuration for search functionality
class SearchConfig {
  const SearchConfig({
    this.supportsWildcards = false,
    this.supportsNegation = true,
    this.supportsQuoting = false,
    this.maxSearchTerms,
    this.autocompleteEnabled = true,
  });

  final bool supportsWildcards;
  final bool supportsNegation;
  final bool supportsQuoting;
  final int? maxSearchTerms;
  final bool autocompleteEnabled;
}

/// Configuration for post functionality
class PostConfig {
  const PostConfig({
    this.supportsNotes = false,
    this.supportsComments = false,
    this.supportsVoting = false,
    this.supportedFormats = const ['jpg', 'png', 'gif'],
    this.maxFileSize,
  });

  final bool supportsNotes;
  final bool supportsComments;
  final bool supportsVoting;
  final List<String> supportedFormats;
  final int? maxFileSize;
}

/// Configuration for favorites functionality
class FavoriteConfig {
  const FavoriteConfig({
    this.requiresAuth = true,
    this.supportsPublicFavorites = false,
    this.supportsCategories = false,
  });

  final bool requiresAuth;
  final bool supportsPublicFavorites;
  final bool supportsCategories;
}

/// Configuration for authentication
class AuthConfig {
  const AuthConfig({
    this.requiresApiKey = false,
    this.supportsOAuth = false,
    this.supportsGuest = true,
  });

  final bool requiresApiKey;
  final bool supportsOAuth;
  final bool supportsGuest;
}

/// Configuration for rating system
class RatingConfig {
  const RatingConfig({
    this.supportedRatings = const [Rating.general, Rating.sensitive, Rating.questionable, Rating.explicit],
    this.defaultRating = Rating.general,
    this.requiresAuth = false,
  });

  final List<Rating> supportedRatings;
  final Rating defaultRating;
  final bool requiresAuth;
}

/// Configuration for comments
class CommentConfig {
  const CommentConfig({
    this.supportsReplies = false,
    this.supportsVoting = false,
    this.requiresAuth = true,
  });

  final bool supportsReplies;
  final bool supportsVoting;
  final bool requiresAuth;
}

/// Configuration for artists
class ArtistConfig {
  const ArtistConfig({
    this.supportsAliases = false,
    this.supportsUrls = true,
  });

  final bool supportsAliases;
  final bool supportsUrls;
}

/// Configuration for characters
class CharacterConfig {
  const CharacterConfig({
    this.supportsAliases = false,
    this.supportsSeries = true,
  });

  final bool supportsAliases;
  final bool supportsSeries;
}

/// Factory for common booru configuration patterns
class BooruConfigCompositions {
  /// Configuration for basic imageboards (Gelbooru-style)
  static BooruFeatureConfig basicImageboard() {
    return const BooruFeatureConfig(
      search: SearchConfig(
        supportsWildcards: true,
        supportsNegation: true,
        autocompleteEnabled: true,
      ),
      posts: PostConfig(
        supportsComments: true,
        supportsVoting: true,
      ),
      rating: RatingConfig(),
    );
  }

  /// Configuration for full-featured boorus (Danbooru-style)
  static BooruFeatureConfig fullFeatured() {
    return const BooruFeatureConfig(
      search: SearchConfig(
        supportsWildcards: true,
        supportsNegation: true,
        supportsQuoting: true,
        autocompleteEnabled: true,
      ),
      posts: PostConfig(
        supportsNotes: true,
        supportsComments: true,
        supportsVoting: true,
      ),
      favorites: FavoriteConfig(
        requiresAuth: true,
        supportsPublicFavorites: true,
      ),
      auth: AuthConfig(
        requiresApiKey: true,
        supportsGuest: true,
      ),
      rating: RatingConfig(),
      comments: CommentConfig(
        supportsReplies: true,
        supportsVoting: true,
      ),
      artists: ArtistConfig(
        supportsAliases: true,
        supportsUrls: true,
      ),
      characters: CharacterConfig(
        supportsAliases: true,
        supportsSeries: true,
      ),
    );
  }

  /// Configuration for minimal boorus (read-only)
  static BooruFeatureConfig minimal() {
    return const BooruFeatureConfig(
      search: SearchConfig(
        autocompleteEnabled: false,
      ),
      posts: PostConfig(),
      rating: RatingConfig(
        supportedRatings: [Rating.general],
      ),
    );
  }
}