import 'package:zustand/zustand.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  tearDown(() {
    StoreLocator().dispose();
  });

  test('emits state changes', () async {
    final store = useStore1();
    final states = <int>[];

    store.stream.listen(states.add);

    store.increment();
    store.increment();
    store.reset();

    await microtask();
    expect(states, [1, 2, 0]);
  });

  test('throws when setting state on disposed store', () async {
    final store = useStore1();
    await store.dispose();
    expect(() => store.increment(), throwsStateError);
  });

  test('can be listened to multiple times', () async {
    final store = useStore1();
    final states1 = <int>[];
    final states2 = <int>[];

    store.stream.listen(states1.add);
    store.stream.listen(states2.add);

    store.increment();

    await microtask();
    expect(states1, [1]);
    expect(states2, [1]);
  });
}
