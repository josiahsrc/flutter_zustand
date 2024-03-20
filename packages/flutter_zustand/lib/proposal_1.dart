import 'dart:async';

import 'package:flutter/material.dart';

abstract class Store {
  FutureOr<void> init() {}

  FutureOr<void> close() {}

  @protected
  void set(void Function() fn) {}
}

extension StoreX<S extends Store> on S {
  T select<T>(BuildContext context, T Function(S) selector) {
    return selector(this);
  }
}

void registerStore<S extends Store>(S store) {
  registerLazyStore(() => store);
}

void registerLazyStore<S extends Store>(S Function() store) {
  throw UnimplementedError();
}

S useStore<S extends Store>() {
  throw UnimplementedError();
}

class MyStore extends Store {
  int a = 0;
  int b = 0;

  int get c => a + b;

  void incrementA() {
    set(() => a++);
  }

  void incrementB() {
    set(() => b++);
  }

  Future<void> longTask() async {
    set(() {
      a = 10;
    });
    await Future.delayed(const Duration(seconds: 1));
    set(() {
      a = -1;
    });
  }
}

Widget build(BuildContext context) {
  final a = useStore<MyStore>().select(context, (state) => state.a);
  final b = useStore<MyStore>().select(context, (state) => state.b);

  throw UnimplementedError();
}
