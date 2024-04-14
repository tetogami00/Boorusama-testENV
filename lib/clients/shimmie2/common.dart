// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin Shimmie2ClientCommon on Object {
  Dio get dio;

  Future<List<AutocompleteDto>> getAutocomplete({
    required String query,
  }) async {
    if (query.isEmpty) return [];

    final response = await dio.get(
      '/api/internal/autocomplete',
      queryParameters: {
        's': query,
      },
    );

    try {
      return switch (response.data) {
        Map m => m.entries
            .map((e) => AutocompleteDto(
                  value: e.key,
                  count: switch (e.value) {
                    int n => n,
                    Map m => _parseCount(m['count']),
                    _ => throw Exception(
                        'Failed to parse autocomplete count, unknown type >> ${e.value}'),
                  },
                ))
            .toList(),
        _ => const [],
      };
    } catch (e) {
      throw Exception('Failed to parse autocomplete >> $e >> ${response.data}');
    }
  }
}

int? _parseCount(dynamic value) => switch (value) {
      null => null,
      String s => int.tryParse(s),
      int n => n,
      _ => null,
    };
