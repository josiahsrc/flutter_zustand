import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';

abstract class BaseCounterStore extends Store<int> {
  BaseCounterStore() : super(0);

  void increment() => set(state + 1);
  void reset() => set(0);
}

class CounterStore1 extends BaseCounterStore {}

class CounterStore2 extends BaseCounterStore {}

CounterStore1 useCounterStore1() => create(() => CounterStore1());
CounterStore2 useCounterStore2() => create(() => CounterStore2());

class Select1 extends StatefulWidget {
  const Select1({super.key});

  @override
  State<Select1> createState() => _Select1State();
}

class _Select1State extends State<Select1> {
  int select = 0;

  @override
  Widget build(BuildContext context) {
    final count = useCounterStore1().select(context, (state) {
      select += 1;
      return state;
    });
    return Text('Count 1: $count, Select 1: $select');
  }
}

class Select2 extends StatefulWidget {
  const Select2({super.key});

  @override
  State<Select2> createState() => _Select2State();
}

class _Select2State extends State<Select2> {
  int select = 0;

  @override
  Widget build(BuildContext context) {
    final count = useCounterStore2().select(context, (state) {
      select += 1;
      return state;
    });
    return Text('Count 2: $count, Select 2: $select');
  }
}

class TwoStoresPage extends StatelessWidget {
  const TwoStoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final page = Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Zustand Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Select1(),
            const Select2(),
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
