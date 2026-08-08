import 'package:flutter/material.dart';
import 'package:libredex/core/widgets/debounced_search_field.dart';

class DexFilterBar extends StatelessWidget {
  final String searchHint;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onClearSearch;
  final String initialSearchValue;
  final VoidCallback onFilterPressed;
  final bool hasActiveFilters;

  const DexFilterBar({
    super.key,
    required this.searchHint,
    required this.onSearchChanged,
    this.onClearSearch,
    this.initialSearchValue = '',
    required this.onFilterPressed,
    required this.hasActiveFilters,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: DebouncedSearchField(
              hintText: searchHint,
              onChanged: onSearchChanged,
              onClear: onClearSearch,
              initialValue: initialSearchValue,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 50,
            width: 52,
            decoration: BoxDecoration(
              color: hasActiveFilters
                  ? Colors.orangeAccent.withValues(alpha: 0.15)
                  : (isDark ? const Color(0xFF141414) : const Color(0xFFEDF2F7)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasActiveFilters
                    ? Colors.orangeAccent
                    : (isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0)),
                width: 1.2,
              ),
            ),
            child: Semantics(
              button: true,
              label: 'Advanced Filters',
              hint: hasActiveFilters ? 'Filters are active' : 'No filters active',
              child: IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: hasActiveFilters ? Colors.orangeAccent : primaryColor,
                ),
                onPressed: onFilterPressed,
                tooltip: 'Advanced Filters',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
