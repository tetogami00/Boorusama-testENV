// Package imports:
import 'package:booru_clients/sankaku.dart';

// Project imports:
import '../../../core/downloads/urls/sanitizer.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/posts/sources/source.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/tag.dart';
import 'types.dart';

SankakuPost postDtoToPost(
  PostDto e,
  PostIdGenerator idGenerator,
  PostMetadata? metadata,
) {
  final hasParent = e.parentId != null;
  final hasChilren = e.hasChildren ?? false;
  final hasParentOrChildren = hasParent || hasChilren;

  // Optimize tag processing by grouping in a single pass instead of 5 separate iterations
  final tagsByCategory = <TagCategory, List<Tag>>{};
  
  if (e.tags != null) {
    for (final tagDto in e.tags!) {
      final category = TagCategory.fromLegacyId(tagDto.type);
      final tag = Tag(
        name: tagDto.tagName ?? '????',
        category: category,
        postCount: tagDto.postCount ?? 0,
      );
      
      tagsByCategory.putIfAbsent(category, () => <Tag>[]).add(tag);
    }
  }

  final artistTags = tagsByCategory[TagCategory.artist()] ?? [];
  final characterTags = tagsByCategory[TagCategory.character()] ?? [];
  final copyrightTags = tagsByCategory[TagCategory.copyright()] ?? [];
  final generalTags = tagsByCategory[TagCategory.general()] ?? [];
  final metaTags = tagsByCategory[TagCategory.meta()] ?? [];

  final timestamp = e.createdAt?.s;

  // They changed the id to a string, so a workaround is needed until i can figure out a better way
  // This workaround is just generating an autoincrement id to make the filtering work
  // Update: They are reverting the id back to an int, not sure if they changed their mind again so i will keep this workaround
  final (id, sankakuId) = switch (e.id) {
    // No id, so we generate pseudo id and a dummy string id
    null => (idGenerator.generateId(), ''),
    // Int id, which means they reverted back to int id
    IntId i => (i.value, ''),
    // String id, which means they are using string id
    StringId s => (idGenerator.generateId(), s.value),
  };

  return SankakuPost(
    id: id,
    sankakuId: sankakuId,
    thumbnailImageUrl: e.previewUrl ?? '',
    sampleImageUrl: e.sampleUrl ?? '',
    originalImageUrl: e.fileUrl ?? '',
    tags: e.tags?.map((e) => e.tagName).nonNulls.toSet() ?? {},
    rating: mapStringToRating(e.rating),
    hasComment: e.hasComments ?? false,
    isTranslated: false,
    hasParentOrChildren: hasParentOrChildren,
    source: PostSource.from(e.source),
    score: e.totalScore ?? 0,
    duration: e.videoDuration ?? 0,
    fileSize: e.fileSize ?? 0,
    format:
        extractFileExtension(
          e.fileType,
          fileUrl: e.fileUrl,
        ) ??
        '',
    hasSound: null,
    height: e.height?.toDouble() ?? 0,
    md5: e.md5 ?? '',
    videoThumbnailUrl: e.previewUrl ?? '',
    videoUrl: e.fileUrl ?? '',
    width: e.width?.toDouble() ?? 0,
    artistDetailsTags: artistTags,
    characterDetailsTags: characterTags,
    copyrightDetailsTags: copyrightTags,
    generalDetailsTags: generalTags,
    metaDetailsTags: metaTags,
    createdAt: timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        : null,
    // uploaderId: e.author?.id,
    uploaderId: 0, // The id is now a string
    uploaderName: e.author?.name,
    metadata: metadata,
  );
}

String? extractFileExtension(
  String? mimeType, {
  String? fileUrl,
}) {
  if (mimeType == null) {
    if (fileUrl == null) return null;

    final ext = sanitizedExtension(fileUrl);

    return ext;
  }

  final parts = mimeType.split('/');
  return parts.length >= 2 ? '.${parts[1]}' : null;
}
