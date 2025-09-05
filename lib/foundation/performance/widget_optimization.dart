// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A mixin that provides debouncing functionality to widgets
mixin DebounceMixin<T extends StatefulWidget> on State<T> {
  Timer? _debounceTimer;
  
  /// Debounce a function call
  void debounce(Duration duration, VoidCallback action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, action);
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// A widget that rebuilds only when its dependencies actually change
class OptimizedBuilder extends StatefulWidget {
  const OptimizedBuilder({
    super.key,
    required this.builder,
    this.dependencies,
  });

  final Widget Function(BuildContext context) builder;
  final List<Object?>? dependencies;

  @override
  State<OptimizedBuilder> createState() => _OptimizedBuilderState();
}

class _OptimizedBuilderState extends State<OptimizedBuilder> {
  List<Object?>? _lastDependencies;
  Widget? _cachedWidget;
  
  @override
  Widget build(BuildContext context) {
    final currentDependencies = widget.dependencies;
    
    // Check if dependencies have changed
    if (_cachedWidget == null || !listEquals(_lastDependencies, currentDependencies)) {
      _cachedWidget = widget.builder(context);
      _lastDependencies = currentDependencies;
      
      if (kDebugMode) {
        debugPrint('OptimizedBuilder: Rebuilding widget due to dependency change');
      }
    } else {
      if (kDebugMode) {
        debugPrint('OptimizedBuilder: Using cached widget');
      }
    }
    
    return _cachedWidget!;
  }
}

/// A mixin that provides efficient list management for widgets
mixin ListOptimizationMixin {
  /// Calculate the optimal item extent for a list
  double calculateOptimalItemExtent({
    required double availableHeight,
    required int itemCount,
    double minItemHeight = 100.0,
    double maxItemHeight = 300.0,
  }) {
    if (itemCount == 0) return minItemHeight;
    
    final calculatedHeight = availableHeight / itemCount;
    return calculatedHeight.clamp(minItemHeight, maxItemHeight);
  }
  
  /// Determine if an item should be cached based on its position
  bool shouldCacheItem({
    required int index,
    required int visibleStartIndex,
    required int visibleEndIndex,
    int cacheExtent = 20,
  }) {
    return index >= (visibleStartIndex - cacheExtent) &&
           index <= (visibleEndIndex + cacheExtent);
  }
}

/// A widget that provides memory-efficient scrolling for large lists
class OptimizedScrollView extends StatefulWidget {
  const OptimizedScrollView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemExtent,
    this.cacheExtent = 20,
    this.scrollDirection = Axis.vertical,
    this.controller,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double? itemExtent;
  final int cacheExtent;
  final Axis scrollDirection;
  final ScrollController? controller;

  @override
  State<OptimizedScrollView> createState() => _OptimizedScrollViewState();
}

class _OptimizedScrollViewState extends State<OptimizedScrollView> 
    with ListOptimizationMixin {
  final Map<int, Widget> _cachedWidgets = <int, Widget>{};
  int _visibleStart = 0;
  int _visibleEnd = 0;
  
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _updateVisibleRange(notification);
        return false;
      },
      child: ListView.builder(
        controller: widget.controller,
        scrollDirection: widget.scrollDirection,
        itemCount: widget.itemCount,
        itemExtent: widget.itemExtent,
        itemBuilder: (context, index) {
          // Use cached widget if available and within cache range
          if (_cachedWidgets.containsKey(index) && 
              shouldCacheItem(
                index: index,
                visibleStartIndex: _visibleStart,
                visibleEndIndex: _visibleEnd,
                cacheExtent: widget.cacheExtent,
              )) {
            return _cachedWidgets[index]!;
          }
          
          // Build new widget
          final widget = this.widget.itemBuilder(context, index);
          
          // Cache if within range
          if (shouldCacheItem(
            index: index,
            visibleStartIndex: _visibleStart,
            visibleEndIndex: _visibleEnd,
            cacheExtent: this.widget.cacheExtent,
          )) {
            _cachedWidgets[index] = widget;
          }
          
          return widget;
        },
      ),
    );
  }
  
  void _updateVisibleRange(ScrollNotification notification) {
    if (widget.itemExtent == null) return;
    
    final metrics = notification.metrics;
    final itemExtent = widget.itemExtent!;
    
    final newStart = (metrics.pixels / itemExtent).floor().clamp(0, widget.itemCount - 1);
    final newEnd = ((metrics.pixels + metrics.viewportDimension) / itemExtent)
        .ceil()
        .clamp(0, widget.itemCount - 1);
    
    if (newStart != _visibleStart || newEnd != _visibleEnd) {
      setState(() {
        _visibleStart = newStart;
        _visibleEnd = newEnd;
      });
      
      // Clean up cached widgets outside the cache range
      _cleanupCache();
    }
  }
  
  void _cleanupCache() {
    final keysToRemove = <int>[];
    
    for (final key in _cachedWidgets.keys) {
      if (!shouldCacheItem(
        index: key,
        visibleStartIndex: _visibleStart,
        visibleEndIndex: _visibleEnd,
        cacheExtent: widget.cacheExtent,
      )) {
        keysToRemove.add(key);
      }
    }
    
    for (final key in keysToRemove) {
      _cachedWidgets.remove(key);
    }
    
    if (kDebugMode && keysToRemove.isNotEmpty) {
      debugPrint('OptimizedScrollView: Cleaned up ${keysToRemove.length} cached widgets');
    }
  }
  
  @override
  void dispose() {
    _cachedWidgets.clear();
    super.dispose();
  }
}