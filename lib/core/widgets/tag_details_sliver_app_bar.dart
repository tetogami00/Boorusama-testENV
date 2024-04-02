// Flutter imports:
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/pages/tag_subscription_page.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/router.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class TagDetailsSlilverAppBar extends ConsumerWidget {
  const TagDetailsSlilverAppBar({
    super.key,
    required this.tagName,
  });

  final String tagName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTagSubscribed = ref.watch(isTagSubscribedProvider(tagName));
    return SliverAppBar(
      floating: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            backgroundColor: isTagSubscribed
                ? context.colorScheme.secondaryContainer
                : context.colorScheme.onSurface,
            foregroundColor: isTagSubscribed
                ? context.colorScheme.onSurface
                : context.colorScheme.secondaryContainer,
          ),
          onPressed: () {
            if (isTagSubscribed) {
              removeTagSubscription(ref, ref.readConfig.url, tagName);
            } else {
              addTagSubscription(ref, ref.readConfig.url, tagName);
            }
          },
          child: Text(
            isTagSubscribed ? 'Subscribed' : 'Subscribe',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          splashRadius: 20,
          onPressed: () {
            goToBulkDownloadPage(
              context,
              [tagName],
              ref: ref,
            );
          },
          icon: const Icon(Symbols.download),
        ),
      ],
    );
  }
}
