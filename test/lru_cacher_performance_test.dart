// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import '../lib/foundation/caching/lru_cacher.dart';

void main() {
  group('LRU Cacher Performance Tests', () {
    late LruCacher<String, String> cacher;

    setUp(() {
      cacher = LruCacher<String, String>(capacity: 100);
    });

    test('should provide O(1) access performance', () {
      // Pre-populate cache
      for (int i = 0; i < 100; i++) {
        cacher.put('key$i', 'value$i');
      }

      final stopwatch = Stopwatch()..start();
      
      // Test many accesses
      for (int i = 0; i < 1000; i++) {
        cacher.get('key${i % 100}');
      }
      
      stopwatch.stop();
      
      // Should be very fast (less than 10ms for 1000 operations)
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('should track hit rate correctly', () {
      cacher.put('key1', 'value1');
      cacher.put('key2', 'value2');
      
      // Mix of hits and misses
      cacher.get('key1'); // hit
      cacher.get('key3'); // miss
      cacher.get('key2'); // hit
      cacher.get('key4'); // miss
      
      expect(cacher.hitRate, equals(0.5));
    });

    test('should evict items when at capacity', () {
      // Fill to capacity
      for (int i = 0; i < 100; i++) {
        cacher.put('key$i', 'value$i');
      }
      
      expect(cacher.size, equals(100));
      
      // Add one more item
      cacher.put('newkey', 'newvalue');
      
      // Should still be at capacity
      expect(cacher.size, equals(100));
      
      // New key should exist
      expect(cacher.get('newkey'), equals('newvalue'));
    });

    test('should maintain LRU order correctly', () {
      cacher.put('key1', 'value1');
      cacher.put('key2', 'value2');
      cacher.put('key3', 'value3');
      
      // Access key1 to make it most recently used
      cacher.get('key1');
      
      // Fill cache to capacity
      for (int i = 4; i <= 100; i++) {
        cacher.put('key$i', 'value$i');
      }
      
      // Add one more to trigger eviction
      cacher.put('key101', 'value101');
      
      // key1 should still exist (was accessed recently)
      expect(cacher.get('key1'), equals('value1'));
      
      // key2 or key3 should be evicted (least recently used)
      final key2Exists = cacher.exist('key2');
      final key3Exists = cacher.exist('key3');
      expect(key2Exists && key3Exists, isFalse); // At least one should be evicted
    });

    test('should handle rapid updates efficiently', () {
      final stopwatch = Stopwatch()..start();
      
      // Rapid updates to same keys
      for (int i = 0; i < 1000; i++) {
        cacher.put('key${i % 10}', 'value$i');
      }
      
      stopwatch.stop();
      
      // Should handle updates efficiently
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
      expect(cacher.size, lessThanOrEqualTo(10));
    });

    test('should clear metrics on clear', () {
      cacher.put('key1', 'value1');
      cacher.get('key1'); // hit
      cacher.get('nonexistent'); // miss
      
      expect(cacher.hitRate, greaterThan(0));
      
      cacher.clear();
      
      expect(cacher.hitRate, equals(0.0));
      expect(cacher.size, equals(0));
    });
  });
}