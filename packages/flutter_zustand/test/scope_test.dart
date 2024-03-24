import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zustand/flutter_zustand.dart';

import 'helpers.dart';

void main() {
  testWidgets(
    'disposes stores when widget is disposed',
    (tester) async {
      await tester.runAsync(() async {
        final store1 = useStore1();
        final store2 = useStore2();

        expect(store1.isDisposed, isFalse);
        expect(store2.isDisposed, isFalse);

        // dispose the store by changing the on-stage widget
        await tester.pumpWidget(StoreScope(child: Container()));
        await tester.pumpAndSettle();
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();

        await microtask();

        expect(store1.isDisposed, isTrue);
        expect(store2.isDisposed, isTrue);
      });
    },
  );
}
