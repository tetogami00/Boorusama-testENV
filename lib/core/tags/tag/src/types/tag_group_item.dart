// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../foundation/utils/collection_utils.dart';
import '../../../categories/tag_category.dart';
import 'tag.dart';
import 'tag_display.dart';

class TagGroupItem extends Equatable {
  const TagGroupItem({
    required this.category,
    required this.groupName,
    required this.tags,
    required this.order,
  });

  final int category;
  final String groupName;
  final List<Tag> tags;
  final TagCategoryOrder order;

  @override
  List<Object?> get props => [category, groupName, tags, order];
}

extension TagGroupItemX on TagGroupItem {
  // Cache the extracted tags to avoid recomputation
  static final Map<String, List<String>> _extractionCache = <String, List<String>>{};
  
  List<String> extractRawTag(TagCategory category) {
    final cacheKey = '${hashCode}_${category.id}';
    
    return _extractionCache.putIfAbsent(cacheKey, () =>
        tags.where((e) => category == e.category).map((e) => e.rawName).toList());
  }

  List<String> extractArtistTags() => extractRawTag(TagCategory.artist());
  List<String> extractCharacterTags() => extractRawTag(TagCategory.character());
  List<String> extractGeneralTags() => extractRawTag(TagCategory.general());
  List<String> extractMetaTags() => extractRawTag(TagCategory.meta());
  List<String> extractCopyRightTags() => extractRawTag(TagCategory.copyright());
  
  static void clearCache() {
    _extractionCache.clear();
  }
}

// Cache for createTagGroupItems to avoid recomputation for same tag sets
final Map<int, List<TagGroupItem>> _tagGroupCache = <int, List<TagGroupItem>>{};

List<TagGroupItem> createTagGroupItems(List<Tag> tags) {
  if (tags.isEmpty) return const <TagGroupItem>[];
  
  // Create a cache key based on the tags
  final cacheKey = Object.hashAll(tags.map((e) => e.hashCode));
  
  return _tagGroupCache.putIfAbsent(cacheKey, () {
    // Create a copy to avoid modifying the original list
    final sortedTags = [...tags]..sort((a, b) => a.rawName.compareTo(b.rawName));
    
    final group = sortedTags
        .groupBy((e) => e.category)
        .entries
        .map(
          (e) => TagGroupItem(
            category: e.key.id,
            groupName: e.key.displayName ?? e.key.name.sentenceCase,
            tags: e.value,
            order: e.key.order ?? 99999,
          ),
        )
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    
    return group;
  });
}

void clearTagGroupCache() {
  _tagGroupCache.clear();
  TagGroupItemX.clearCache();
}
