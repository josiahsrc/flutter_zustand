import 'dart:async';

import 'package:flutter/material.dart';

abstract class Store<S> {
  Store(S state) : _state = state {
    init();
  }

  S _state;

  FutureOr<void> init() {}

  FutureOr<void> close() {}

  void set(void Function() fn) {}

  T select<T>(BuildContext context, T Function(S) selector) {
    return selector(_state);
  }

  T listen<T>(
    BuildContext context,
    T Function(S) callback, {
    bool Function(S prev, S next)? condition,
  }) {
    throw UnimplementedError();
  }
}

S create<S extends Store>(S Function() create) {
  throw UnimplementedError();
}

class MyState {
  int a = 0;
  int b = 0;
}

class MyStore extends Store<MyState> {
  MyStore() : super(MyState());

  void incrementA() {
    set(() {
      _state.a++;
    });
  }
}

MyStore useMyStore() => create(() => MyStore());

Widget build(BuildContext context) {
  final a = useMyStore().select(context, (state) => state.a);

  useMyStore().listen(
    context,
    (state) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('a changed to ${state.a}')),
      );
    },
    condition: (prev, next) => prev.a == 5 && next.a == 0,
  );

  return ElevatedButton(
    child: Text('A=$a'),
    onPressed: () {
      useMyStore().incrementA();
    },
  );
}
