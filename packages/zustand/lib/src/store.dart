import 'dart:async';

import 'package:meta/meta.dart';

abstract class Store<V> {
  Store(V state) : _state = state;

  final _subject = StreamController<V>.broadcast();
  V _state;
  bool _disposed = false;

  Stream<V> get stream {
    return _subject.stream;
  }

  V get state => _state;

  bool get isDisposed => _disposed;

  @visibleForTesting
  @protected
  void set(V value) {
    if (isDisposed) {
      throw StateError('Cannot set state on a disposed store');
    }

    _state = value;
    _subject.add(value);
  }

  @mustCallSuper
  Future<void> dispose() async {
    await _subject.close();
    _disposed = true;
  }
}
