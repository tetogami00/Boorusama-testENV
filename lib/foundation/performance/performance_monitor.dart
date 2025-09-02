// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/foundation.dart';

/// Performance monitor for tracking app performance metrics
class PerformanceMonitor {
  PerformanceMonitor._();
  
  static final PerformanceMonitor _instance = PerformanceMonitor._();
  static PerformanceMonitor get instance => _instance;

  final _metrics = <String, _PerformanceMetric>{};
  final _timers = <String, DateTime>{};
  
  /// Start timing an operation
  void startTimer(String operation) {
    _timers[operation] = DateTime.now();
  }
  
  /// End timing and record the metric
  void endTimer(String operation) {
    final startTime = _timers.remove(operation);
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      recordMetric(operation, duration.inMilliseconds.toDouble());
    }
  }
  
  /// Record a performance metric
  void recordMetric(String name, double value) {
    final metric = _metrics.putIfAbsent(name, () => _PerformanceMetric(name));
    metric.addValue(value);
    
    if (kDebugMode) {
      debugPrint('Performance [$name]: ${value.toStringAsFixed(2)}ms (avg: ${metric.average.toStringAsFixed(2)}ms)');
    }
  }
  
  /// Get performance summary
  Map<String, Map<String, double>> getMetrics() {
    return _metrics.map((key, value) => MapEntry(key, {
      'average': value.average,
      'min': value.min,
      'max': value.max,
      'count': value.count.toDouble(),
    }));
  }
  
  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    _timers.clear();
  }
  
  /// Log a summary of all metrics
  void logSummary() {
    if (!kDebugMode) return;
    
    debugPrint('=== Performance Summary ===');
    for (final metric in _metrics.values) {
      debugPrint('${metric.name}: avg=${metric.average.toStringAsFixed(2)}ms, '
          'min=${metric.min.toStringAsFixed(2)}ms, '
          'max=${metric.max.toStringAsFixed(2)}ms, '
          'count=${metric.count}');
    }
    debugPrint('=========================');
  }
}

class _PerformanceMetric {
  _PerformanceMetric(this.name);
  
  final String name;
  final List<double> _values = <double>[];
  
  void addValue(double value) {
    _values.add(value);
    // Keep only the last 100 values to prevent memory leaks
    if (_values.length > 100) {
      _values.removeAt(0);
    }
  }
  
  double get average => _values.isEmpty ? 0.0 : _values.reduce((a, b) => a + b) / _values.length;
  double get min => _values.isEmpty ? 0.0 : _values.reduce(math.min);
  double get max => _values.isEmpty ? 0.0 : _values.reduce(math.max);
  int get count => _values.length;
}

/// Convenience function to time async operations
Future<T> timedOperation<T>(String name, Future<T> Function() operation) async {
  PerformanceMonitor.instance.startTimer(name);
  try {
    return await operation();
  } finally {
    PerformanceMonitor.instance.endTimer(name);
  }
}

/// Convenience function to time sync operations
T timedSync<T>(String name, T Function() operation) {
  PerformanceMonitor.instance.startTimer(name);
  try {
    return operation();
  } finally {
    PerformanceMonitor.instance.endTimer(name);
  }
}