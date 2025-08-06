# Booru Composition Architecture

This directory contains the new composition-based architecture for booru implementations, designed to replace the inheritance-heavy `BooruBuilder` approach with Flutter's composition principles.

## Problem with Current Architecture

The current `BooruBuilder` interface requires implementing 20+ abstract methods, leading to:
- Massive inheritance hierarchies with heavy mixin usage
- Boilerplate code for every new booru implementation
- Difficulty in testing individual features
- Tight coupling between unrelated functionality
- Violation of Flutter's composition-over-inheritance principle

## Solution: Capability-Based Composition

The new architecture decomposes booru functionality into **composable capabilities**:

```dart
class BooruCapabilities {
  final SearchCapability search;      // Required
  final PostCapability posts;         // Required  
  final FavoritesCapability? favorites; // Optional
  final CommentCapability? comments;    // Optional
  // ... other optional capabilities
}
```

## Core Components

### 1. Capabilities (`capabilities/`)
Each capability represents a distinct feature set:

- **`SearchCapability`** - Search functionality with autocomplete
- **`PostCapability`** - Post display and interaction
- **`FavoritesCapability`** - Favorites management
- More capabilities can be added without breaking existing code

### 2. Services (`services/`)
Composable data layer services:

- **`PostService`** - Post data operations
- **`TagService`** - Tag-related operations  
- **`FavoriteService`** - Favorite operations

### 3. Widget Components (`widgets/`)
Composable UI components:

- **`PostDetailComponents`** - Composable post detail sections
- **`SearchComponents`** - Composable search interface parts

### 4. Configuration (`config/`)
Declarative feature configuration:

- **`BooruFeatureConfig`** - Composable feature flags and settings
- **`BooruConfigCompositions`** - Predefined configuration patterns

## Usage Examples

### Simple Booru (Before vs After)

**BEFORE** (Inheritance-heavy):
```dart
class GelbooruBuilder
    with
        UnknownMetatagsMixin,
        DefaultUnknownBooruWidgetsBuilderMixin,
        DefaultViewTagListBuilderMixin,
        // ... 8 more mixins
    implements BooruBuilder {
  
  // Must implement all 20+ methods
  @override
  SearchPageBuilder get searchPageBuilder => ...;
  
  @override 
  PostDetailsPageBuilder get postDetailsPageBuilder => ...;
  
  // ... 18+ more methods
}
```

**AFTER** (Composition-based):
```dart
class SimpleGelbooruFactory {
  static BooruCapabilities create() {
    return BooruCapabilities(
      search: DefaultSearchCapability(
        searchPageBuilder: (context, params) => GelbooruSearchPage(),
        tagSuggestionItemBuilder: (config, tag, dense, query, onTap) => 
          GelbooruTagSuggestion(tag: tag),
        autocompleteFactory: (config) => GelbooruAutocompleteRepository(),
      ),
      
      posts: DefaultPostCapability(
        postDetailsPageBuilder: (context, details) => GelbooruPostDetails(),
        postImageDetailsUrlBuilder: (quality, post, config) => post.sampleImageUrl,
        // ... only the methods you need
        postRepositoryFactory: (config) => GelbooruPostRepository(),
      ),
      
      // Optional: Only include if supported
      favorites: DefaultFavoritesCapability(
        favoritesPageBuilder: (context) => GelbooruFavoritesPage(),
        quickFavoriteButtonBuilder: (context, post) => FavoriteButton(post: post),
        favoriteRepositoryFactory: (config) => GelbooruFavoriteRepository(),
      ),
    );
  }
}

// Usage
final capabilities = SimpleGelbooruFactory.create();
final builder = capabilities.compose(); // Creates BooruBuilder
```

### Minimal Read-Only Booru

