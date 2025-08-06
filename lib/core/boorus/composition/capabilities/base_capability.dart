/// Base interface for all booru capabilities
/// 
/// Each capability represents a distinct feature set that can be
/// composed together to build a complete booru implementation.
abstract class BooruCapability {
  /// Unique identifier for this capability
  String get id;
  
  /// Human-readable name for this capability
  String get name;
  
  /// Whether this capability is essential for basic booru functionality
  bool get isRequired => false;
  
  /// Dependencies that must be available for this capability to work
  List<String> get dependencies => const [];
  
  /// Check if this capability can be enabled with the given dependencies
  bool canEnable(Set<String> availableCapabilities) {
    return dependencies.every(availableCapabilities.contains);
  }
}
