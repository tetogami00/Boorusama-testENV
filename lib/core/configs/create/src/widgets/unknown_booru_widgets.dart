// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../auth/widgets.dart';
import 'booru_url_field.dart';
import 'create_booru_config_name_field.dart';
import 'unknown_booru_submit_button.dart';

class DefaultUnknownBooruWidgets extends StatelessWidget {
  const DefaultUnknownBooruWidgets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const BooruConfigNameField(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const BooruUrlField(),
              const SizedBox(height: 16),
              Text(
                'Advanced options (optional)',
                style: theme.textTheme.titleMedium,
              ),
              const DefaultBooruInstructionText(
                '*These options only be used if the site allows it.',
              ),
              const SizedBox(height: 16),
              const DefaultBooruLoginField(),
              const SizedBox(height: 16),
              const DefaultBooruApiKeyField(),
              const SizedBox(height: 16),
              const UnknownBooruSubmitButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class ApiKeyOnlyUnknownBooruWidgets extends StatelessWidget {
  const ApiKeyOnlyUnknownBooruWidgets({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        BooruConfigNameField(),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BooruUrlField(),
              SizedBox(height: 16),
              DefaultBooruApiKeyField(),
              SizedBox(height: 16),
              UnknownBooruSubmitButton(),
            ],
          ),
        ),
      ],
    );
  }
}
