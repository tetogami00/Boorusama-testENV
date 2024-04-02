import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tagSubscriptionsProvider =
    StateProvider<Map<String, List<String>>>((ref) {
  return {};
});

final isTagSubscribedProvider =
    Provider.autoDispose.family<bool, String>((ref, tag) {
  final subs = ref.watch(tagSubscriptionsProvider);
  final config = ref.watchConfig;
  return subs[config.url]?.contains(tag) ?? false;
});

void addTagSubscription(WidgetRef ref, String site, String tag) {
  final subs = ref.read(tagSubscriptionsProvider);
  final tags = subs[site] ?? [];
  tags.add(tag);
  subs[site] = tags.toSet().toList();

  ref.read(tagSubscriptionsProvider.notifier).state = {
    ...subs,
  };
}

void removeTagSubscription(WidgetRef ref, String site, String tag) {
  final subs = ref.read(tagSubscriptionsProvider);
  final tags = subs[site] ?? [];
  tags.remove(tag);
  subs[site] = tags.toSet().toList();

  ref.read(tagSubscriptionsProvider.notifier).state = {
    ...subs,
  };
}

class TagSubscriptionPage extends ConsumerWidget {
  const TagSubscriptionPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subs = ref.watch(tagSubscriptionsProvider);
    final sites = subs.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tag Subscriptions'),
      ),
      body: ListView.builder(
        itemCount: sites.length,
        itemBuilder: (context, index) {
          final site = sites[index];
          final tags = subs[site]!;
          return Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return ListTile(
                    title: Text(site),
                    subtitle: Text(tag),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {},
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
