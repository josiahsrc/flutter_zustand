import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zustand/flutter_zustand.dart';

import 'helpers.dart';

class CounterApp extends StatelessWidget {
  const CounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: StoreScope(
        child: Column(
          children: [
            Store1Counter(),
            Store2Counter(),
            NotObserved(),
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

    return Column(
      children: [
        Text('Store1: $count, rebuilds: $rebuilds'),
        ElevatedButton(
          onPressed: () {
            useStore1().increment();
          },
          child: const Text('Increment1'),
        ),
      ],
    );
  }
}

class NotObserved extends StatefulWidget {
  const NotObserved({super.key});

  @override
  State<NotObserved> createState() => _NotObservedState();
}

class _NotObservedState extends State<NotObserved> {
  int rebuilds = 0;

  @override
  Widget build(BuildContext context) {
    rebuilds++;
    final count = useStore1().select(context, (state) => 0);
    return Text("Not observed: $count, rebuilds: $rebuilds");
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

    return Column(
      children: [
        Text('Store2: $count, rebuilds: $rebuilds'),
        ElevatedButton(
          onPressed: () {
            useStore2().increment();
          },
          child: const Text('Increment2'),
        ),
      ],
    );
  }
}

void main() {
  testWidgets(
    'updates the appropriate widget when stores change',
    (tester) async {
      await tester.pumpWidget(const CounterApp());
      await tester.pumpAndSettle();

      expect(find.text('Store1: 0, rebuilds: 1'), findsOneWidget);
      expect(find.text('Store2: 0, rebuilds: 1'), findsOneWidget);
      expect(find.text('Not observed: 0, rebuilds: 1'), findsOneWidget);

      await tester.tap(find.text('Increment1'));
      await tester.pumpAndSettle();

      expect(find.text('Store1: 1, rebuilds: 2'), findsOneWidget);
      expect(find.text('Store2: 0, rebuilds: 1'), findsOneWidget);
      expect(find.text('Not observed: 0, rebuilds: 1'), findsOneWidget);

      await tester.tap(find.text('Increment2'));
      await tester.pumpAndSettle();

      expect(find.text('Store1: 1, rebuilds: 2'), findsOneWidget);
      expect(find.text('Store2: 1, rebuilds: 2'), findsOneWidget);
      expect(find.text('Not observed: 0, rebuilds: 1'), findsOneWidget);
    },
  );
}
