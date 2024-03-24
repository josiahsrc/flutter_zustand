import 'dart:async';

import 'package:zustand/zustand.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  tearDown(() {
    StoreLocator().dispose();
  });

  test('only creates one store', () async {
    var timesCalled = 0;

    Store1 useTest() => create(() {
          timesCalled++;
          return Store1();
        });

    useTest();
    expect(timesCalled, 1);

    useTest();
    expect(timesCalled, 1);

    useTest();
    expect(timesCalled, 1);

    await StoreLocator().dispose();

    useTest();
    expect(timesCalled, 2);

    useTest();
    expect(timesCalled, 2);
  });

  group('Store', () {
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
  });

  group('StoreLocator', () {
    late bool store1Created;
    late bool store2Created;
    StreamSubscription? subscription;

    Store1 createStore1() {
      store1Created = true;
      return Store1();
    }

    Store2 createStore2() {
      store2Created = true;
      return Store2();
    }

    setUp(() {
      store1Created = false;
      store2Created = false;
    });

    tearDown(() async {
      await subscription?.cancel();
    });

    test('creates factory instances', () {
      StoreLocator().putFactory(Store1, createStore1);
      StoreLocator().putFactory(Store2, createStore2);
      expect(store1Created, isFalse);
      expect(store2Created, isFalse);

      StoreLocator().get(Store1);
      expect(store1Created, isTrue);
      expect(store2Created, isFalse);

      StoreLocator().get(Store2);
      expect(store1Created, isTrue);
      expect(store2Created, isTrue);
    });

    test('containment checks work as expected', () async {
      StoreLocator().putFactory(Store1, createStore1);
      expect(StoreLocator().contains(Store1), isTrue);
      expect(StoreLocator().contains(Store2), isFalse);
      expect(StoreLocator().isCreated(Store1), isFalse);
      expect(StoreLocator().isCreated(Store2), isFalse);

      StoreLocator().put(Store2, Store2());
      expect(StoreLocator().contains(Store1), isTrue);
      expect(StoreLocator().contains(Store2), isTrue);
      expect(StoreLocator().isCreated(Store1), isFalse);
      expect(StoreLocator().isCreated(Store2), isTrue);

      StoreLocator().get(Store1);
      expect(StoreLocator().contains(Store1), isTrue);
      expect(StoreLocator().contains(Store2), isTrue);
      expect(StoreLocator().isCreated(Store1), isTrue);
      expect(StoreLocator().isCreated(Store2), isTrue);

      await StoreLocator().delete(Store1);
      expect(StoreLocator().contains(Store1), isFalse);
      expect(StoreLocator().contains(Store2), isTrue);
      expect(StoreLocator().isCreated(Store1), isFalse);
      expect(StoreLocator().isCreated(Store2), isTrue);

      await StoreLocator().dispose();
      expect(StoreLocator().contains(Store1), isFalse);
      expect(StoreLocator().contains(Store2), isFalse);
      expect(StoreLocator().isCreated(Store1), isFalse);
      expect(StoreLocator().isCreated(Store2), isFalse);
    });

    test('dispose all stores', () async {
      StoreLocator().putFactory(Store1, createStore1);
      StoreLocator().putFactory(Store2, createStore2);

      final store1 = StoreLocator().get(Store1);
      final store2 = StoreLocator().get(Store2);

      expect(store1.isDisposed, isFalse);
      expect(store2.isDisposed, isFalse);

      await StoreLocator().dispose();

      expect(store1.isDisposed, isTrue);
      expect(store2.isDisposed, isTrue);
    });

    test("delete one store", () async {
      StoreLocator().putFactory(Store1, createStore1);
      StoreLocator().putFactory(Store2, createStore2);

      final store1 = StoreLocator().get(Store1);
      final store2 = StoreLocator().get(Store2);

      expect(store1.isDisposed, isFalse);
      expect(store2.isDisposed, isFalse);

      await StoreLocator().delete(Store1);

      expect(store1.isDisposed, isTrue);
      expect(store2.isDisposed, isFalse);

      // Second one is a noop, but should not throw
      expect(() => StoreLocator().delete(Store1), returnsNormally);
    });

    test("emits changed keys", () async {
      final keys = <StoreKey>[];

      subscription = StoreLocator().changes.listen(keys.add);

      StoreLocator().putFactory(Store1, createStore1);
      StoreLocator().putFactory(Store2, createStore2);

      expect(keys, isEmpty);
      expect(keys, isEmpty);

      final store1 = StoreLocator().get<Store1, int>(Store1);
      expect(keys, []);

      final store2 = StoreLocator().get<Store2, int>(Store2);
      expect(keys, []);

      store1.increment();
      await microtask();

      expect(keys, [Store1]);

      store1.increment();
      await microtask();

      expect(keys, [Store1, Store1]);

      store2.increment();
      await microtask();

      expect(keys, [Store1, Store1, Store2]);

      store1.reset();
      await microtask();

      expect(keys, [Store1, Store1, Store2, Store1]);

      store2.reset();
      await microtask();

      expect(keys, [Store1, Store1, Store2, Store1, Store2]);
    });
  });
}
