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

  T event<T>(
    BuildContext context,
    T Function(S) listener, {
    bool Function(S prev, S next)? condition,
  }) {
    throw UnimplementedError();
  }
}

void registerStore<T extends Store>(T store) {
  registerLazyStore(() => store);
}

void registerLazyStore<T extends Store>(T Function() store) {
  throw UnimplementedError();
}

T useStore<T extends Store>() {
  throw UnimplementedError();
}

// might need to be immutable? otherwise how do prev?
class MyState {
  int a = 0;
  int b = 0;
}

// This is just like a cubit, but it's not provided in the build context
// I'm beginning to think that what makes zustand so good is how it pairs
// nicely with typescript. Using ...spread to update the state feels so
// natural in typescript.
//
// The question here is then: Is a global store, shown below, worth it?
// Does it add value?
class MyStore extends Store<MyState> {
  MyStore(super.state);

  void incrementA() {
    set(() {
      _state.a++;
    });
  }
}

Widget build(BuildContext context) {
  final a = useStore<MyStore>().select(context, (state) => state.a);

  useStore<MyStore>().event(
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
      useStore<MyStore>().incrementA();
    },
  );
}
