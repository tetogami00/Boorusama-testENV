// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'post_dto.dart';

class PostGraphqlDto {
  final int? id;
  final List<String>? tags;
  final int? width;
  final int? height;
  final String? md5;
  final int? fileSize;
  final DateTime? createdAt;
  final String? format;
  final String? mimeType;
  final int? score;
  final String? ownerId;
  final String? ownerName;
  final String? source;
  final String? fileName;
  final String? niceName;
  final String? thumbnailImageUrl;
  final String? originalImageUrl;

  PostGraphqlDto({
    required this.id,
    required this.tags,
    required this.width,
    required this.height,
    required this.md5,
    required this.fileSize,
    required this.createdAt,
    required this.format,
    required this.mimeType,
    required this.score,
    required this.ownerId,
    required this.ownerName,
    required this.source,
    required this.fileName,
    required this.niceName,
    required this.thumbnailImageUrl,
    required this.originalImageUrl,
  });

  factory PostGraphqlDto.fromJson(Map<String, dynamic> json) {
    return PostGraphqlDto(
      id: json['post_id'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      width: json['width'],
      height: json['height'],
      md5: json['hash'],
      fileSize: json['filesize'],
      createdAt: _parseDate(json['posted']),
      format: json['ext'],
      mimeType: json['mime'],
      score: json['score'],
      ownerId: json['owner']['id'],
      ownerName: json['owner']['name'],
      source: json['source'],
      fileName: json['filename'],
      niceName: json['nice_name'],
      thumbnailImageUrl: json['thumb_link'],
      originalImageUrl: json['image_link'],
    );
  }
}

// 2024-04-10 17:21:31
DateTime? _parseDate(String? date) {
  if (date == null) return null;

  return DateFormat('yyyy-MM-dd HH:mm:ss').parse(date);
}

PostDto postDtoFromPostGraphqlDto(PostGraphqlDto dto, String? baseUrl) {
  final previewUrl = dto.thumbnailImageUrl;

  return PostDto(
    id: dto.id,
    md5: dto.md5,
    fileName: dto.fileName,
    fileUrl: dto.originalImageUrl,
    height: dto.height,
    width: dto.width,
    previewUrl: previewUrl?.startsWith('http') == true
        ? previewUrl
        : baseUrl != null
            ? '$baseUrl$previewUrl'
            : null,
    previewHeight: dto.height,
    previewWidth: dto.width,
    rating: '?',
    date: dto.createdAt,
    tags: dto.tags,
    source: dto.source,
    score: dto.score,
    author: dto.ownerName,
    fileSize: dto.fileSize,
  );
}
