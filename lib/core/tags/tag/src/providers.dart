// Dart imports:
import 'dart:async';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/riverpod/riverpod.dart';
import '../../../configs/config.dart';
import '../../../posts/post/post.dart';
import '../../local/providers.dart';
import 'data/providers.dart';
import 'types/cached_tag_mapper.dart';
import 'types/tag.dart';
import 'types/tag_group_item.dart';
import 'types/tag_resolver.dart';

final tagGroupsProvider = FutureProvider.autoDispose
    .family<List<TagGroupItem>?, (BooruConfigAuth, Post)>((ref, params) async {
      ref.cacheFor(const Duration(seconds: 30)); // Increased cache duration

      final config = params.$1;
      final post = params.$2;

      final tagExtractor = ref.watch(tagExtractorProvider(config));

      if (tagExtractor == null) return null;

      final tags = await tagExtractor.extractTags(
        post,
        options: const ExtractOptions(
          fetchTagCount: true,
        ),
      );

      return createTagGroupItems(tags);
    });

final tagResolverProvider = Provider.family<TagResolver, BooruConfigAuth>((
  ref,
  config,
) {
  return TagResolver(
    tagCacheBuilder: () => ref.watch(tagCacheRepositoryProvider.future),
    siteHost: config.url,
    cachedTagMapper: const CachedTagMapper(),
    tagRepositoryBuilder: () => ref.read(
      tagRepoProvider(config),
    ), // use read to avoid circular dependency
  );
});

final artistCharacterGroupProvider = AsyncNotifierProvider.autoDispose
    .family<
      ArtistCharacterNotifier,
      ArtistCharacterGroup,
      ArtistCharacterGroupParams
    >(
      ArtistCharacterNotifier.new,
    );

typedef ArtistCharacterGroupParams = ({Post post, BooruConfigAuth auth});

class ArtistCharacterGroup extends Equatable {
  const ArtistCharacterGroup({
    required this.characterTags,
    required this.artistTags,
  });

  const ArtistCharacterGroup.empty()
    : characterTags = const {},
      artistTags = const {};

  final Set<String> characterTags;
  final Set<String> artistTags;

  @override
  List<Object?> get props => [characterTags, artistTags];
}

class ArtistCharacterNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<
          ArtistCharacterGroup,
          ArtistCharacterGroupParams
        > {
  @override
  FutureOr<ArtistCharacterGroup> build(ArtistCharacterGroupParams arg) async {
    final post = arg.post;
    final config = arg.auth;

    final extractor = ref.watch(tagExtractorProvider(config));

    if (extractor == null) {
      return const ArtistCharacterGroup.empty();
    }

    final tags = await extractor.extractTags(post);
    final group = createTagGroupItems(tags);

    return ArtistCharacterGroup(
      characterTags:
          group
              .firstWhereOrNull(
                (tag) => tag.groupName.toLowerCase() == 'character',
              )
              ?.extractCharacterTags()
              .toSet() ??
          {},
      artistTags:
          group
              .firstWhereOrNull(
                (tag) => tag.groupName.toLowerCase() == 'artist',
              )
              ?.extractArtistTags()
              .toSet() ??
          {},
    );
  }
}
