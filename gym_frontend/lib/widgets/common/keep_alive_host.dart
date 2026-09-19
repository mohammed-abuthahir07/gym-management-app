import 'package:flutter/material.dart';

/// Keeps visited role pages alive so returning to a tab does not re-run
/// initState / refetch APIs. Unvisited pages are not built.
class KeepAliveHost extends StatefulWidget {
  const KeepAliveHost({
    super.key,
    required this.index,
    required this.builders,
  });

  final int index;
  final List<WidgetBuilder> builders;

  @override
  State<KeepAliveHost> createState() => _KeepAliveHostState();
}

class _KeepAliveHostState extends State<KeepAliveHost> {
  late List<Widget?> _pages;

  @override
  void initState() {
    super.initState();
    _pages = List<Widget?>.filled(widget.builders.length, null);
    _ensure(widget.index);
  }

  @override
  void didUpdateWidget(KeepAliveHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.builders.length != widget.builders.length) {
      final next = List<Widget?>.filled(widget.builders.length, null);
      for (var i = 0; i < _pages.length && i < next.length; i++) {
        next[i] = _pages[i];
      }
      _pages = next;
    }
    _ensure(widget.index);
  }

  void _ensure(int index) {
    if (index < 0 || index >= _pages.length) return;
    _pages[index] ??= widget.builders[index](context);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < _pages.length; i++)
          _pages[i] ?? const SizedBox.shrink(),
      ],
    );
  }
}
