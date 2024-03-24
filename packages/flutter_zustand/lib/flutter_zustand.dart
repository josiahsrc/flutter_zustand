import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class StoreLocator {
  StoreLocator._();
  factory StoreLocator() => _instance ??= StoreLocator._();
  static StoreLocator? _instance;

  final _factories = <dynamic, dynamic Function()>{};
  final _instances = <dynamic, dynamic>{};
  final _subscriptions = <dynamic, StreamSubscription>{};
  final _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get changes => _controller.stream;

  void register<V>(
    dynamic key,
    Store<V> Function() factory,
  ) {
    _factories[key] = factory;
  }

  Store<V> get<V>(dynamic key) {
    if (!_instances.containsKey(key)) {
      final store = _factories[key]!() as Store<V>;
      _instances[key] = store;
      _subscriptions[key] = store.stream.listen((_) => _onChange(key));
    }
    return _instances[key] as Store<V>;
  }

  void _onChange(dynamic key) {
    _controller.add(key);
  }
}

S create<S extends Store<V>, V>(S Function() create) {
  StoreLocator().register(S, create);
  return StoreLocator().get(S) as S;
}

abstract class Store<V> {
  Store(V state) : _state = state;

  final _subject = StreamController<V>.broadcast();
  V _state;

  Stream<V> get stream => _subject.stream;

  V get state => _state;

  @protected
  void set(V value) {
    _state = value;
    _subject.add(value);
  }
}

typedef StateSelector<V, T> = T Function(V state);

extension StoreSelectorX<V> on Store<V> {
  T select<T>(
    BuildContext context,
    StateSelector<V, T> selector,
  ) {
    return context.select<StoreLocator, T>(
      (_) => selector(state),
    );
  }
}

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

class StoreScope extends SingleChildStatelessWidget {
  const StoreScope({
    super.key,
    required Widget child,
  }) : super(child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return InheritedProvider<StoreLocator>.value(
      value: StoreLocator(),
      startListening: _startListening,
      lazy: false,
      child: child,
    );
  }

  static VoidCallback _startListening(
    InheritedContext<StoreLocator?> e,
    StoreLocator value,
  ) {
    final subscription = value.changes.listen(
      (dynamic _) => e.markNeedsNotifyDependents(),
    );
    return subscription.cancel;
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
