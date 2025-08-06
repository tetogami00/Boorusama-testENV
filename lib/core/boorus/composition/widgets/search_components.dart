// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../search/queries/query.dart';
import '../../../tags/autocompletes/types.dart';

/// Base interface for composable search components
abstract class SearchComponent {
  /// Unique identifier for this component
  String get id;
  
  /// Display order in the search interface
  int get order;
  
  /// Build the widget for this component
  Widget build(BuildContext context, SearchState state);
  
  /// Whether this component can be hidden by user preferences
  bool get isOptional => true;
}

/// Search state container for components
class SearchState {
  const SearchState({
    required this.query,
    required this.suggestions,
    required this.onQueryChanged,
    required this.onSuggestionSelected,
    this.isLoading = false,
  });

  final String query;
  final List<AutocompleteData> suggestions;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<AutocompleteData> onSuggestionSelected;
  final bool isLoading;
}

/// Component for the main search input field
class SearchInputComponent extends SearchComponent {
  const SearchInputComponent({
    this.order = 100,
    this.hint = 'Enter search terms...',
  });

  @override
  String get id => 'search_input';
  
  @override
  final int order;
  
  final String hint;

  @override
  bool get isOptional => false; // Required component

  @override
  Widget build(BuildContext context, SearchState state) {
    return TextField(
      onChanged: state.onQueryChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: state.isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Component for displaying autocomplete suggestions
class SuggestionsComponent extends SearchComponent {
  const SuggestionsComponent({
    this.order = 200,
    this.maxSuggestions = 10,
  });

  @override
  String get id => 'suggestions';
  
  @override
  final int order;
  
  final int maxSuggestions;

  @override
  Widget build(BuildContext context, SearchState state) {
    if (state.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final suggestions = state.suggestions.take(maxSuggestions).toList();
    
    return Card(
      child: Column(
        children: suggestions.map((suggestion) =>
          ListTile(
            title: Text(suggestion.value),
            subtitle: suggestion.count != null 
              ? Text('${suggestion.count} posts')
              : null,
            onTap: () => state.onSuggestionSelected(suggestion),
          )
        ).toList(),
      ),
    );
  }
}

/// Component for popular/trending tags
class TrendingTagsComponent extends SearchComponent {
  const TrendingTagsComponent({
    this.order = 300,
    required this.tags,
  });

  @override
  String get id => 'trending_tags';
  
  @override
  final int order;
  
  final List<String> tags;

  @override
  Widget build(BuildContext context, SearchState state) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trending Tags',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: tags.map((tag) =>
                ActionChip(
                  label: Text(tag),
                  onPressed: () {
                    final newQuery = state.query.isEmpty 
                      ? tag 
                      : '${state.query} $tag';
                    state.onQueryChanged(newQuery);
                  },
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Component for search filters/options
class SearchFiltersComponent extends SearchComponent {
  const SearchFiltersComponent({
    this.order = 400,
    this.availableRatings = const ['safe', 'questionable', 'explicit'],
  });

  @override
  String get id => 'search_filters';
  
  @override
  final int order;
  
  final List<String> availableRatings;

  @override
  Widget build(BuildContext context, SearchState state) {
    return Card(
      child: ExpansionTile(
        title: const Text('Filters'),
        leading: const Icon(Icons.filter_list),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  children: availableRatings.map((rating) =>
                    FilterChip(
                      label: Text(rating),
                      selected: false, // TODO: Connect to actual filter state
                      onSelected: (selected) {
                        // TODO: Handle filter selection
                      },
                    )
                  ).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Composer that arranges search components
class SearchComposer {
  const SearchComposer({
    required this.components,
    this.enabledComponents,
  });

  final List<SearchComponent> components;
  final Set<String>? enabledComponents;

  /// Build the composed search interface
  Widget build(BuildContext context, SearchState state) {
    // Filter and sort components
    final enabledComps = components
        .where((c) => enabledComponents?.contains(c.id) ?? true)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      children: enabledComps
          .map((component) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: component.build(context, state),
              ))
          .toList(),
    );
  }

  /// Get list of optional components that can be enabled/disabled
  List<SearchComponent> get optionalComponents {
    return components.where((c) => c.isOptional).toList();
  }
}

/// Factory for creating common search compositions
class SearchCompositions {
  /// Standard search interface with all common components
  static SearchComposer standard({List<String> trendingTags = const []}) {
    return SearchComposer(
      components: [
        const SearchInputComponent(),
        const SuggestionsComponent(),
        TrendingTagsComponent(tags: trendingTags),
        const SearchFiltersComponent(),
      ],
    );
  }

  /// Minimal search interface with just input and suggestions
  static SearchComposer minimal() {
    return const SearchComposer(
      components: [
        SearchInputComponent(),
        SuggestionsComponent(),
      ],
    );
  }

  /// Custom composition with specific components
  static SearchComposer custom({
    required List<SearchComponent> components,
    Set<String>? enabledComponents,
  }) {
    return SearchComposer(
      components: components,
      enabledComponents: enabledComponents,
    );
  }
}