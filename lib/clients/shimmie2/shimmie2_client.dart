// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'common.dart';
import 'types/types.dart';

class Shimmie2Client with Shimmie2ClientCommon {
  Shimmie2Client({
    Dio? dio,
    required String baseUrl,
  }) : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
            ));

  final Dio _dio;

  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
  }) async {
    final isEmpty = tags?.join(' ').isEmpty ?? true;

    final response = await _dio.get(
      '/api/danbooru/find_posts',
      queryParameters: {
        if (!isEmpty) 'tags': tags?.join(' '),
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    return _parsePosts(
      response,
      baseUrl: _dio.options.baseUrl,
    );
  }

  @override
  Dio get dio => _dio;
}

FutureOr<List<PostDto>> _parsePosts(
  value, {
  String? baseUrl,
}) {
  final dtos = <PostDto>[];
  final xmlDocument = XmlDocument.parse(value.data);
  final posts = xmlDocument.findAllElements('tag');
  for (final item in posts) {
    dtos.add(PostDto.fromXml(
      item,
      baseUrl: baseUrl,
    ));
  }
  return dtos;
}
