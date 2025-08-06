// Project imports:
import '../../../configs/config.dart';
import '../../../posts/favorites/types.dart';
import '../../../posts/post/post.dart';
import '../../engine/src/booru_builder_types.dart';
import 'base_capability.dart';

/// Capability for favorites functionality
abstract class FavoritesCapability extends BooruCapability {
  @override
  String get id => 'favorites';
  
  @override
  String get name => 'Favorites';

  @override
  List<String> get dependencies => ['posts']; // Depends on posts capability

  /// Builder for the favorites page
  FavoritesPageBuilder get favoritesPageBuilder;
  
  /// Quick favorite button builder
  QuickFavoriteButtonBuilder get quickFavoriteButtonBuilder;
  
  /// Favorite repository factory
  FavoriteRepository<Post> favoriteRepository(BooruConfigAuth config);
}

/// Default implementation of FavoritesCapability
class DefaultFavoritesCapability extends FavoritesCapability {
  DefaultFavoritesCapability({
    required this.favoritesPageBuilder,
    required this.quickFavoriteButtonBuilder,
    required this.favoriteRepositoryFactory,
  });

  @override
  final FavoritesPageBuilder favoritesPageBuilder;
  
  @override
  final QuickFavoriteButtonBuilder quickFavoriteButtonBuilder;
  
  final FavoriteRepository<Post> Function(BooruConfigAuth config) favoriteRepositoryFactory;
  
  @override
  FavoriteRepository<Post> favoriteRepository(BooruConfigAuth config) => favoriteRepositoryFactory(config);
}
