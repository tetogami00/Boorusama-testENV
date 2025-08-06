// Project imports:
import '../engine/src/booru_builder.dart';
import 'capabilities/base_capability.dart';
import 'capabilities/favorites_capability.dart';
import 'capabilities/post_capability.dart';
import 'capabilities/search_capability.dart';
import 'composed_booru_builder.dart';

/// Container for all booru capabilities using composition
class BooruCapabilities {
  const BooruCapabilities({
    required this.search,
    required this.posts,
    this.favorites,
    this.artist,
    this.character,
    this.comment,
    this.multiSelection,
    this.home,
  });

  /// Required search capability
  final SearchCapability search;
  
  /// Required post capability
  final PostCapability posts;
  
  /// Optional favorites capability
  final FavoritesCapability? favorites;
  
  /// Optional artist capability
  final BooruCapability? artist;
  
  /// Optional character capability
  final BooruCapability? character;
  
  /// Optional comment capability
  final BooruCapability? comment;
  
  /// Optional multi-selection capability
  final BooruCapability? multiSelection;
  
  /// Optional custom home views capability
  final BooruCapability? home;

  /// Get all available capabilities
  List<BooruCapability> get allCapabilities => [
    search,
    posts,
    if (favorites != null) favorites!,
    if (artist != null) artist!,
    if (character != null) character!,
    if (comment != null) comment!,
    if (multiSelection != null) multiSelection!,
    if (home != null) home!,
  ];

  /// Get capability IDs that are available
  Set<String> get availableCapabilityIds => 
    allCapabilities.map((c) => c.id).toSet();

  /// Validate that all capability dependencies are met
  bool get areAllDependenciesMet {
    for (final capability in allCapabilities) {
      if (!capability.canEnable(availableCapabilityIds)) {
        return false;
      }
    }
    return true;
  }

  /// Get list of missing dependencies
  List<String> get missingDependencies {
    final missing = <String>[];
    for (final capability in allCapabilities) {
      for (final dependency in capability.dependencies) {
        if (!availableCapabilityIds.contains(dependency)) {
          missing.add('${capability.id} requires $dependency');
        }
      }
    }
    return missing;
  }

  /// Compose capabilities into a unified BooruBuilder
  BooruBuilder compose() {
    if (!areAllDependenciesMet) {
      throw StateError(
        'Cannot compose booru with missing dependencies: ${missingDependencies.join(', ')}'
      );
    }
    
    return ComposedBooruBuilder(capabilities: this);
  }
}
