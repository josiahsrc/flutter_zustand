import 'dart:async';

import 'store.dart';

typedef StoreKey = dynamic;

class StoreLocator {
  StoreLocator._();
  factory StoreLocator() => _instance ??= StoreLocator._();
  static StoreLocator? _instance;

  final _factories = <StoreKey, Store Function()>{};
  final _instances = <StoreKey, Store>{};
  final _subscriptions = <StoreKey, StreamSubscription>{};
  final _controller = StreamController<StoreKey>.broadcast();

  Stream<StoreKey> get changes => _controller.stream;

  void putFactory(
    StoreKey key,
    Store Function() factory,
  ) {
    _factories[key] = factory;
  }

  void put(StoreKey key, Store store) {
    _instances[key] = store;
    _subscriptions[key] = store.stream.listen((_) => _onChange(key));
  }

  S get<S extends Store<V>, V>(StoreKey key) {
    if (!_instances.containsKey(key)) {
      final store = _factories[key]!() as S;
      put(key, store);
    }
    return _instances[key] as S;
  }

  Future<void> remove(StoreKey key) async {
    if (!_instances.containsKey(key)) {
      return;
    }

    await _subscriptions[key]!.cancel();
    await (_instances[key] as Store).dispose();
    _subscriptions.remove(key);
    _instances.remove(key);
    _factories.remove(key);
  }

  Future<void> dispose() async {
    await _controller.close();
    final keys = _instances.keys.toList();
    await Future.wait(keys.map(remove));
    _instance = null;
  }

  void _onChange(StoreKey key) {
    _controller.add(key);
  }
}
