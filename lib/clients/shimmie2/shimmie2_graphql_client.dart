// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// Project imports:
import 'package:boorusama/clients/shimmie2/common.dart';
import 'package:boorusama/clients/shimmie2/shimmie2_client.dart';
import 'package:boorusama/clients/shimmie2/types/post_graphql_dto.dart';
import 'types/types.dart';

const String fetchPostsQuery = '''
query FetchPosts(\$limit: Int!, \$offset: Int! , \$tags: [String!])
{
  posts(limit: \$limit, offset: \$offset, , tags: \$tags) { 
      post_id
      tags
      width
      height
      hash
      filesize
      posted
      ext
      mime
      owner {
          id
          name
      }
      source
      filename
      nice_name
      thumb_link
      image_link
  }
}
''';

class Shimmie2GraphqlClient
    with Shimmie2ClientCommon
    implements Shimmie2Client {
  Shimmie2GraphqlClient({
    Dio? dio,
    required String baseUrl,
  })  : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
            )),
        _graphQLClient = GraphQLClient(
          link: HttpLink('${baseUrl}graphql'),
          cache: GraphQLCache(),
        ),
        _baseUrl = baseUrl;

  final Dio _dio;
  final GraphQLClient _graphQLClient;
  final String _baseUrl;

  @override
  Future<List<PostDto>> getPosts({
    List<String>? tags,
    int? page,
    int? limit,
  }) async {
    final isEmpty = tags?.join(' ').isEmpty ?? true;
    final lim = limit ?? 100;
    final offset = page != null ? page * lim : 0;

    final response = await _graphQLClient.query(
      QueryOptions(
        document: gql(fetchPostsQuery),
        variables: {
          'limit': lim,
          'offset': offset,
          if (!isEmpty) 'tags': tags,
        },
      ),
    );

    return switch (response.data) {
      Map m => (m['posts'] as List)
          .map((e) => PostGraphqlDto.fromJson(e))
          .map((e) => postDtoFromPostGraphqlDto(e, _baseUrl))
          .toList(),
      _ => const [],
    };
  }

  @override
  Dio get dio => _dio;
}
