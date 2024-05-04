import 'package:flutter/material.dart';
import 'package:zustand/zustand.dart';

/// A convenience widget that disposes of a set of stores after being removed
/// from the widget tree. This is useful when you know you won't need a
/// store anymore and want to free up its resources.
///
/// ```
/// StoreDisposer(
///  [store1, store2],
///  child: MyWidget(),
/// )
/// ```
class StoreDisposer extends StatefulWidget {
  /// Creates a [StoreDisposer] widget.
  const StoreDisposer(
    this.stores, {
    super.key,
    required this.child,
  });

  /// The stores to dispose after this widget is removed from the tree.
  final List<Store> stores;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  State<StoreDisposer> createState() => _StoreDisposerState();
}

class _StoreDisposerState extends State<StoreDisposer> {
  @override
  void dispose() {
    for (final store in widget.stores) {
      StoreLocator().delete(store.runtimeType);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
