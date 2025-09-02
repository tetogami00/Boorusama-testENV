// Dart imports:
import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../memory_cache.dart';
import '../image_cache_manager.dart';

/// Image preloader that can warm up the cache with commonly accessed images
class ImagePreloader {
  ImagePreloader({
    required this.dio,
    required this.cacheManager,
    required this.memoryCache,
    this.maxConcurrentPreloads = 3,
  });

  final Dio dio;
  final ImageCacheManager cacheManager;
  final MemoryCache memoryCache;
  final int maxConcurrentPreloads;

  final Set<String> _preloadingUrls = <String>{};
  final Set<String> _preloadedUrls = <String>{};

  /// Preload a single image
  Future<bool> preloadImage(String url) async {
    if (_preloadingUrls.contains(url) || _preloadedUrls.contains(url)) {
      return true;
    }

    _preloadingUrls.add(url);

    try {
      final cacheKey = cacheManager.generateCacheKey(url);
      
      // Check if already in memory cache
      if (memoryCache.contains(cacheKey)) {
        _preloadedUrls.add(url);
        return true;
      }

      // Check if in disk cache
      final hasValidCache = await cacheManager.hasValidCache(cacheKey);
      if (hasValidCache) {
        final cachedBytes = await cacheManager.getCachedFileBytes(cacheKey);
        if (cachedBytes != null && cachedBytes.isNotEmpty) {
          // Load into memory cache
          memoryCache.put(cacheKey, cachedBytes);
          _preloadedUrls.add(url);
          if (kDebugMode) {
            debugPrint('Preloaded from disk cache: $url');
          }
          return true;
        }
      }

      // Download from network
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data!);
        
        // Save to both caches
        await cacheManager.saveFile(cacheKey, bytes);
        memoryCache.put(cacheKey, bytes);
        
        _preloadedUrls.add(url);
        if (kDebugMode) {
          debugPrint('Preloaded from network: $url (${bytes.length} bytes)');
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to preload $url: $e');
      }
      return false;
    } finally {
      _preloadingUrls.remove(url);
    }
  }

  /// Preload multiple images with concurrency control
  Future<List<bool>> preloadImages(List<String> urls) async {
    final results = <bool>[];
    final semaphore = Semaphore(maxConcurrentPreloads);

    final futures = urls.map((url) async {
      await semaphore.acquire();
      try {
        return await preloadImage(url);
      } finally {
        semaphore.release();
      }
    });

    results.addAll(await Future.wait(futures));
    return results;
  }

  /// Preload images based on priority (e.g., visible items first)
  Future<void> preloadImagesByPriority(
    Map<String, int> urlPriorities, {
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    // Sort URLs by priority (higher priority first)
    final sortedUrls = urlPriorities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedUrls) {
      if (!_preloadedUrls.contains(entry.key) && 
          !_preloadingUrls.contains(entry.key)) {
        
        // Add delay to prevent overwhelming the network
        if (delay > Duration.zero) {
          await Future.delayed(delay);
        }
        
        unawaited(preloadImage(entry.key));
      }
    }
  }

  /// Get preload statistics
  Map<String, int> getStatistics() {
    return {
      'preloaded': _preloadedUrls.length,
      'preloading': _preloadingUrls.length,
      'total_requested': _preloadedUrls.length + _preloadingUrls.length,
    };
  }

  /// Clear preload tracking
  void clear() {
    _preloadingUrls.clear();
    _preloadedUrls.clear();
  }

  /// Check if an image is preloaded
  bool isPreloaded(String url) => _preloadedUrls.contains(url);

  /// Check if an image is currently preloading
  bool isPreloading(String url) => _preloadingUrls.contains(url);
}

/// A simple semaphore implementation for controlling concurrency
class Semaphore {
  Semaphore(this.maxCount) : _currentCount = maxCount;

  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}