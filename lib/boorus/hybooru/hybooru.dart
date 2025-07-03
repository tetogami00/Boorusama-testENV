// Package imports:
import 'package:booru_clients/hybooru.dart';

// Project imports:
import '../../core/boorus/booru/booru.dart';
import '../../core/boorus/engine/engine.dart';
import '../../core/boorus/scaffolds/booru_builder_scaffold.dart';
import '../../core/boorus/scaffolds/booru_repository_scaffold.dart';
import '../../core/boorus/scaffolds/booru_scaffold.dart';
import '../../core/configs/config.dart';
import '../../core/configs/create/widgets.dart';
import '../../core/configs/manage/widgets.dart';
import '../../core/downloads/filename.dart';
import '../../core/downloads/filename/constants.dart';
import '../../core/http/providers.dart';
import '../../core/posts/details/widgets.dart';
import '../../core/posts/details_manager/types.dart';
import '../../core/posts/details_parts/widgets.dart';
import '../../core/posts/post/post.dart';
import '../../core/posts/post/providers.dart';
import 'posts/providers.dart';
import 'posts/types.dart';
import 'posts/widgets.dart';
import 'tags/providers.dart';

BooruComponents createHybooru() => BooruComponents(
      parser: YamlBooruParser.standard(
        type: BooruType.hybooru,
        constructor: (siteDef) => BooruScaffold(
          name: siteDef.name,
          protocol: siteDef.protocol,
          sites: siteDef.sites,
          type: BooruType.hybooru,
        ),
      ),
      createBuilder: () => BooruBuilderScaffold(
        createConfigPageBuilder: (context, id, {backgroundColor}) =>
            CreateBooruConfigScope(
          id: id,
          config: BooruConfig.defaultConfig(
            booruType: id.booruType,
            url: id.url,
            customDownloadFileNameFormat: null,
          ),
          child: CreateAnonConfigPage(
            backgroundColor: backgroundColor,
          ),
        ),
        updateConfigPageBuilder: (context, id, {backgroundColor, initialTab}) =>
            UpdateBooruConfigScope(
          id: id,
          child: CreateAnonConfigPage(
            backgroundColor: backgroundColor,
            initialTab: initialTab,
          ),
        ),
        postDetailsPageBuilder: (context, payload) {
          final posts = payload.posts.map((e) => e as HybooruPost).toList();
          return PostDetailsScope(
            initialIndex: payload.initialIndex,
            initialThumbnailUrl: payload.initialThumbnailUrl,
            posts: posts,
            scrollController: payload.scrollController,
            dislclaimer: payload.dislclaimer,
            child: const DefaultPostDetailsPage<HybooruPost>(),
          );
        },
        postDetailsUIBuilder: PostDetailsUIBuilder(
          preview: {
            DetailsPart.toolbar: (context) =>
                const DefaultInheritedPostActionToolbar<HybooruPost>(),
          },
          full: {
            DetailsPart.toolbar: (context) =>
                const DefaultInheritedPostActionToolbar<HybooruPost>(),
            DetailsPart.tags: (context) =>
                const DefaultInheritedBasicTagsTile<HybooruPost>(),
            DetailsPart.fileDetails: (context) =>
                const HybooruFileDetailsSection(),
          },
        ),
      ),
      createRepository: (ref) => BooruRepositoryScaffold(
        ref: ref,
        postRepositoryBuilder: (config) =>
            ref.watch(hybooruPostRepoProvider(config)),
        autocompleteRepositoryBuilder: (config) =>
            ref.watch(hybooruAutocompleteRepoProvider(config)),
        postLinkGeneratorBuilder: (config) =>
            PluralPostLinkGenerator(baseUrl: config.url),
        downloadFilenameBuilderBuilder: (config) =>
            DownloadFileNameBuilder<Post>(
          defaultFileNameFormat: kDefaultCustomDownloadFileNameFormat,
          defaultBulkDownloadFileNameFormat:
              kDefaultCustomDownloadFileNameFormat,
          sampleData: kDanbooruPostSamples,
          hasRating: false,
          extensionHandler: (post, config) => post.format.startsWith('.')
              ? post.format.substring(1)
              : post.format,
          tokenHandlers: [
            WidthTokenHandler(),
            HeightTokenHandler(),
            AspectRatioTokenHandler(),
          ],
        ),
        siteValidatorBuilder: (config) {
          final dio = ref.watch(dioProvider(config));
          return () => HybooruClient(baseUrl: config.url, dio: dio)
              .getPosts()
              .then((value) => true);
        },
      ),
    );
