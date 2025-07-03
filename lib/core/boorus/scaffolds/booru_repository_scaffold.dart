// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../autocompletes/autocompletes.dart';
import '../../blacklists/blacklist.dart';
import '../../blacklists/providers.dart';
import '../../comments/comment.dart';
import '../../comments/providers.dart';
import '../../configs/config.dart';
import '../../configs/create/create.dart';
import '../../downloads/filename.dart';
import '../../downloads/urls.dart';
import '../../notes/notes.dart';
import '../../posts/count/count.dart';
import '../../posts/favorites/providers.dart';
import '../../posts/listing/list.dart';
import '../../posts/listing/providers.dart';
import '../../posts/post/post.dart';
import '../../search/queries/tag_query_composer.dart';
import '../../tags/tag/colors.dart';
import '../../tags/tag/providers.dart';
import '../../tags/tag/tag.dart';
import '../engine/engine.dart';

class BooruRepositoryScaffold implements BooruRepository {
  const BooruRepositoryScaffold({
    required this.ref,
    required this.postRepositoryBuilder,
    required this.autocompleteRepositoryBuilder,
    required this.postLinkGeneratorBuilder,
    required this.downloadFilenameBuilderBuilder,
    this.siteValidatorBuilder,
    this.postCountRepositoryBuilder,
    this.noteRepositoryBuilder,
    this.tagRepositoryBuilder,
    this.downloadFileUrlExtractorBuilder,
    this.favoriteRepositoryBuilder,
    this.blacklistTagRefRepositoryBuilder,
    this.tagComposerBuilder,
    this.imageUrlResolverBuilder,
    this.gridThumbnailUrlGeneratorBuilder,
    this.tagColorGeneratorBuilder,
    this.queryMatcherBuilder,
    this.tagGroupRepositoryBuilder,
    this.commentRepositoryBuilder,
  });

  @override
  final Ref ref;

  final PostRepository<Post> Function(BooruConfigSearch) postRepositoryBuilder;
  final AutocompleteRepository Function(BooruConfigAuth)
      autocompleteRepositoryBuilder;
  final PostLinkGenerator<Post> Function(BooruConfigAuth)
      postLinkGeneratorBuilder;
  final DownloadFilenameGenerator<Post> Function(BooruConfigAuth)
      downloadFilenameBuilderBuilder;
  final BooruSiteValidator? Function(BooruConfigAuth)? siteValidatorBuilder;
  final PostCountRepository? Function(BooruConfigSearch)?
      postCountRepositoryBuilder;
  final NoteRepository Function(BooruConfigAuth)? noteRepositoryBuilder;
  final TagRepository Function(BooruConfigAuth)? tagRepositoryBuilder;
  final DownloadFileUrlExtractor Function(BooruConfigAuth)?
      downloadFileUrlExtractorBuilder;
  final FavoriteRepository Function(BooruConfigAuth)? favoriteRepositoryBuilder;
  final BlacklistTagRefRepository Function(BooruConfigAuth)?
      blacklistTagRefRepositoryBuilder;
  final TagQueryComposer Function(BooruConfigSearch)? tagComposerBuilder;
  final ImageUrlResolver Function()? imageUrlResolverBuilder;
  final GridThumbnailUrlGenerator Function()? gridThumbnailUrlGeneratorBuilder;
  final TagColorGenerator Function()? tagColorGeneratorBuilder;
  final TextMatcher? Function(BooruConfigAuth)? queryMatcherBuilder;
  final TagGroupRepository<Post> Function(BooruConfigAuth)?
      tagGroupRepositoryBuilder;
  final CommentRepository Function(BooruConfigAuth)? commentRepositoryBuilder;

  @override
  PostRepository<Post> post(BooruConfigSearch config) =>
      postRepositoryBuilder(config);

  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) =>
      autocompleteRepositoryBuilder(config);

  @override
  PostLinkGenerator<Post> postLinkGenerator(BooruConfigAuth config) =>
      postLinkGeneratorBuilder(config);

  @override
  DownloadFilenameGenerator<Post> downloadFilenameBuilder(
    BooruConfigAuth config,
  ) =>
      downloadFilenameBuilderBuilder(config);

  @override
  BooruSiteValidator? siteValidator(BooruConfigAuth config) =>
      siteValidatorBuilder?.call(config);

  @override
  PostCountRepository? postCount(BooruConfigSearch config) =>
      postCountRepositoryBuilder?.call(config);

  @override
  NoteRepository note(BooruConfigAuth config) =>
      noteRepositoryBuilder?.call(config) ?? ref.watch(emptyNoteRepoProvider);

  @override
  TagRepository tag(BooruConfigAuth config) =>
      tagRepositoryBuilder?.call(config) ?? ref.watch(emptyTagRepoProvider);

  @override
  DownloadFileUrlExtractor downloadFileUrlExtractor(BooruConfigAuth config) =>
      downloadFileUrlExtractorBuilder?.call(config) ??
      const UrlInsidePostExtractor();

  @override
  FavoriteRepository favorite(BooruConfigAuth config) =>
      favoriteRepositoryBuilder?.call(config) ?? EmptyFavoriteRepository();

  @override
  BlacklistTagRefRepository blacklistTagRef(BooruConfigAuth config) =>
      blacklistTagRefRepositoryBuilder?.call(config) ??
      EmptyBooruSpecificBlacklistTagRefRepository(ref);

  @override
  TagQueryComposer tagComposer(BooruConfigSearch config) =>
      tagComposerBuilder?.call(config) ??
      DefaultTagQueryComposer(config: config);

  @override
  ImageUrlResolver imageUrlResolver() =>
      imageUrlResolverBuilder?.call() ?? const DefaultImageUrlResolver();

  @override
  GridThumbnailUrlGenerator gridThumbnailUrlGenerator() =>
      gridThumbnailUrlGeneratorBuilder?.call() ??
      const DefaultGridThumbnailUrlGenerator();

  @override
  TagColorGenerator tagColorGenerator() =>
      tagColorGeneratorBuilder?.call() ?? const DefaultTagColorGenerator();

  @override
  TextMatcher? queryMatcher(BooruConfigAuth config) =>
      queryMatcherBuilder?.call(config);

  @override
  TagGroupRepository<Post> tagGroup(BooruConfigAuth config) =>
      tagGroupRepositoryBuilder?.call(config) ??
      ref.watch(emptyTagGroupRepoProvider(config));

  @override
  CommentRepository comment(BooruConfigAuth config) =>
      commentRepositoryBuilder?.call(config) ??
      ref.watch(emptyCommentRepoProvider);
}
