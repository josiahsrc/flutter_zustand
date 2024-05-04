import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zustand/flutter_zustand.dart';
import 'package:flutter_zustand/src/disposer.dart';
import 'package:zustand/zustand.dart';

import 'helpers.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  bool _show2 = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StoreScope(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _show2 = !_show2;
                });
              },
              child: const Text('Toggle'),
            ),
            if (_show2) const Store2Counter() else const Store1Counter(),
          ],
        ),
      ),
    );
  }
}

class Store1Counter extends StatefulWidget {
  const Store1Counter({super.key});

  @override
  State<Store1Counter> createState() => _Store1CounterState();
}

class _Store1CounterState extends State<Store1Counter> {
  int rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    rebuilds++;
    final count = useStore1().select(context, (state) => state);

    return StoreDisposer(
      [
        useStore1(),
      ],
      child: Column(
        children: [
          Text('Store1: $count, rebuilds: $rebuilds'),
          ElevatedButton(
            onPressed: () {
              useStore1().increment();
            },
            child: const Text('Increment1'),
          ),
        ],
      ),
    );
  }
}

class Store2Counter extends StatefulWidget {
  const Store2Counter({super.key});

  @override
  State<Store2Counter> createState() => _Store2CounterState();
}

class _Store2CounterState extends State<Store2Counter> {
  int rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    rebuilds++;
    final count = useStore2().select(context, (state) => state);

    return StoreDisposer(
      [
        useStore2(),
      ],
      child: Column(
        children: [
          Text('Store2: $count, rebuilds: $rebuilds'),
          ElevatedButton(
            onPressed: () {
              useStore2().increment();
            },
            child: const Text('Increment2'),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets(
    'disposes of stores when removed from the tree',
    (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(const CounterApp());
        await tester.pumpAndSettle();

        expect(find.text('Store1: 0, rebuilds: 1'), findsOneWidget);
        expect(find.text('Store2: 0, rebuilds: 1'), findsNothing);

        expect(StoreLocator().get(Store1), isNotNull);
        expect(StoreLocator().get(Store1).isDisposed, isFalse);
        expect(() => StoreLocator().get(Store2), throwsA(isA<StateError>()));
        final store1 = StoreLocator().get(Store1);

        await tester.tap(find.text('Toggle'));
        await tester.pumpAndSettle();
        await microtask();

        expect(find.text('Store1: 0, rebuilds: 1'), findsNothing);
        expect(find.text('Store2: 0, rebuilds: 1'), findsOneWidget);

        expect(store1.isDisposed, isTrue);
        expect(() => StoreLocator().get(Store1), throwsA(isA<StateError>()));
        expect(StoreLocator().get(Store2), isNotNull);
        expect(StoreLocator().get(Store2).isDisposed, isFalse);

        // it is recreated when toggled back
        await tester.tap(find.text('Toggle'));
        await tester.pumpAndSettle();
        await microtask();

        expect(find.text('Store1: 0, rebuilds: 1'), findsOneWidget);
        expect(find.text('Store2: 0, rebuilds: 1'), findsNothing);

        expect(StoreLocator().get(Store1), isNotNull);
        expect(StoreLocator().get(Store1).isDisposed, isFalse);
        expect(() => StoreLocator().get(Store2), throwsA(isA<StateError>()));
      });
    },
  );
}
