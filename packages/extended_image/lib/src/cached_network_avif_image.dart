import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:extended_image_library/extended_image_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:retriable/retriable.dart';

import 'image_cache_manager.dart';

class CustomCachedNetworkAvifImage extends AvifImage {
  CustomCachedNetworkAvifImage(
    String url, {
    super.key,
    double scale = 1.0,
    super.width,
    super.height,
    super.color,
    super.opacity,
    super.colorBlendMode,
    super.fit,
    super.alignment = Alignment.center,
    super.repeat = ImageRepeat.noRepeat,
    super.centerSlice,
    super.matchTextDirection = false,
    super.isAntiAlias = false,
    super.filterQuality = FilterQuality.low,
    super.cacheWidth,
    super.cacheHeight,
    int? overrideDurationMs = -1,
    super.errorBuilder,
    super.semanticLabel,
    super.excludeFromSemantics = false,
    super.gaplessPlayback = false,
    super.frameBuilder,
    super.loadingBuilder,
    Map<String, String>? headers,
    ImageCacheManager? cacheManager,
    required Dio dio,
    CancellationToken? cancelToken,
    FetchStrategyBuilder? fetchStrategy,
    String? cacheKey,
    Duration? cacheMaxAge,
  }) : super(
         image: CustomCachedNetworkAvifImageProvider(
           url,
           scale: scale,
           overrideDurationMs: overrideDurationMs,
           headers: headers,
           cacheManager: cacheManager,
           dio: dio,
           cancelToken: cancelToken,
           fetchStrategy: fetchStrategy,
           cacheKey: cacheKey,
           cacheMaxAge: cacheMaxAge,
         ),
       );
}

class CustomCachedNetworkAvifImageProvider extends NetworkAvifImage {
  CustomCachedNetworkAvifImageProvider(
    super.url, {
    super.scale = 1.0,
    super.overrideDurationMs = -1,
    super.headers,
    required this.dio,
    this.cancelToken,
    this.fetchStrategy,
    this.cacheKey,
    this.cacheMaxAge,
    ImageCacheManager? cacheManager,
  }) : cacheManager = cacheManager ?? DefaultImageCacheManager();

  late final ImageCacheManager cacheManager;
  final Dio dio;
  final CancellationToken? cancelToken;
  final FetchStrategyBuilder? fetchStrategy;
  final String? cacheKey;
  final Duration? cacheMaxAge;

  @override
  ImageStreamCompleter loadImage(
    NetworkAvifImage key,
    ImageDecoderCallback decode,
  ) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return AvifImageStreamCompleter(
      key: key,
      codec: _loadAsync(
        key,
        decode,
        chunkEvents,
      ),
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Url: $url'),
        DiagnosticsProperty<String>('Cache key', _generateCacheKey()),
      ],
      chunkEvents: chunkEvents.stream,
    );
  }

  String _generateCacheKey() {
    return cacheManager.generateCacheKey(
      url,
      customKey: cacheKey,
    );
  }

  Future<AvifCodec> _loadAsync(
    NetworkAvifImage key,
    ImageDecoderCallback decode,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    assert(key == this);

    final stopwatch = Stopwatch()..start();
    final cacheKey = _generateCacheKey();
    
    try {
      final hasValidCache = await cacheManager.hasValidCache(
        cacheKey,
        maxAge: cacheMaxAge,
      );

      // Try to load from cache first
      if (hasValidCache) {
        final cacheStopwatch = Stopwatch()..start();
        try {
          final cachedBytes = await cacheManager.getCachedFileBytes(cacheKey);
          if (cachedBytes != null && cachedBytes.isNotEmpty) {
            cacheStopwatch.stop();
            if (kDebugMode) {
              debugPrint('AVIF cache hit for $url (${cacheStopwatch.elapsedMilliseconds}ms)');
            }
            return _processAvifBytes(cachedBytes, chunkEvents);
          }
        } catch (e) {
          // Cache corruption, continue with network fetch
          cacheStopwatch.stop();
          if (kDebugMode) {
            debugPrint('Cache read failed for $url: $e (${cacheStopwatch.elapsedMilliseconds}ms)');
          }
        }
      }

      // If not in cache or cache failed, fetch from network
      final networkStopwatch = Stopwatch()..start();
      try {
        final resolved = Uri.base.resolve(url);

        final response = await tryGetResponse<List<int>>(
          resolved,
          dio: dio,
          cancelToken: cancelToken,
          fetchStrategy: fetchStrategy,
          options: Options(
            responseType: ResponseType.bytes,
            headers: headers,
            // Add connection timeout for better performance
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(minutes: 2),
          ),
          onReceiveProgress: (count, total) {
            if (!chunkEvents.isClosed && total >= 0) {
              chunkEvents.add(
                ImageChunkEvent(
                  cumulativeBytesLoaded: count,
                  expectedTotalBytes: total,
                ),
              );
            }
          },
        );

        if (response == null || response.data == null) {
          throw StateError('Failed to load $url: Empty response');
        }

        final bytes = Uint8List.fromList(response.data!);
        networkStopwatch.stop();

        if (kDebugMode) {
          debugPrint('AVIF network fetch for $url (${networkStopwatch.elapsedMilliseconds}ms, ${bytes.length} bytes)');
        }

        // Validate bytes before caching
        if (bytes.isNotEmpty && _isValidAvifHeader(bytes)) {
          // Save to cache asynchronously to not block UI
          unawaited(cacheManager.saveFile(cacheKey, bytes));
        }

        return _processAvifBytes(bytes, chunkEvents);
      } on OperationCanceledError catch (_) {
        PaintingBinding.instance.imageCache.evict(key);
        chunkEvents.close();
        throw StateError('User canceled request $url.');
      } catch (e) {
        networkStopwatch.stop();
        PaintingBinding.instance.imageCache.evict(key);
        chunkEvents.close();
        throw StateError('Failed to load $url: $e');
      }
    } finally {
      stopwatch.stop();
      if (kDebugMode) {
        debugPrint('Total AVIF load time for $url: ${stopwatch.elapsedMilliseconds}ms');
      }
    }
  }

  bool _isValidAvifHeader(Uint8List bytes) {
    if (bytes.length < 16) return false;
    try {
      final fType = isAvifFile(bytes.sublist(0, 16));
      return fType != AvifFileType.unknown;
    } catch (e) {
      return false;
    }
  }

  Future<AvifCodec> _processAvifBytes(
    Uint8List bytes,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    chunkEvents.close();

    if (bytes.lengthInBytes == 0) {
      throw StateError('$url is empty and cannot be loaded as an image.');
    }

    final fType = isAvifFile(bytes.sublist(0, 16));
    if (fType == AvifFileType.unknown) {
      throw StateError('$url is not an avif file.');
    }

    final codec = fType == AvifFileType.avif
        ? SingleFrameAvifCodec(bytes: bytes)
        : MultiFrameAvifCodec(
            key: hashCode,
            avifBytes: bytes,
            overrideDurationMs: overrideDurationMs,
          );
    await codec.ready();

    return codec;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is CustomCachedNetworkAvifImageProvider &&
        url == other.url &&
        scale == other.scale &&
        overrideDurationMs == other.overrideDurationMs &&
        cancelToken == other.cancelToken;
  }

  @override
  int get hashCode => Object.hash(url, scale, overrideDurationMs, cancelToken);
}