```dart
final minimalBooru = BooruCapabilities(
  search: DefaultSearchCapability(
    searchPageBuilder: (context, params) => BasicSearchPage(),
    tagSuggestionItemBuilder: (config, tag, dense, query, onTap) => 
      ListTile(title: Text(tag.value)),
    autocompleteFactory: (config) => EmptyAutocompleteRepository(),
  ),
  
  posts: DefaultPostCapability(
    postDetailsPageBuilder: (context, details) => BasicPostDetails(),
    postImageDetailsUrlBuilder: (quality, post, config) => post.sampleImageUrl,
    postStatisticsPageBuilder: (context, posts) => Container(),
    postGestureHandlerBuilder: (ref, action, post) => false,
    postDetailsUIBuilder: const PostDetailsUIBuilder(),
    postRepositoryFactory: (config) => BasicPostRepository(),
  ),
  
  // No favorites, comments, or other features
);
```

## Key Benefits

### 1. **Modularity**
Each capability is independently testable and reusable:
```dart
// Test search capability in isolation
final searchCapability = DefaultSearchCapability(...);
testSearchCapability(searchCapability);
```

### 2. **Flexibility** 
Mix and match only needed features:
```dart
// Booru with search and posts, but no favorites
BooruCapabilities(search: ..., posts: ...);

// Booru with all features
BooruCapabilities(search: ..., posts: ..., favorites: ..., comments: ...);
```

### 3. **Type Safety**
Compile-time feature detection:
```dart
// Type-safe optional feature usage
if (capabilities.favorites != null) {
  final favoritesBuilder = capabilities.favorites!.favoritesPageBuilder;
}
```

### 4. **Dependency Validation**
Automatic dependency checking:
```dart
if (!capabilities.areAllDependenciesMet) {
  print('Missing: ${capabilities.missingDependencies}');
}
```

### 5. **Configuration-Driven**
Declarative feature configuration:
```dart
final config = BooruFeatureConfig(
  search: SearchConfig(supportsWildcards: true),
  posts: PostConfig(supportsComments: true),
  rating: RatingConfig(defaultRating: Rating.general),
);
```

## Migration Guide

See `migration/migration_guide.dart` for detailed migration examples and utilities.

### Quick Migration Steps:

1. **Identify capabilities** your booru supports
2. **Extract implementation methods** from your BooruBuilder
3. **Create capability instances** with your implementations
4. **Compose capabilities** into BooruCapabilities
5. **Validate and test** the composed builder

### Migration Helper:
```dart
// Automated migration helper (conceptual)
final capabilities = BooruMigrationHelper.fromLegacyBuilder(
  legacyBuilder: oldGelbooruBuilder,
  config: BooruConfigCompositions.basicImageboard(),
);
final newBuilder = capabilities.compose();
```

## File Structure

```
composition/
├── README.md                          # This file
├── booru_capabilities.dart            # Main composition container
├── composed_booru_builder.dart        # BooruBuilder implementation
├── example_usage.dart                 # Usage examples
├── capabilities/                      # Individual capability interfaces
│   ├── base_capability.dart
│   ├── search_capability.dart
│   ├── post_capability.dart
│   └── favorites_capability.dart
├── services/                          # Composable data services
│   └── booru_service.dart
├── widgets/                           # Composable UI components  
│   ├── post_detail_components.dart
│   └── search_components.dart
├── config/                            # Configuration composition
│   └── booru_config_composition.dart
└── migration/                         # Migration utilities
    └── migration_guide.dart
```

## Future Extensions

The composition architecture makes it easy to add new capabilities:

1. **Create new capability interface** (e.g., `PoolCapability`)
2. **Add to BooruCapabilities** as optional field
3. **Update ComposedBooruBuilder** to delegate to new capability
4. **Existing boorus continue working** without changes

## Testing Strategy

Each capability can be tested independently:

```dart
// Test search capability
testWidgets('SearchCapability builds correct page', (tester) async {
  final capability = DefaultSearchCapability(...);
  final page = capability.searchPageBuilder(context, params);
  await tester.pumpWidget(page);
  // ... assertions
});

// Test capability composition
testWidgets('BooruCapabilities composes correctly', (tester) async {
  final capabilities = BooruCapabilities(search: ..., posts: ...);
  expect(capabilities.areAllDependenciesMet, isTrue);
  
  final builder = capabilities.compose();
  expect(builder.searchPageBuilder, isNotNull);
});
```

This composition approach transforms booru creation from implementing 20+ methods to simply composing the needed capability objects, making the system much more maintainable and flexible while following Flutter's composition principles.