// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../configs/gesture/gesture.dart';
import '../../configs/ref.dart';
import '../../downloads/downloader.dart';
import '../../foundation/url_launcher.dart';
import '../../home/custom_home.dart';
import '../../home/home_page_scaffold.dart';
import '../../home/user_custom_home_builder.dart';
import '../../posts/details/details.dart';
import '../../posts/details/widgets.dart';
import '../../posts/details_manager/types.dart';
import '../../posts/details_parts/widgets.dart';
import '../../posts/post/post.dart';
import '../../posts/post/providers.dart';
import '../../posts/post/routes.dart';
import '../../posts/post/tags.dart';
import '../../posts/shares/providers.dart';
import '../../posts/shares/widgets.dart';
import '../../posts/sources/source.dart';
import '../../posts/statistics/stats.dart';
import '../../posts/statistics/widgets.dart';
import '../../scaffolds/scaffolds.dart';
import '../../search/search/widgets.dart';
import '../../search/suggestions/widgets.dart';
import '../../settings/settings.dart';
import '../../tags/tag/routes.dart';
import '../engine/engine.dart';

class BooruBuilderScaffold implements BooruBuilder {
  const BooruBuilderScaffold({
    required this.createConfigPageBuilder,
    required this.updateConfigPageBuilder,
    HomePageBuilder? homePageBuilder,
    SearchPageBuilder? searchPageBuilder,
    PostDetailsPageBuilder? postDetailsPageBuilder,
    this.favoritesPageBuilder,
    this.artistPageBuilder,
    this.characterPageBuilder,
    this.commentPageBuilder,
    this.quickFavoriteButtonBuilder,
    HomeViewBuilder? homeViewBuilder,
    PostImageDetailsUrlBuilder? postImageDetailsUrlBuilder,
    PostStatisticsPageBuilder? postStatisticsPageBuilder,
    this.granularRatingFilterer,
    this.granularRatingOptionsBuilder,
    PostGestureHandlerBuilder? postGestureHandlerBuilder,
    this.metatagExtractorBuilder,
    TagSuggestionItemBuilder? tagSuggestionItemBuilder,
    this.multiSelectionActionsBuilder,
    Map<CustomHomeViewKey, CustomHomeDataBuilder>? customHomeViewBuilders,
    PostDetailsUIBuilder? postDetailsUIBuilder,
  })  : _homePageBuilder = homePageBuilder,
        _searchPageBuilder = searchPageBuilder,
        _postDetailsPageBuilder = postDetailsPageBuilder,
        _homeViewBuilder = homeViewBuilder,
        _postImageDetailsUrlBuilder = postImageDetailsUrlBuilder,
        _postStatisticsPageBuilder = postStatisticsPageBuilder,
        _postGestureHandlerBuilder = postGestureHandlerBuilder,
        _tagSuggestionItemBuilder = tagSuggestionItemBuilder,
        _customHomeViewBuilders = customHomeViewBuilders,
        _postDetailsUIBuilder = postDetailsUIBuilder;

  final HomePageBuilder? _homePageBuilder;
  final SearchPageBuilder? _searchPageBuilder;
  final PostDetailsPageBuilder? _postDetailsPageBuilder;
  final HomeViewBuilder? _homeViewBuilder;
  final PostImageDetailsUrlBuilder? _postImageDetailsUrlBuilder;
  final PostStatisticsPageBuilder? _postStatisticsPageBuilder;
  final PostGestureHandlerBuilder? _postGestureHandlerBuilder;
  final TagSuggestionItemBuilder? _tagSuggestionItemBuilder;
  final Map<CustomHomeViewKey, CustomHomeDataBuilder>? _customHomeViewBuilders;
  final PostDetailsUIBuilder? _postDetailsUIBuilder;

  @override
  final CreateConfigPageBuilder createConfigPageBuilder;

  @override
  final UpdateConfigPageBuilder updateConfigPageBuilder;

  @override
  final FavoritesPageBuilder? favoritesPageBuilder;

  @override
  final ArtistPageBuilder? artistPageBuilder;

  @override
  final CharacterPageBuilder? characterPageBuilder;

  @override
  final CommentPageBuilder? commentPageBuilder;

  @override
  final QuickFavoriteButtonBuilder? quickFavoriteButtonBuilder;

  @override
  final GranularRatingFilterer? granularRatingFilterer;

  @override
  final GranularRatingOptionsBuilder? granularRatingOptionsBuilder;

  @override
  final MetatagExtractorBuilder? metatagExtractorBuilder;

  @override
  final MultiSelectionActionsBuilder? multiSelectionActionsBuilder;

  @override
  HomePageBuilder get homePageBuilder =>
      _homePageBuilder ?? (context) => const HomePageScaffold();

  @override
  SearchPageBuilder get searchPageBuilder =>
      _searchPageBuilder ??
      (context, params) => _DefaultSearchPage(params: params);

  @override
  PostDetailsPageBuilder get postDetailsPageBuilder =>
      _postDetailsPageBuilder ??
      (context, payload) {
        return PostDetailsScope(
          initialIndex: payload.initialIndex,
          initialThumbnailUrl: payload.initialThumbnailUrl,
          posts: payload.posts,
          scrollController: payload.scrollController,
          dislclaimer: payload.dislclaimer,
          child: const _DefaultPostDetailsPage(),
        );
      };

  @override
  HomeViewBuilder get homeViewBuilder =>
      _homeViewBuilder ??
      (context) => const UserCustomHomeBuilder(
            defaultView: MobileHomePageScaffold(),
          );

