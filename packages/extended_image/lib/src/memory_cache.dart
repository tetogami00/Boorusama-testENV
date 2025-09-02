import 'dart:typed_data';
import 'package:flutter/foundation.dart';

abstract class MemoryCache {
  Uint8List? get(String key);
  void put(String key, Uint8List data);
  bool contains(String key);
  void remove(String key);
  void clear();
}

class LRUMemoryCache implements MemoryCache {
  LRUMemoryCache({
    this.maxEntries = 1000,
    this.maxSizePerEntry = 100 * 1024, // 100KB
  });

  final int maxEntries;
  final int maxSizePerEntry;

  final Map<String, _CacheNode> _cache = <String, _CacheNode>{};
  _CacheNode? _head;
  _CacheNode? _tail;
  int _currentSize = 0;

  // Performance metrics
  int _hits = 0;
  int _misses = 0;

  double get hitRate => _hits + _misses > 0 ? _hits / (_hits + _misses) : 0.0;

  @override
  Uint8List? get(String key) {
    final node = _cache[key];
    if (node != null) {
      _moveToFront(node);
      _hits++;
      return node.data;
    }
    _misses++;
    return null;
  }

  @override
  void put(String key, Uint8List data) {
    // Skip if data is too large
    if (data.length > maxSizePerEntry) {
      return;
    }

    final existingNode = _cache[key];
    if (existingNode != null) {
      // Update existing entry
      existingNode.data = data;
      _moveToFront(existingNode);
      return;
    }

    // Ensure we have space
    while (_cache.length >= maxEntries && _cache.isNotEmpty) {
      _evictLeastRecentlyUsed();
    }

    // Add new entry
    final newNode = _CacheNode(key, data);
    _cache[key] = newNode;
    _addToFront(newNode);
    _currentSize++;
  }

  @override
  bool contains(String key) {
    final exists = _cache.containsKey(key);
    if (exists) {
      final node = _cache[key]!;
      _moveToFront(node);
    }
    return exists;
  }

  @override
  void remove(String key) {
    final node = _cache.remove(key);
    if (node != null) {
      _removeNode(node);
      _currentSize--;
    }
  }

  @override
  void clear() {
    _cache.clear();
    _head = null;
    _tail = null;
    _currentSize = 0;
    _hits = 0;
    _misses = 0;
  }

  void _addToFront(_CacheNode node) {
    if (_head == null) {
      _head = _tail = node;
    } else {
      node.next = _head;
      _head!.prev = node;
      _head = node;
    }
  }

  void _removeNode(_CacheNode node) {
    if (node.prev != null) {
      node.prev!.next = node.next;
    } else {
      _head = node.next;
    }

    if (node.next != null) {
      node.next!.prev = node.prev;
    } else {
      _tail = node.prev;
    }
  }

  void _moveToFront(_CacheNode node) {
    _removeNode(node);
    _addToFront(node);
  }

  void _evictLeastRecentlyUsed() {
    if (_tail != null) {
      final key = _tail!.key;
      _cache.remove(key);
      _removeNode(_tail!);
      _currentSize--;
    }
  }
}

class _CacheNode {
  _CacheNode(this.key, this.data);
  
  final String key;
  Uint8List data;
  _CacheNode? prev;
  _CacheNode? next;
}
