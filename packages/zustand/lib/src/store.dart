import 'dart:async';

import 'package:meta/meta.dart';

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
