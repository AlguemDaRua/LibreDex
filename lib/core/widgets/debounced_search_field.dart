import 'dart:async';
import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';

class DebouncedSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String initialValue;
  final Duration debounceDuration;

  const DebouncedSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.initialValue = '',
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _lastQuery = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant DebouncedSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
      _lastQuery = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (!mounted) return;
      if (val != _lastQuery) {
        _lastQuery = val;
        widget.onChanged(val);
      }
    });
    // Trigger setState to show/hide clear icon immediately
    setState(() {});
  }

  void _handleClear() {
    _debounceTimer?.cancel();
    _controller.clear();
    _lastQuery = '';
    widget.onChanged('');
    if (widget.onClear != null) {
      widget.onClear!();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Search Field',
      hint: widget.hintText,
      child: TextField(
        controller: _controller,
        onChanged: _onTextChanged,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.pokemonRed),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: _handleClear,
                  tooltip: 'Clear search',
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF141414) : const Color(0xFFEDF2F7),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppTheme.pokemonRed, width: 1.5),
          ),
        ),
      ),
    );
  }
}
