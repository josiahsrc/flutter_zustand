import 'dart:async';

import 'package:meta/meta.dart';

import 'locator.dart';

/// Base class for all stores. Holds a state and emits changes whenever
/// [set] is called.
///
/// [V] is the type of state. It's recommended that you use an immutable
/// type for the state.
abstract class Store<V> {
  /// Creates a new store with the given initial [state].
  Store(V state) : _state = state;

  final _subject = StreamController<V>.broadcast();
  V _state;
  bool _disposed = false;

  /// A stream of [state] changes. A new value is emitted whenever [set] is
  /// called.
  Stream<V> get stream {
    return _subject.stream;
  }

  /// The current [state] of the store.
  V get state => _state;

  /// Whether [dispose] has been called on this store.
  bool get isDisposed => _disposed;

  /// Sets the [state] of the store and emits a change event.
  @visibleForTesting
  @protected
  void set(V value) {
    if (isDisposed) {
      throw StateError('Cannot set state on a disposed store');
    }

    _state = value;
    _subject.add(value);
  }

  /// Called when the store is closed. Typically invoked by the [StoreLocator].
  /// Use this to clean up any resources.
  @mustCallSuper
  Future<void> dispose() async {
    await _subject.close();
    _disposed = true;
  }
}
