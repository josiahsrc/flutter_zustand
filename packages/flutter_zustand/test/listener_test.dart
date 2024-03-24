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
        child: Store1Counter(),
      ),
    );
  }
}

class Store1Counter extends StatefulWidget {
  const Store1Counter({super.key});

  @override
  State<Store1Counter> createState() => Store1CounterState();
}

class Store1CounterState extends State<Store1Counter> {
  int rebuilds = 0;
  bool didEmit2 = false;
  int numTimesEmit = 0;

  @override
  Widget build(BuildContext context) {
    rebuilds++;

    final column = Column(
      children: [
        Text('Store1, rebuilds: $rebuilds'),
        ElevatedButton(
          onPressed: () {
            useStore1().increment();
          },
          child: const Text('Increment1'),
        ),
      ],
    );

    return StoreListener(
      [
        useStore1().listen(
          (context, state) {
            numTimesEmit++;
          },
        ),
        useStore1().listen(
          (context, state) {
            didEmit2 = true;
          },
          condition: (prev, next) => prev != next && next == 2,
        ),
      ],
      child: column,
    );
  }
}

void main() {
  testWidgets(
    'emits events when conditions are met',
    (tester) async {
      Store1CounterState getState() {
        return tester.state(find.byType(Store1Counter));
      }

      await tester.pumpWidget(const CounterApp());
      await tester.pumpAndSettle();
      expect(find.text('Store1, rebuilds: 1'), findsOneWidget);

      await tester.tap(find.text('Increment1'));
      await tester.pumpAndSettle();
      expect(find.text('Store1, rebuilds: 1'), findsOneWidget);

      expect(getState().numTimesEmit, 1);
      expect(getState().didEmit2, false);

      await tester.tap(find.text('Increment1'));
      await tester.pumpAndSettle();
      expect(find.text('Store1, rebuilds: 1'), findsOneWidget);

      expect(getState().numTimesEmit, 2);
      expect(getState().didEmit2, true);
    },
  );
}
