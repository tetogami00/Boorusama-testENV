// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/uploads/uploads.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/widgets.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/feats/user_level_colors.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';

enum UploadTabType {
  posted,
  unposted,
}

class DanbooruMyUploadsPage extends ConsumerStatefulWidget {
  const DanbooruMyUploadsPage({
    super.key,
    required this.userId,
  });

  final int userId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruMyUploadsPageState();
}

class _DanbooruMyUploadsPageState extends ConsumerState<DanbooruMyUploadsPage>
    with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Uploads'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              controller: tabController,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              indicatorColor: context.colorScheme.onBackground,
              labelColor: context.colorScheme.onBackground,
              unselectedLabelColor:
                  context.colorScheme.onBackground.withOpacity(0.5),
              tabs: const [
                Tab(text: 'Unposted'),
                Tab(text: 'Posted'),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: [
                    _buildTab(UploadTabType.unposted),
                    _buildTab(UploadTabType.posted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(UploadTabType type) {
    return DanbooruUploadGrid(
      type: type,
      userId: widget.userId,
    );
  }
}

final _danbooruUploaderMapProvider = StateProvider<Map<int, User>>((ref) {
  return {};
});

typedef _UnpostedData = ({
  int unPostedCount,
  int mediaAssetCount,
});

final _danbooruUnPostedCountMapProvider =
    StateProvider<Map<int, _UnpostedData>>((ref) {
  return {};
});

class DanbooruUploadGrid extends ConsumerStatefulWidget {
  const DanbooruUploadGrid({
    super.key,
    required this.userId,
    required this.type,
  });

  final UploadTabType type;
  final int userId;

  @override
  ConsumerState<DanbooruUploadGrid> createState() => _DanbooruUploadGridState();
}

class _DanbooruUploadGridState extends ConsumerState<DanbooruUploadGrid> {
  late final AutoScrollController _autoScrollController =
      AutoScrollController();

  @override
  void dispose() {
    super.dispose();
    _autoScrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watchConfig;
    final settings = ref.watch(settingsProvider);

    return PostScope(
      fetcher: (page) => TaskEither.Do(
        ($) async {
          final uploads =
              await ref.read(danbooruUploadRepoProvider(config)).getUploads(
                    page: page,
                    userId: widget.userId,
                    isPosted: switch (widget.type) {
                      UploadTabType.posted => true,
                      UploadTabType.unposted => false,
                    },
                  );

          final uploaderMap = ref.read(_danbooruUploaderMapProvider);
          for (final upload in uploads) {
            if (upload.uploader != null) {
              uploaderMap[upload.uploaderId] = upload.uploader!;
            }
          }

          final List<DanbooruPost> posts = [];

          final unPostedCountMap = ref.read(_danbooruUnPostedCountMapProvider);

          for (final upload in uploads) {
            final post = upload.previewPost;
            posts.add(post);

            if (widget.type == UploadTabType.unposted &&
                upload.mediaAssetCount != upload.postedCount) {
              unPostedCountMap[upload.id] = (
                unPostedCount: upload.mediaAssetCount - upload.postedCount,
                mediaAssetCount: upload.mediaAssetCount,
              );
            }
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(_danbooruUploaderMapProvider.notifier).state = uploaderMap;
            ref.read(_danbooruUnPostedCountMapProvider.notifier).state =
                unPostedCountMap;
          });

          return posts;
        },
      ),
      builder: (context, controller, errors) => LayoutBuilder(
        builder: (context, constraints) => PostGrid(
          controller: controller,
          scrollController: _autoScrollController,
          itemBuilder: (context, items, index) {
            final post = items[index];

            return Stack(
              children: [
                DanbooruImageGridItem(
                  post: post,
                  hideOverlay: false,
                  autoScrollOptions: AutoScrollOptions(
                    controller: _autoScrollController,
                    index: index,
                  ),
                  enableFav: false,
                  image: BooruImage(
                    aspectRatio: post.aspectRatio,
                    imageUrl: post.thumbnailFromSettings(settings),
                    borderRadius: BorderRadius.circular(
                      settings.imageBorderRadius,
                    ),
                    forceFill: settings.imageListType == ImageListType.standard,
                    placeholderUrl: post.thumbnailImageUrl,
                    // null, // Will cause error sometimes, disabled for now
                  ),
                ),
                if (widget.type == UploadTabType.unposted)
                  _buildUnpostedChip(post.id),
                if (post.uploaderId != 0 &&
                    post.uploaderId != widget.userId &&
                    widget.type == UploadTabType.posted)
                  _buildUploaderChip(context, post.uploaderId),
              ],
            );
          },
          bodyBuilder: (context, itemBuilder, refreshing, data) {
            return SliverPostGrid(
              constraints: constraints,
              itemBuilder: itemBuilder,
              refreshing: refreshing,
              error: errors,
              data: data,
              onRetry: () => controller.refresh(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUnpostedChip(int postId) {
    final data = ref.watch(_danbooruUnPostedCountMapProvider)[postId];

    if (data == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${data.unPostedCount}',
              style: context.textTheme.bodySmall,
            ),
            TextSpan(
              text: ' / ',
              style: context.textTheme.bodySmall,
            ),
            TextSpan(
              text: '${data.mediaAssetCount}',
              style: context.textTheme.bodySmall,
            ),
            TextSpan(
              text: ' posted',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploaderChip(BuildContext context, int uploaderId) {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.background.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Builder(
          builder: (context) {
            final uploader =
                ref.watch(_danbooruUploaderMapProvider)[uploaderId];
            return uploader != null
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'By ',
                          style: context.textTheme.bodySmall,
                        ),
                        TextSpan(
                          text: uploader.name,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: uploader.level.toOnDarkColor(),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
