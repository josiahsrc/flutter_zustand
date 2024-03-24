import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:zustand/zustand.dart';

/// An extension on [Store] that exposes some helpful utilities for listening
/// to store changes.
extension StoreListenerX<V> on Store<V> {
  /// Creates a listener widget that listens for changes to this [store].
  ///
  /// Intended to be used with a [StoreListener] widget.
  SingleChildWidget listen(
    StoreListenerCallback<V> callback, {
    StoreListenerCondition<V>? condition,
  }) {
    return _StoreReferenceListener<V>(
      store: this,
      callback: callback,
      condition: condition,
    );
  }
}

/// A callback that is invoked when a store's [Store.state] changes.
typedef StoreListenerCallback<V> = void Function(BuildContext context, V state);

/// A predicate that determines whether a store's [Store.state] has changed.
typedef StoreListenerCondition<V> = bool Function(V previous, V current);

class _StoreReferenceListener<V> extends SingleChildStatefulWidget {
  const _StoreReferenceListener({
    super.key,
    required this.store,
    required this.callback,
    this.condition,
  });

  final Store<V> store;
  final StoreListenerCallback<V> callback;
  final StoreListenerCondition<V>? condition;

  @override
  State<_StoreReferenceListener<V>> createState() =>
      _StoreReferenceListenerState<V>();
}

class _StoreReferenceListenerState<V>
    extends SingleChildState<_StoreReferenceListener<V>> {
  StreamSubscription? _sub;
  late V _prevState;

  @override
  void initState() {
    super.initState();
    _prevState = widget.store.state;
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _sub = widget.store.stream.listen((state) {
      if (widget.condition?.call(_prevState, state) ?? true) {
        widget.callback(context, state);
      }
      _prevState = state;
    });
  }

  void _unsubscribe() {
    _sub?.cancel();
    _sub = null;
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return child!;
  }
}

/// Registers listeners for multiple stores. The stores do not have to be of the
/// same type.
///
/// Listeners can be created using the [StoreListenerX.listen] method.
///
/// ```
/// Widget build(BuildContext context) {
///   return StoreListener(
///     [
///       useBearStore().listen(
///         (context, state) {
///           print("There are $state bears");
///         },
///         condition: (prev, next) => prev != next && next == 5,
///       ),
///     ],
///     child: Container(...),
///   );
/// }
/// ```
class StoreListener extends MultiProvider {
  /// Creates a [StoreListener] widget.
  StoreListener(
    List<SingleChildWidget> listeners, {
    required Widget child,
    super.key,
  }) : super(providers: listeners, child: child);
}
