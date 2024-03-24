import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

typedef StoreFactory<S extends Store<V>, V> = S Function();

typedef StateSelector<S extends Store<V>, V, T> = T Function(V state);

class StoreLocator {
  StoreLocator._();
  factory StoreLocator() => _instance ??= StoreLocator._();
  static StoreLocator? _instance;

  final _factories = <Type, dynamic Function()>{};
  final _instances = <Type, dynamic>{};
  final _subscriptions = <Type, StreamSubscription>{};
  final _controller = StreamController<Type>.broadcast();

  Stream<Type> get changes => _controller.stream;

  void register<S extends Store<V>, V>(StoreFactory<S, V> factory) {
    _factories[S] = factory;
  }

  S getStatic<S extends Store<V>, V>() {
    return getRuntime(S) as S;
  }

  Store<V> getRuntime<V>(Type type) {
    if (!_instances.containsKey(type)) {
      final store = _factories[type]!() as Store<V>;
      _instances[type] = store;
      _subscriptions[type] = store.stream.listen((_) => _onChange(type));
    }
    return _instances[type] as Store<V>;
  }

  void _onChange(Type type) {
    _controller.add(type);
  }
}

S create<S extends Store<V>, V>(StoreFactory<S, V> create) {
  StoreLocator().register(create);
  return StoreLocator().getStatic<S, V>();
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

extension StoreSelectorX<V> on Store<V> {
  T select<T>(
    BuildContext context,
    T Function(V) selector,
  ) {
    return context.select<StoreLocator, T>(
      (locator) {
        final store = locator.getRuntime<V>(runtimeType);
        return selector(store.state);
      },
    );
  }
}

extension StoreListenerX<V> on Store<V> {
  SingleChildWidget listen(
    StoreListenerCallback<V> callback, {
    StoreListenerCondition<V>? condition,
  }) {
    return RuntimeStoreListener<V>(
      type: runtimeType,
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

class RuntimeStoreListener<V> extends SingleChildStatefulWidget {
  const RuntimeStoreListener({
    super.key,
    required this.type,
    required this.callback,
    this.condition,
  });

  final Type type;
  final StoreListenerCallback<V> callback;
  final StoreListenerCondition<V>? condition;

  @override
  State<RuntimeStoreListener<V>> createState() => _StoreListenerState<V>();
}

class _StoreListenerState<V> extends SingleChildState<RuntimeStoreListener<V>> {
  StreamSubscription? _sub;
  late V _prevState;

  Store<V> get _store => StoreLocator().getRuntime<V>(widget.type);

  @override
  void initState() {
    super.initState();
    _prevState = _store.state;
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _sub = _store.stream.listen((state) {
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
