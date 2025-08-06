// Project imports:
import '../../../configs/config.dart';
import '../../../tags/autocompletes/autocomplete_repository.dart';
import '../../../tags/autocompletes/types.dart';
import '../../engine/src/booru_builder_types.dart';
import 'base_capability.dart';

/// Capability for search functionality
abstract class SearchCapability extends BooruCapability {
  @override
  String get id => 'search';
  
  @override
  String get name => 'Search';
  
  @override
  bool get isRequired => true;

  /// Builder for the search page
  SearchPageBuilder get searchPageBuilder;
  
  /// Tag suggestion item builder
  TagSuggestionItemBuilder get tagSuggestionItemBuilder;
  
  /// Autocomplete repository for tag suggestions
  AutocompleteRepository autocomplete(BooruConfigAuth config);
  
  /// Optional metatag extractor builder
  MetatagExtractorBuilder? get metatagExtractorBuilder => null;
}

/// Default implementation of SearchCapability
class DefaultSearchCapability extends SearchCapability {
  DefaultSearchCapability({
    required this.searchPageBuilder,
    required this.tagSuggestionItemBuilder,
    required this.autocompleteFactory,
    this.metatagExtractorBuilder,
  });

  @override
  final SearchPageBuilder searchPageBuilder;
  
  @override
  final TagSuggestionItemBuilder tagSuggestionItemBuilder;
  
  @override
  final MetatagExtractorBuilder? metatagExtractorBuilder;
  
  final AutocompleteRepository Function(BooruConfigAuth config) autocompleteFactory;
  
  @override
  AutocompleteRepository autocomplete(BooruConfigAuth config) => autocompleteFactory(config);
}
