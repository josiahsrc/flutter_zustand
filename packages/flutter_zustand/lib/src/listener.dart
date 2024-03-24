import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:zustand/zustand.dart';

extension StoreListenerX<V> on Store<V> {
  SingleChildWidget listen(
    StoreListenerCallback<V> callback, {
    StoreListenerCondition<V>? condition,
  }) {
    return StoreReferenceListener<V>(
      store: this,
      callback: callback,
      condition: condition,
    );
  }
}

typedef StoreListenerCallback<V> = void Function(BuildContext context, V state);

typedef StoreListenerCondition<V> = bool Function(V previous, V current);

class StoreReferenceListener<V> extends SingleChildStatefulWidget {
  const StoreReferenceListener({
    super.key,
    required this.store,
    required this.callback,
    this.condition,
  });

  final Store<V> store;
  final StoreListenerCallback<V> callback;
  final StoreListenerCondition<V>? condition;

  @override
  State<StoreReferenceListener<V>> createState() =>
      _StoreReferenceListenerState<V>();
}

class _StoreReferenceListenerState<V>
    extends SingleChildState<StoreReferenceListener<V>> {
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

class StoreListener extends MultiProvider {
  StoreListener(
    List<SingleChildWidget> listeners, {
    required Widget child,
    super.key,
  }) : super(providers: listeners, child: child);
}
