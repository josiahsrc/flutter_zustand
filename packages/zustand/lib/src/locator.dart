import 'dart:async';

import 'store.dart';

/// The key used to identify a store.
typedef StoreKey = dynamic;

/// Locates and manages stores. Responsible for creating, storing,
/// accessing, and disposing of stores.
class StoreLocator {
  StoreLocator._();
  static StoreLocator? _instance;

  /// Returns the singleton instance of [StoreLocator].
  factory StoreLocator() => _instance ??= StoreLocator._();

  final _factories = <StoreKey, Store Function()>{};
  final _instances = <StoreKey, Store>{};
  final _subscriptions = <StoreKey, StreamSubscription>{};
  final _controller = StreamController<StoreKey>.broadcast();

  /// A stream of changes to [Store]s by their keys. A new value is emitted
  /// whenever a [Store] changes. That [Store]'s key is emitted.
  Stream<StoreKey> get changes => _controller.stream;

  /// Puts a factory function that creates a [Store] with the given [key].
  /// The factory is used to create a [Store] when [get] is called with the
  /// same [key]. A new store is only created if one does not already exist.
  void putFactory(
    StoreKey key,
    Store Function() factory,
  ) {
    _factories[key] = factory;
  }

  /// Puts a [store] with the given [key]. The [store] is used when [get] is
  /// called with the same [key]. Throws a [StateError] if a store with the
  /// same [key] already exists.
  void put(StoreKey key, Store store) {
    if (isCreated(key)) {
      // We want to make sure we don't lose reference to this store, because
      // it must be disposed of. So we throw and force the caller to delete
      // the store first.
      throw StateError('Store $key already exists');
    }

    _instances[key] = store;
    _subscriptions[key] = store.stream.listen((_) => _onChange(key));
  }

  /// Returns `true` if the [key] is registered either as a factory or as an
  /// instance.
  bool contains(StoreKey key) =>
      _factories.containsKey(key) || _instances.containsKey(key);

  /// Returns `true` if a [Store] with the given [key] has an instance.
  bool isCreated(StoreKey key) => _instances.containsKey(key);

  /// Returns the [Store] with the given [key]. If no means of getting an
  /// instance of the [Store] is found, a [StateError] is thrown.
  S get<S extends Store<V>, V>(StoreKey key) {
    if (!contains(key)) {
      throw StateError('Store $key not found');
    }

    if (!_instances.containsKey(key)) {
      final store = _factories[key]!() as S;
      put(key, store);
    }

    return _instances[key] as S;
  }

  /// Deletes the [Store] with the given [key]. If the [Store] is created, it
  /// is disposed of. If the [Store] is not created, it is removed from the
  /// factories. Does nothing if the [key] is not registered.
  Future<void> delete(StoreKey key) async {
    if (isCreated(key)) {
      await _subscriptions[key]!.cancel();
      await (_instances[key] as Store).dispose();
      _subscriptions.remove(key);
      _instances.remove(key);
    }

    _factories.remove(key);
  }

  /// Deletes all instances and factories currently registered.
  Future<void> deleteAll() async {
    final instanceKeys = _instances.keys.toList();
    final factoryKeys = _factories.keys.toList();
    await Future.wait([...factoryKeys, ...instanceKeys].map(delete));
  }

  /// Disposes of the [StoreLocator] and all [Store]s it manages. A new
  /// [StoreLocator] instance will be created next time the [StoreLocator]
  /// singleton is accessed.
  Future<void> dispose() async {
    await _controller.close();
    await deleteAll();
    _instance = null;
  }

  void _onChange(StoreKey key) {
    _controller.add(key);
  }
}