  @override
  PostImageDetailsUrlBuilder get postImageDetailsUrlBuilder =>
      _postImageDetailsUrlBuilder ??
      (imageQuality, post, config) => post.isGif
          ? post.sampleImageUrl
          : config.imageDetaisQuality.toOption().fold(
                () => switch (imageQuality) {
                  ImageQuality.low => post.thumbnailImageUrl,
                  ImageQuality.original => post.isVideo
                      ? post.videoThumbnailUrl
                      : post.originalImageUrl,
                  _ =>
                    post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
                },
                (quality) => switch (stringToGeneralPostQualityType(quality)) {
                  GeneralPostQualityType.preview => post.thumbnailImageUrl,
                  GeneralPostQualityType.sample =>
                    post.isVideo ? post.videoThumbnailUrl : post.sampleImageUrl,
                  GeneralPostQualityType.original => post.isVideo
                      ? post.videoThumbnailUrl
                      : post.originalImageUrl,
                },
              );

  @override
  PostStatisticsPageBuilder get postStatisticsPageBuilder =>
      _postStatisticsPageBuilder ??
      (context, posts) => PostStatisticsPage(
            generalStats: () => posts.getStats(),
            totalPosts: () => posts.length,
          );

  @override
  PostGestureHandlerBuilder get postGestureHandlerBuilder =>
      _postGestureHandlerBuilder ??
      (ref, action, post) =>
          const _PostGestureHandler().handle(ref, action, post);

  @override
  TagSuggestionItemBuilder get tagSuggestionItemBuilder =>
      _tagSuggestionItemBuilder ??
      (config, tag, dense, currentQuery, onItemTap) => DefaultTagSuggestionItem(
            config: config,
            tag: tag,
            onItemTap: onItemTap,
            currentQuery: currentQuery,
            dense: dense,
          );

  @override
  Map<CustomHomeViewKey, CustomHomeDataBuilder> get customHomeViewBuilders =>
      _customHomeViewBuilders ?? kDefaultAltHomeView;

  @override
  PostDetailsUIBuilder get postDetailsUIBuilder =>
      _postDetailsUIBuilder ??
      const PostDetailsUIBuilder(
        preview: {
          DetailsPart.toolbar: _defaultInheritedPostActionToolbar,
        },
        full: {
          DetailsPart.toolbar: _defaultInheritedPostActionToolbar,
          DetailsPart.tags: _defaultInheritedBasicTagsTile,
          DetailsPart.fileDetails: _defaultInheritedFileDetailsSection,
        },
      );

  static Widget _defaultInheritedPostActionToolbar(BuildContext context) =>
      const DefaultInheritedPostActionToolbar();

  static Widget _defaultInheritedBasicTagsTile(BuildContext context) =>
      const DefaultInheritedBasicTagsTile();

  static Widget _defaultInheritedFileDetailsSection(BuildContext context) =>
      const DefaultInheritedFileDetailsSection();
}

class _DefaultPostDetailsPage<T extends Post> extends ConsumerWidget {
  const _DefaultPostDetailsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = PostDetails.of<T>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
      viewerConfig: ref.watchConfigViewer,
      authConfig: ref.watchConfigAuth,
      gestureConfig: ref.watchPostGestures,
    );
  }
}

class _DefaultSearchPage extends ConsumerWidget {
  const _DefaultSearchPage({
    required this.params,
  });

  final SearchParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postRepo = ref.watch(postRepoProvider(ref.watchConfigSearch));

    return SearchPageScaffold(
      params: params,
      fetcher: (page, controler) => postRepo.getPostsFromController(
        controler.tagSet,
        page,
      ),
    );
  }
}

class _PostGestureHandler {
  const _PostGestureHandler({
    // ignore: unused_element_parameter
    this.customActions = const {},
  });

  final Map<String, bool Function(WidgetRef, String?, Post)> customActions;

  bool handle(WidgetRef ref, String? action, Post post) {
    final handled = handleDefaultGestureAction(
      action,
      onDownload: () => _handleDownload(ref, post),
      onShare: () => _handleShare(ref, post),
      onToggleBookmark: () => _handleBookmark(ref, post),
      onViewTags: () => _handleViewTags(ref, post),
      onViewOriginal: () => _handleViewOriginal(ref, post),
      onOpenSource: () => _handleOpenSource(ref, post),
    );

    if (handled) return true;

    for (final entry in customActions.entries) {
      if (entry.key == action) {
        final customAction = entry.value;
        if (customAction(ref, action, post)) {
          return true;
        }
      }
    }

    return false;
  }

  void _handleDownload(WidgetRef ref, Post post) {
    ref.download(post);
  }

  void _handleShare(WidgetRef ref, Post post) {
    ref.sharePost(
      post,
      context: ref.context,
      state: ref.read(postShareProvider(post)),
    );
  }

  void _handleBookmark(WidgetRef ref, Post post) {
    ref.toggleBookmark(post);
  }

  void _handleViewTags(WidgetRef ref, Post post) {
    goToShowTaglistPage(
      ref.context,
      post.extractTags(),
    );
  }

  void _handleViewOriginal(WidgetRef ref, Post post) {
    goToOriginalImagePage(ref, post);
  }

  void _handleOpenSource(WidgetRef ref, Post post) {
    post.source.whenWeb(
      (source) => launchExternalUrlString(source.url),
      () => false,
    );
  }
}
