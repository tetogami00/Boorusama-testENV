// Dart imports:
import 'dart:collection';

// Project imports:
import 'cacher.dart';

class CacheObject<K, V> {
  const CacheObject(this.node, this.value);

  final K node;
  final V value;
}

class LruCacher<K, V> implements Cacher<K, V> {
  LruCacher({
    this.capacity = 50,
  });

  final int capacity;
  final _cache = <K, _CacheNode<K, V>>{};
  _CacheNode<K, V>? _head;
  _CacheNode<K, V>? _tail;

  // Performance metrics
  int _hits = 0;
  int _misses = 0;

  double get hitRate => _hits + _misses > 0 ? _hits / (_hits + _misses) : 0.0;
  int get size => _cache.length;

  bool get _atMax => _cache.length >= capacity;

  @override
  void clear() {
    _cache.clear();
    _head = null;
    _tail = null;
    _hits = 0;
    _misses = 0;
  }

  @override
  bool exist(K key) {
    final exists = _cache.containsKey(key);
    if (exists) {
      final node = _cache[key]!;
      _moveToFront(node);
    }
    return exists;
  }

  @override
  V? get(K key) {
    final node = _cache[key];
    if (node != null) {
      _moveToFront(node);
      _hits++;
      return node.value.value;
    }
    _misses++;
    return null;
  }

  @override
  Future<void> put(K key, V item) async {
    final existingNode = _cache[key];
    if (existingNode != null) {
      // Update existing entry
      existingNode.value = CacheObject(key, item);
      _moveToFront(existingNode);
      return;
    }

    if (_atMax) {
      _evictLeastRecentlyUsed();
    }

    final newNode = _CacheNode(CacheObject(key, item));
    _cache[key] = newNode;
    _addToFront(newNode);
  }

  void remove(K key) {
    final node = _cache.remove(key);
    if (node != null) {
      _removeNode(node);
    }
  }

  void _addToFront(_CacheNode<K, V> node) {
    if (_head == null) {
      _head = _tail = node;
    } else {
      node.next = _head;
      _head!.prev = node;
      _head = node;
    }
  }

  void _removeNode(_CacheNode<K, V> node) {
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

  void _moveToFront(_CacheNode<K, V> node) {
    _removeNode(node);
    _addToFront(node);
  }

  void _evictLeastRecentlyUsed() {
    if (_tail != null) {
      final key = _tail!.value.node;
      _cache.remove(key);
      _removeNode(_tail!);
    }
  }
}

class _CacheNode<K, V> {
  _CacheNode(this.value);
  
  CacheObject<K, V> value;
  _CacheNode<K, V>? prev;
  _CacheNode<K, V>? next;
}
