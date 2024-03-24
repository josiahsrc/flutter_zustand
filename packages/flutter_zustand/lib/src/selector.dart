import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zustand/zustand.dart';

/// Extends the [Store] class with selector methods that allow you to watch
/// atomic slices of the [Store.state].
extension StoreSelectorX<V> on Store<V> {
  /// Allows you to watch an atomic slice of a [Store.state]. Intended to be
  /// used in the `build` method. Causes the enclosing widget to rebuild when
  /// the selected value changes.
  /// 
  /// ```
  /// Widget build(BuildContext context) {
  ///   final nuts = useBearStore().select(context, (state) => state.nuts);
  /// }
  /// ```
  T select<T>(
    BuildContext context,
    T Function(V state) selector,
  ) {
    return context.select<StoreLocator, T>(
      (_) => selector(state),
    );
  }
}
