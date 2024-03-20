import 'dart:async';

import 'package:flutter/material.dart';

class ZustandScope extends StatelessWidget {
  const ZustandScope({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

abstract class Store {
  Store();

  FutureOr<void> init() {}

  FutureOr<void> close() {}

  void set(void Function() fn) {}
}

typedef DependencyGetter<S> = List<dynamic> Function(S);

extension StoreX<S extends Store> on S {
  // Whenever set is called, this is invoked. If the store implements an
  // equality function, we could use that. But basically everytime I write a
  // bloc, I watch everything becauase I'm too lazy to watch specific fields.
  // Using that assumption, we prefer to watch everything, but use an equality
  // function when it's useful
  T select<T>(
    BuildContext context,
    T Function(S) selector,
    DependencyGetter<S>? watch,
  ) {
    return selector(this);
  }

  // Bloc uses curr and prev to listen. This only works with an immutable state.
  // We don't want to enforce immutability. It's often easier to store a
  // "prev" value in the store, than it is to maintain an immutable state. We'll
  // run with that assumption.
  T listen<T>(
    BuildContext context,
    T Function(S) callback, {
    DependencyGetter<S>? watch,
  }) {
    throw UnimplementedError();
  }
}

S create<S extends Store>(S Function() create) {
  throw UnimplementedError();
}
