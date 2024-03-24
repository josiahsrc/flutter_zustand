import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';

class CounterStore extends Store<int> {
  CounterStore() : super(0);

  void increment() => set(state + 1);
  void reset() => set(0);
}

CounterStore useCounterStore1() => create(() => CounterStore(), tag: '1');
CounterStore useCounterStore2() => create(() => CounterStore(), tag: '2');

class TwoStoreInstancesPage extends StatelessWidget {
  const TwoStoreInstancesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final count1 = useCounterStore1().select(context, (state) => state);
    final count2 = useCounterStore2().select(context, (state) => state);

    final page = Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Zustand Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Counter 1: $count1'),
            Text('Counter 2: $count2'),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                useCounterStore1().reset();
                useCounterStore2().reset();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              useCounterStore1().increment();
            },
            heroTag: '1',
            child: const Text("1"),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              useCounterStore2().increment();
            },
            heroTag: '2',
            child: const Text("2"),
          ),
        ],
      ),
    );

    return page;
  }
}
