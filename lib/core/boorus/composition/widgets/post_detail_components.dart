// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../posts/post/post.dart';

/// Base interface for composable post detail components
abstract class PostDetailComponent {
  /// Unique identifier for this component
  String get id;
  
  /// Display order (lower numbers appear first)
  int get order;
  
  /// Whether this component should be shown for the given post
  bool isSupported(Post post);
  
  /// Build the widget for this component
  Widget build(BuildContext context, Post post);
  
  /// Whether this component can be disabled by user preferences
  bool get isOptional => true;
}

/// Component for displaying post tags
class TagsComponent extends PostDetailComponent {
  const TagsComponent({this.order = 100});

  @override
  String get id => 'tags';
  
  @override
  final int order;

  @override
  bool isSupported(Post post) => post.tags.isNotEmpty;

  @override
  Widget build(BuildContext context, Post post) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tags',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: post.tags.map((tag) => 
                Chip(label: Text(tag))
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Component for displaying post artist information
class ArtistComponent extends PostDetailComponent {
  const ArtistComponent({this.order = 200});

  @override
  String get id => 'artist';
  
  @override
  final int order;

  @override
  bool isSupported(Post post) => post.artistTags?.isNotEmpty == true;

  @override
  Widget build(BuildContext context, Post post) {
    final artists = post.artistTags ?? [];
    
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: const Text('Artist'),
        subtitle: Text(artists.join(', ')),
      ),
    );
  }
}

/// Component for displaying post statistics
class StatsComponent extends PostDetailComponent {
  const StatsComponent({this.order = 300});

  @override
  String get id => 'stats';
  
  @override
  final int order;

  @override
  bool isSupported(Post post) => true; // Always show stats

  @override
  Widget build(BuildContext context, Post post) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Score', post.score?.toString() ?? '0'),
            _buildStatItem('Size', '${post.width}×${post.height}'),
            _buildStatItem('Rating', post.rating.name.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

/// Component for displaying post source
class SourceComponent extends PostDetailComponent {
  const SourceComponent({this.order = 400});

  @override
  String get id => 'source';
  
  @override
  final int order;

  @override
  bool isSupported(Post post) => post.source.isNotEmpty;

  @override
  Widget build(BuildContext context, Post post) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.link),
        title: const Text('Source'),
        subtitle: Text(
          post.source,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.open_in_new),
        onTap: () {
          // Open source URL
        },
      ),
    );
  }
}

/// Composer that arranges post detail components
class PostDetailComposer {
  const PostDetailComposer({
    required this.components,
    this.enabledComponents,
  });

  final List<PostDetailComponent> components;
  final Set<String>? enabledComponents;

  /// Build the composed post details view
  Widget build(BuildContext context, Post post) {
    // Filter and sort components
    final supportedComponents = components
        .where((c) => c.isSupported(post))
        .where((c) => enabledComponents?.contains(c.id) ?? true)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return ListView(
      children: supportedComponents
          .map((component) => component.build(context, post))
          .toList(),
    );
  }

  /// Get list of available component IDs for this post
  Set<String> getAvailableComponents(Post post) {
    return components
        .where((c) => c.isSupported(post))
        .map((c) => c.id)
        .toSet();
  }
}

/// Factory for creating common post detail compositions
class PostDetailCompositions {
  /// Standard composition with all common components
  static PostDetailComposer standard() {
    return const PostDetailComposer(
      components: [
        TagsComponent(),
        ArtistComponent(),
        StatsComponent(), 
        SourceComponent(),
      ],
    );
  }

  /// Minimal composition with just essential components
  static PostDetailComposer minimal() {
    return const PostDetailComposer(
      components: [
        TagsComponent(),
        StatsComponent(),
      ],
    );
  }

  /// Custom composition with user-specified components and order
  static PostDetailComposer custom({
    required List<PostDetailComponent> components,
    Set<String>? enabledComponents,
  }) {
    return PostDetailComposer(
      components: components,
      enabledComponents: enabledComponents,
    );
  }
}