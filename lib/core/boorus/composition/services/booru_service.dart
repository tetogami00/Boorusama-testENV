// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../posts/favorites/types.dart';
import '../../../posts/post/post.dart';
import '../../../settings/src/types/types.dart';
import '../../../tags/autocompletes/autocomplete_repository.dart';

/// Service interface for composable booru data operations
abstract class BooruService {
  /// Unique identifier for this service
  String get id;
  
  /// Whether this service is available for the current configuration
  bool isAvailable(BooruConfigSearch config);
}

/// Service for post-related data operations
abstract class PostService extends BooruService {
  @override
  String get id => 'posts';

  /// Get posts repository
  PostRepository<Post> getRepository(BooruConfigSearch config);
  
  /// Get image URL for the given post
  String getImageUrl(Post post, ImageQuality quality);
  
  /// Get download URL for the given post
  String getDownloadUrl(Post post);
}

/// Service for tag-related data operations  
abstract class TagService extends BooruService {
  @override
  String get id => 'tags';

  /// Get autocomplete repository
  AutocompleteRepository getAutocompleteRepository(BooruConfigAuth config);
  
  /// Extract tags from post
  List<String> extractTags(Post post);
  
  /// Get tag color based on type
  Color? getTagColor(String tagType);
}

/// Service for favorite-related data operations
abstract class FavoriteService extends BooruService {
  @override
  String get id => 'favorites';

  /// Get favorites repository
  FavoriteRepository<Post> getRepository(BooruConfigAuth config);
  
  /// Check if favorites are supported
  bool canFavorite();
}

/// Container for all booru services using composition
class BooruServices {
  const BooruServices({
    required this.posts,
    this.tags,
    this.favorites,
    this.comments,
  });

  /// Required post service
  final PostService posts;
  
  /// Optional tag service
  final TagService? tags;
  
  /// Optional favorite service
  final FavoriteService? favorites;
  
  /// Optional comment service
  final BooruService? comments;

  /// Get all available services
  List<BooruService> get allServices => [
    posts,
    if (tags != null) tags!,
    if (favorites != null) favorites!,
    if (comments != null) comments!,
  ];

  /// Check if a service is available
  bool hasService(String serviceId) {
    return allServices.any((s) => s.id == serviceId);
  }

  /// Get service by ID
  T? getService<T extends BooruService>(String serviceId) {
    try {
      return allServices.firstWhere((s) => s.id == serviceId) as T;
    } catch (e) {
      return null;
    }
  }
}
