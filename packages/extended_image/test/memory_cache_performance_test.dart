// Dart imports:
import 'dart:typed_data';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import '../lib/src/memory_cache.dart';

void main() {
  group('LRUMemoryCache Performance Tests', () {
    late LRUMemoryCache cache;

    setUp(() {
      cache = LRUMemoryCache(maxEntries: 100, maxSizePerEntry: 1024);
    });

    test('should have O(1) access time', () {
      // Pre-populate cache
      for (int i = 0; i < 100; i++) {
        cache.put('key$i', Uint8List.fromList([i]));
      }

      final stopwatch = Stopwatch()..start();
      
      // Test many accesses
      for (int i = 0; i < 1000; i++) {
        cache.get('key${i % 100}');
      }
      
      stopwatch.stop();
      
      // Should be very fast (less than 10ms for 1000 operations)
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('should maintain correct hit rate tracking', () {
      // Add some items
      cache.put('key1', Uint8List.fromList([1]));
      cache.put('key2', Uint8List.fromList([2]));
      
      // Mix of hits and misses
      cache.get('key1'); // hit
      cache.get('key3'); // miss
      cache.get('key2'); // hit
      cache.get('key4'); // miss
      
      expect(cache.hitRate, equals(0.5)); // 2 hits out of 4 attempts
    });

    test('should evict least recently used items efficiently', () {
      // Fill cache to capacity
      for (int i = 0; i < 100; i++) {
        cache.put('key$i', Uint8List.fromList([i]));
      }
      
      // Access first item to make it most recently used
      cache.get('key0');
      
      // Add new item (should evict something that's not key0)
      cache.put('newkey', Uint8List.fromList([255]));
      
      // key0 should still exist
      expect(cache.get('key0'), isNotNull);
      
      // Some other key should be evicted
      int nullCount = 0;
      for (int i = 1; i < 100; i++) {
        if (cache.get('key$i') == null) {
          nullCount++;
        }
      }
      expect(nullCount, equals(1)); // Exactly one item should be evicted
    });

    test('should handle large data efficiently', () {
      final largeData = Uint8List(1000); // 1KB data
      
      final stopwatch = Stopwatch()..start();
      
      // Add many large items
      for (int i = 0; i < 50; i++) {
        cache.put('large$i', largeData);
      }
      
      stopwatch.stop();
      
      // Should be reasonably fast even with large data
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('should reject oversized items', () {
      final oversizedData = Uint8List(2048); // 2KB > 1KB limit
      
      cache.put('oversized', oversizedData);
      
      // Should not be stored
      expect(cache.get('oversized'), isNull);
      expect(cache.contains('oversized'), isFalse);
    });

    test('should clear all metrics on clear', () {
      cache.put('key1', Uint8List.fromList([1]));
      cache.get('key1'); // Generate some metrics
      cache.get('nonexistent'); // Generate miss
      
      expect(cache.hitRate, greaterThan(0));
      
      cache.clear();
      
      expect(cache.hitRate, equals(0.0));
      expect(cache.get('key1'), isNull);
    });
  });
}