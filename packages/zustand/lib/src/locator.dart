import 'dart:async';

import 'store.dart';

S create<S extends Store<V>, V>(S Function() create) {
  StoreLocator().register<S, V>(S, create);
  return StoreLocator().get(S);
}

class StoreLocator {
  StoreLocator._();
  factory StoreLocator() => _instance ??= StoreLocator._();
  static StoreLocator? _instance;

  final _factories = <dynamic, dynamic Function()>{};
  final _instances = <dynamic, dynamic>{};
  final _subscriptions = <dynamic, StreamSubscription>{};
  final _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get changes => _controller.stream;

  void register<S extends Store<V>, V>(
    dynamic key,
    Store<V> Function() factory,
  ) {
    _factories[key] = factory;
  }

  S get<S extends Store<V>, V>(dynamic key) {
    if (!_instances.containsKey(key)) {
      final store = _factories[key]!() as S;
      _instances[key] = store;
      _subscriptions[key] = store.stream.listen((_) => _onChange(key));
    }
    return _instances[key] as S;
  }

  void _onChange(dynamic key) {
    _controller.add(key);
  }
}
