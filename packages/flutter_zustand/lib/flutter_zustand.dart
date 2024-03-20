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
  T select<T>(
    BuildContext context,
    T Function(S) selector, {
    DependencyGetter<S>? dependencies,
  }) {
    return selector(this);
  }

  T listen<T>(
    BuildContext context,
    T Function(S) callback, {
    DependencyGetter<S>? dependencies,
  }) {
    throw UnimplementedError();
  }
}

S create<S extends Store>(S Function() create) {
  throw UnimplementedError();
}
