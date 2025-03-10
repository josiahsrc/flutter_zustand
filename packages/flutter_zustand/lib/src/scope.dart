import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zustand/zustand.dart';

import 'internal.dart';

/// Provides a [StoreLocator] instance to its descendants. Descendant widgets
/// observe this changes to the [StoreLocator] and rebuild accordingly.
///
/// Intended to be placed at the root of your widget tree.
///
/// ```
/// void main() {
///   runApp(const StoreScope(child: MyApp()));
/// }
/// ```
class StoreScope extends StatefulWidget {
  /// Creates a [StoreScope] widget.
  const StoreScope({
    super.key,
    required this.child,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<StoreScope> createState() {
    return _StoreScopeState();
  }
}

class _StoreScopeState extends State<StoreScope> {
  ScopeData _data = const ScopeData();
  late StreamSubscription _sub;
  bool _pending = false;
  bool _notify = false;

  @override
  void initState() {
    _sub = StoreLocator().changes.listen(
      (changes) {
        _notify = true;
        setState(() => _data = _data.withNewChange(changes));
        _clearChangesPostFrame();
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _sub.cancel();
    StoreLocator().dispose();
    super.dispose();
  }

  void _clearChangesPostFrame() {
    if (_pending) {
      return;
    }

    _pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _data.changes.clear();
      _pending = false;
      _notify = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedStoreScope(
      data: _data,
      notify: _notify,
      child: widget.child,
    );
  }
}
