// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/boorus/engine/engine.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/configs/ref.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/details/widgets.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/router.dart';
import '../../../core/search/search/routes.dart';
import '../gelbooru_v2.dart';
import 'providers.dart';
import 'types.dart';

class GelbooruV2PostDetailsPage extends ConsumerWidget {
  const GelbooruV2PostDetailsPage({
    required this.payload,
    super.key,
  });

  final DetailsRouteContext payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configSearch = ref.watchConfigSearch;

    final postId = payload.posts.getOrNull(payload.initialIndex)?.id;

    if (postId == null) {
      return InvalidPage(message: 'Invalid post: $postId');
    }

    final gelbooruV2 = ref.watch(gelbooruV2Provider);

    final thumbnailOnly =
        gelbooruV2
            .getCapabilitiesForSite(configSearch.auth.url)
            ?.posts
            ?.thumbnailOnly ??
        false;

    if (thumbnailOnly) {
      return _PostDetailsDataLoadingTransitionPage(
        postId: NumericPostId(postId),
        configSearch: configSearch,
        originalPayload: payload,
        pageBuilder: (context, detailsContext) {
          final widget = InheritedDetailsContext(
            context: detailsContext,
            child: const _PayloadPostDetailsPage(),
          );

          return widget;
        },
      );
    }

    final posts = payload.posts.map((e) => e as GelbooruV2Post).toList();

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: posts,
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<GelbooruV2Post>(),
    );
  }
}

class _PayloadPostDetailsPage<T extends Post> extends ConsumerWidget {
  const _PayloadPostDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payload = InheritedDetailsContext.of<T>(context);
    final configSearch = payload.configSearch;

    if (configSearch == null) {
      return const UnimplementedPage();
    }

    return PostDetailsScope(
      initialIndex: payload.initialIndex,
      initialThumbnailUrl: payload.initialThumbnailUrl,
      posts: payload.posts.map((e) => e as GelbooruV2Post).toList(),
      scrollController: payload.scrollController,
      dislclaimer: payload.dislclaimer,
      child: const DefaultPostDetailsPage<GelbooruV2Post>(),
    );
  }
}

class _PostDetailsDataLoadingTransitionPage extends ConsumerWidget {
  const _PostDetailsDataLoadingTransitionPage({
    required this.pageBuilder,
    required this.postId,
    required this.configSearch,
    required this.originalPayload,
  });

  final PostId postId;
  final BooruConfigSearch configSearch;
  final DetailsRouteContext originalPayload;

  final Widget Function(
    BuildContext context,
    DetailsRouteContext<Post> detailsContext,
  )
  pageBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (postId, configSearch);
    return ref
        .watch(gelbooruV2PostProvider(params))
        .when(
          data: (post) {
            if (post == null) {
              return InvalidPage(message: 'Invalid post: $post');
            }

            // Create posts list with the detailed post at current index
            // but keep other posts as thumbnails so user can still swipe
            // Note: When user swipes to other posts, they will see thumbnail data
            // until they click to load detailed view for that specific post
            final updatedPosts = List<Post>.from(originalPayload.posts);
            if (originalPayload.initialIndex >= 0 && 
                originalPayload.initialIndex < updatedPosts.length) {
              updatedPosts[originalPayload.initialIndex] = post;
            }

            final detailsContext = DetailsRouteContext(
              initialIndex: originalPayload.initialIndex,
              posts: updatedPosts,
              scrollController: originalPayload.scrollController,
              isDesktop: originalPayload.isDesktop,
              hero: originalPayload.hero,
              initialThumbnailUrl: originalPayload.initialThumbnailUrl,
              dislclaimer: null, // Remove the limiting disclaimer
              configSearch: configSearch,
            );
            return pageBuilder(context, detailsContext);
          },
          error: (error, stackTrace) => InvalidPage(message: error.toString()),
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
  }
}

class GelbooruV2FileDetailsSection extends ConsumerWidget {
  const GelbooruV2FileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

class GelbooruV2RelatedPostsSection extends ConsumerWidget {
  const GelbooruV2RelatedPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return post.hasParent
        ? ref
              .watch(
                gelbooruV2ChildPostsProvider(
                  (ref.watchConfigFilter, ref.watchConfigSearch, post),
                ),
              )
              .maybeWhen(
                data: (data) => SliverRelatedPostsSection(
                  title: 'Child posts',
                  posts: data,
                  imageUrl: (post) => post.sampleImageUrl,
                  onViewAll: () => goToSearchPage(
                    ref,
                    tag: post.relationshipQuery,
                  ),
                  onTap: (index) => goToPostDetailsPageFromPosts(
                    ref: ref,
                    posts: data,
                    initialIndex: index,
                    initialThumbnailUrl: data[index].sampleImageUrl,
                  ),
                ),
                orElse: () => const SliverSizedBox.shrink(),
              )
        : const SliverSizedBox.shrink();
  }
}
