import 'dart:async';
import 'package:flutter/material.dart';
import 'package:libredex/core/theme/app_theme.dart';

class DebouncedSearchField extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String initialValue;

  /// Minimum gap between two emissions.
  ///
  /// This is a throttle with a guaranteed trailing emit, not a plain trailing
  /// debounce, because a plain debounce is wrong for search-as-you-type: it
  /// cancels the pending timer on every keystroke, so a typist whose
  /// inter-keystroke gap is shorter than the delay never sees the results move
  /// until they stop. That reads as "I have to type the whole name".
  ///
  /// Keep this comfortably below the ~180 ms gap between keystrokes of an
  /// average typist. Anything near or above that and the list stops tracking
  /// the query while the user is still typing.
  final Duration throttleDuration;

  const DebouncedSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.onClear,
    this.initialValue = '',
    this.throttleDuration = const Duration(milliseconds: 100),
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late final TextEditingController _controller;
  Timer? _trailingTimer;
  DateTime? _lastEmitAt;
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
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
      _lastQuery = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _trailingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _emit(String val) {
    _lastEmitAt = DateTime.now();
    if (val == _lastQuery) return;
    _lastQuery = val;
    widget.onChanged(val);
  }

  void _onTextChanged(String val) {
    final last = _lastEmitAt;
    final now = DateTime.now();

    if (last == null || now.difference(last) >= widget.throttleDuration) {
      // Long enough since the last emission: show results now, so the list
      // starts narrowing from the very first keystroke.
      _trailingTimer?.cancel();
      _emit(val);
    } else {
      // Too soon. Coalesce into one trailing emit so fast typing cannot
      // outrun the throttle and strand the final value.
      final remaining = widget.throttleDuration - now.difference(last);
      _trailingTimer?.cancel();
      _trailingTimer = Timer(remaining, () {
        if (!mounted) return;
        _emit(val);
      });
    }
    // Trigger setState to show/hide clear icon immediately
    setState(() {});
  }

  void _handleClear() {
    _trailingTimer?.cancel();
    _controller.clear();
    _emit('');
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
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.pokemonRed,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: _handleClear,
                  tooltip: 'Clear search',
                )
              : null,
          filled: true,
          fillColor: isDark ? const Color(0xFF141414) : const Color(0xFFEDF2F7),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? const Color(0xFF222222) : const Color(0xFFE2E8F0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppTheme.pokemonRed,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
