import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';

abstract class BaseCounterStore extends Store<int> {
  BaseCounterStore() : super(0);

  void increment() => set(state + 1);
  void reset() => set(0);
}

class CounterStore1 extends BaseCounterStore {}

class CounterStore2 extends BaseCounterStore {}

BaseCounterStore useCounterStore1() => create(() => CounterStore1());
BaseCounterStore useCounterStore2() => create(() => CounterStore2());

class TwoStoresPage extends StatefulWidget {
  const TwoStoresPage({super.key});

  @override
  State<TwoStoresPage> createState() => _TwoStoresPageState();
}

class _TwoStoresPageState extends State<TwoStoresPage> {
  int select1 = 0;
  int select2 = 0;

  @override
  Widget build(BuildContext context) {
    final count1 = useCounterStore1().select(context, (state) {
      select1 += 1;
      return state;
    });

    final count2 = useCounterStore2().select(context, (state) {
      select2 += 1;
      return state;
    });

    final page = Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Zustand Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Count 1: $count1'),
            Text('Count 2: $count2'),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                useCounterStore1().reset();
                useCounterStore2().reset();
              },
            ),
            Text('Select 1: $select1'),
            Text('Select 2: $select2'),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 4,
        children: [
          FloatingActionButton(
            heroTag: '1',
            onPressed: () {
              useCounterStore1().increment();
            },
            child: const Text('1'),
          ),
          FloatingActionButton(
            heroTag: '2',
            onPressed: () {
              useCounterStore2().increment();
            },
            child: const Text('2'),
          ),
        ],
      ),
    );

    return page;
  }
}
