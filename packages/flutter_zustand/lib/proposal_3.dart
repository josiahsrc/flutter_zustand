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

extension StoreX<S extends Store> on S {
  T select<T>(BuildContext context, T Function(S) selector) {
    return selector(this);
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

class ExampleStore extends Store {
  int a = 0;

  void incrementA() {
    set(() {
      a++;
    });
  }
}

ExampleStore useExampleStore() => create(() => ExampleStore());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final a = useExampleStore().select(context, (state) => state.a);

    useExampleStore().listen(
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
        useExampleStore().incrementA();
      },
    );
  }
}

void main(List<String> args) {
  runApp(const ZustandScope(child: ExampleApp()));
}
