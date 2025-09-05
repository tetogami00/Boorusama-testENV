// Dart imports:
import 'dart:async';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../http_utils.dart';

class ImageRequestDeduplicateInterceptor extends Interceptor {
  ImageRequestDeduplicateInterceptor({
    this.isImageRequest = defaultImageRequestChecker,
  });

  final bool Function(Uri uri) isImageRequest;

  final _pendingRequests = <String, Completer<Response>>{};
  final _responseCache = <String, Response>{}; // Add response cache
  static const _maxCacheSize = 100;
  static const _cacheTimeout = Duration(minutes: 5);

  String _deduplicateKey(RequestOptions options) {
    // Include relevant headers in cache key for better deduplication
    final relevantHeaders = <String, dynamic>{
      if (options.headers.containsKey('user-agent'))
        'user-agent': options.headers['user-agent'],
      if (options.headers.containsKey('referer'))
        'referer': options.headers['referer'],
    };
    
    return '${options.uri}${relevantHeaders.isNotEmpty ? '_${relevantHeaders.hashCode}' : ''}';
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    // Make sure this is an image request
    if (!isImageRequest(options.uri)) {
      return handler.next(options);
    }

    final key = _deduplicateKey(options);

    // Check if we have a cached response first
    final cachedResponse = _responseCache[key];
    if (cachedResponse != null) {
      // Clone the response to avoid modification issues
      final clonedResponse = Response<dynamic>(
        data: cachedResponse.data,
        headers: cachedResponse.headers,
        statusCode: cachedResponse.statusCode,
        statusMessage: cachedResponse.statusMessage,
        requestOptions: options,
      );
      return handler.resolve(clonedResponse);
    }

    // Check if there's already a pending request with the same key
    if (_pendingRequests.containsKey(key)) {
      // A request is already in-flight, we will complete this request by attaching to the existing future
      final existingCompleter = _pendingRequests[key]!;

      // When the existingCompleter completes, we just fulfill the new request with the same response
      existingCompleter.future.then(
        (response) {
          // Clone the response for this request
          final clonedResponse = Response<dynamic>(
            data: response.data,
            headers: response.headers,
            statusCode: response.statusCode,
            statusMessage: response.statusMessage,
            requestOptions: options,
          );
          handler.resolve(clonedResponse);
        },
        onError: (err) {
          handler.reject(err);
        },
      );
    } else {
      // No existing request, so create a new Completer for this key
      final completer = Completer<Response>();
      _pendingRequests[key] = completer;

      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final key = _deduplicateKey(response.requestOptions);

    // Cache successful responses for a short time
    if (response.statusCode == 200) {
      _addToCache(key, response);
    }

    // If we have a completer for this response, complete it
    final completer = _pendingRequests[key];
    if (completer != null && !completer.isCompleted) {
      completer.complete(response);
      _pendingRequests.remove(key);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final key = _deduplicateKey(err.requestOptions);

    // Complete the future with an error if still pending
    final completer = _pendingRequests[key];
    if (completer != null && !completer.isCompleted) {
      completer.completeError(err);
      _pendingRequests.remove(key);
    }

    handler.next(err);
  }

  void _addToCache(String key, Response response) {
    // Manage cache size
    if (_responseCache.length >= _maxCacheSize) {
      // Remove oldest entries (simple FIFO, could be improved with LRU)
      final keysToRemove = _responseCache.keys.take(_maxCacheSize ~/ 4).toList();
      for (final key in keysToRemove) {
        _responseCache.remove(key);
      }
    }

    _responseCache[key] = response;

    // Auto-expire cache entries
    Timer(_cacheTimeout, () {
      _responseCache.remove(key);
    });
  }

  void clearCache() {
    _responseCache.clear();
    _pendingRequests.clear();
  }
}
