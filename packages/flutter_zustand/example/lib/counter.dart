import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';

class CounterStore extends Store<int> {
  CounterStore() : super(0);

  void increment() => set(state + 1);
  void reset() => set(0);
}

CounterStore useCounterStore() => create(() => CounterStore());

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final count = useCounterStore().select(context, (state) => state);

    final page = Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Zustand Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                useCounterStore().reset();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          useCounterStore().increment();
        },
        child: const Icon(Icons.add),
      ),
    );

    return page;
  }
}
