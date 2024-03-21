import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

typedef StoreFactory<S extends Store> = S Function();

class _Locator {
  _Locator._();
  factory _Locator() => _instance ??= _Locator._();
  static _Locator? _instance;

  final _factories = <Type, dynamic Function()>{};
  final _instances = <Type, dynamic>{};
  final _subscriptions = <Type, StreamSubscription>{};
  final _controller = StreamController<Type>.broadcast();

  Stream<Type> get changes => _controller.stream;

  void register<S extends Store>(StoreFactory<S> factory) {
    _factories[S] = factory;
  }

  S get<S extends Store>() {
    if (!_instances.containsKey(S)) {
      final store = _factories[S]!() as S;
      _instances[S] = store;
      _subscriptions[S] = store._controller.stream.listen((_) => _onChange(S));
    }
    return _instances[S] as S;
  }

  void _onChange(Type type) {
    _controller.add(type);
  }
}

S create<S extends Store>(StoreFactory<S> create) {
  _Locator().register(create);
  return _Locator().get<S>();
}

// Zustand enforces state immutability. Its set fucntion merges the new values
// and emits a new state.
//
// It's starting to seem that the main advantage here is global stores.
abstract class Store {
  Store();

  final _controller = StreamController<void>.broadcast();

  Stream<void> get changes => _controller.stream;

  @protected
  void set(void Function() fn) {
    fn();
    _controller.add(null);
  }
}

extension StoreX<S extends Store> on S {
  T select<T>(
    BuildContext context,
    T Function(S) selector,
  ) {
    return context.select<_Locator, T>(
      (locator) {
        final store = locator.get<S>();
        return selector(store);
      },
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
    return InheritedProvider<_Locator>.value(
      value: _Locator(),
      startListening: _startListening,
      lazy: false,
      child: child,
    );
  }

  static VoidCallback _startListening(
    InheritedContext<_Locator?> e,
    _Locator value,
  ) {
    final subscription = value.changes.listen(
      (dynamic _) => e.markNeedsNotifyDependents(),
    );
    return subscription.cancel;
  }
}

typedef StoreContextCallback<S extends Store> = void Function(
  BuildContext context,
  S store,
);

class StoreListener<S extends Store> extends SingleChildStatefulWidget {
  const StoreListener({
    super.key,
    this.onChange,
    this.onInit,
    this.onDispose,
    required Widget child,
  }) : super(child: child);

  final StoreContextCallback<S>? onChange;
  final StoreContextCallback<S>? onInit;
  final StoreContextCallback<S>? onDispose;

  @override
  StoreListenerState<S> createState() => StoreListenerState<S>();
}

class StoreListenerState<S extends Store>
    extends SingleChildState<StoreListener<S>> {
  StreamSubscription<void>? _sub;

  S get _store => _Locator().get<S>();

  @override
  void initState() {
    super.initState();
    _subscribe();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onInit?.call(context, _store);
    });
  }

  @override
  void dispose() {
    _unsubscribe();
    widget.onDispose?.call(context, _store);
    super.dispose();
  }

  void _subscribe() {
    _sub ??= _store.changes.listen(
      (_) => widget.onChange?.call(context, _store),
    );
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
