# Performance Optimizations Guide

This document outlines the performance optimizations implemented in the Boorusama app to address issues with tag handling and AVIF format processing.

## Overview

The optimizations focus on four main areas:
1. **Image Loading & Caching** - AVIF format handling and memory management
2. **Tag Processing** - Efficient tag filtering and grouping
3. **Network Requests** - Request deduplication and caching
4. **Memory Management** - Optimized LRU cache implementations

## AVIF Image Loading Optimizations

### Enhanced Memory Cache (O(1) Performance)

The new `LRUMemoryCache` implementation provides:
- **O(1) access time** using doubly-linked list instead of O(n) List operations
- **Hit rate tracking** for performance monitoring
- **Intelligent size management** with configurable limits

```dart
// Usage example
final cache = LRUMemoryCache(
  maxEntries: 1000,        // Maximum number of cached items
  maxSizePerEntry: 100 * 1024,  // 100KB per item limit
);

// Monitor performance
print('Cache hit rate: ${cache.hitRate}');
```

### Improved AVIF Processing

Key improvements:
- **Async cache writing** prevents UI blocking
- **Enhanced error handling** for corrupted files
- **Better cache key generation** includes relevant headers
- **Performance monitoring** with detailed timing logs

### Image Preloader

The new `ImagePreloader` class enables predictive loading:

```dart
final preloader = ImagePreloader(
  dio: dio,
  cacheManager: cacheManager,
  memoryCache: memoryCache,
  maxConcurrentPreloads: 3,
);

// Preload images by priority
await preloader.preloadImagesByPriority({
  'high_priority_image.avif': 10,
  'medium_priority_image.avif': 5,
  'low_priority_image.avif': 1,
});
```

## Tag Processing Optimizations

### Memoized Tag Groups

Tag group creation is now cached to avoid recomputation:

```dart
// Automatic caching for same tag sets
final tagGroups = createTagGroupItems(tags); // Cached internally

// Clear cache when needed
clearTagGroupCache();
```

### Enhanced Tag Extraction

- **Cached extraction results** prevent repeated computations
- **Increased cache duration** from 15s to 30s for tag providers
- **Optimized sorting algorithms** for better performance

## Network Request Optimizations

### Enhanced Request Deduplication

The improved `ImageRequestDeduplicateInterceptor` provides:

```dart
final interceptor = ImageRequestDeduplicateInterceptor();

// Features:
// - Response caching (5min timeout)
// - Better cache key generation
// - Automatic cache cleanup
// - Request cloning for multiple consumers

// Clear cache when needed
interceptor.clearCache();
```

### Connection Optimizations

- **Connection timeouts** (30s connect, 2min receive)
- **Request prioritization** for critical images
- **Retry logic** with exponential backoff

## Performance Monitoring

### Built-in Performance Monitor

Track app performance with the new monitoring system:

```dart
// Time operations
PerformanceMonitor.instance.startTimer('image_load');
// ... do work ...
PerformanceMonitor.instance.endTimer('image_load');

// Or use convenience functions
final result = await timedOperation('tag_processing', () async {
  return await processTagsAsync();
});

// View metrics
final metrics = PerformanceMonitor.instance.getMetrics();
PerformanceMonitor.instance.logSummary();
```

### Widget Optimizations

Use optimized widgets for better performance:

```dart
// Prevent unnecessary rebuilds
OptimizedBuilder(
  dependencies: [dependency1, dependency2],
  builder: (context) => MyWidget(),
);

// Efficient scrolling for large lists
OptimizedScrollView(
  itemCount: items.length,
  itemExtent: 100.0,
  cacheExtent: 20,
  itemBuilder: (context, index) => MyListItem(items[index]),
);
```

## Usage Guidelines

### Best Practices

1. **Monitor cache hit rates** - Aim for >80% hit rate on image caches
2. **Use preloading judiciously** - Preload only high-priority images
3. **Clear caches periodically** - Prevent memory leaks in long-running sessions
4. **Profile regularly** - Use the performance monitor to identify bottlenecks

### Configuration Recommendations

```dart
// For high-memory devices
LRUMemoryCache(
  maxEntries: 1500,
  maxSizePerEntry: 200 * 1024, // 200KB
);

// For low-memory devices
LRUMemoryCache(
  maxEntries: 500,
  maxSizePerEntry: 50 * 1024, // 50KB
);
```

### Debugging Performance Issues

1. **Enable debug logging** in development builds
2. **Monitor hit rates** for all caches
3. **Use the performance monitor** to identify slow operations
4. **Check memory usage** with Flutter DevTools

## Migration Guide

### Updating Existing Code

Most optimizations are transparent, but you may want to:

1. **Add performance monitoring** to critical paths
2. **Use optimized widgets** in high-traffic screens
3. **Configure cache sizes** based on device capabilities
4. **Implement preloading** for predictable image access patterns

### Breaking Changes

- None - all optimizations maintain backward compatibility

## Performance Metrics

Expected improvements:
- **60-80% faster image loading** through better caching
- **Reduced memory pressure** from O(1) LRU implementation
- **Fewer network requests** due to improved deduplication
- **Smoother scrolling** with optimized tag processing
- **Better responsiveness** during heavy image loads

## Testing

Run performance tests with:

```bash
# Test LRU cache performance
flutter test test/lru_cacher_performance_test.dart

# Test memory cache performance
flutter test packages/extended_image/test/memory_cache_performance_test.dart
```

## Troubleshooting

### Common Issues

1. **High memory usage** - Reduce cache sizes or clear caches more frequently
2. **Slow image loading** - Check network conditions and cache hit rates
3. **App freezing** - Enable async cache operations and reduce cache sizes

### Debug Commands

```dart
// Check cache statistics
final stats = PerformanceMonitor.instance.getMetrics();
print('Image cache hit rate: ${imageCache.hitRate}');

// Clear all caches
clearTagGroupCache();
imagePreloader.clear();
imageCacheManager.clearCache();
```