import 'dart:async';

import 'package:zustand/zustand.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late bool store1Created;
  late bool store2Created;
  StreamSubscription? subscription;

  setUp(() {
    store1Created = false;
    store2Created = false;
  });

  tearDown(() async {
    await StoreLocator().dispose();
    await subscription?.cancel();
  });

  Store1 createStore1() {
    store1Created = true;
    return Store1();
  }

  Store2 createStore2() {
    store2Created = true;
    return Store2();
  }

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

    await StoreLocator().deleteAll();
    expect(StoreLocator().contains(Store1), isFalse);
    expect(StoreLocator().contains(Store2), isFalse);
    expect(StoreLocator().isCreated(Store1), isFalse);
    expect(StoreLocator().isCreated(Store2), isFalse);
  });

  test('dispose disposes all stores', () async {
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

  test("deleteAll disposes all stores", () async {
    StoreLocator().putFactory(Store1, createStore1);
    StoreLocator().putFactory(Store2, createStore2);

    final store1 = StoreLocator().get(Store1);
    final store2 = StoreLocator().get(Store2);

    expect(store1.isDisposed, isFalse);
    expect(store2.isDisposed, isFalse);

    await StoreLocator().deleteAll();

    expect(store1.isDisposed, isTrue);
    expect(store2.isDisposed, isTrue);
  });

  test("delete disposes the store", () async {
    StoreLocator().putFactory(Store1, createStore1);
    StoreLocator().putFactory(Store2, createStore2);

    final store1 = StoreLocator().get(Store1);
    final store2 = StoreLocator().get(Store2);

    expect(store1.isDisposed, isFalse);
    expect(store2.isDisposed, isFalse);

    await StoreLocator().delete(Store1);

    expect(store1.isDisposed, isTrue);
    expect(store2.isDisposed, isFalse);
  });

  test("delete can be called without an instance", () async {
    expect(() => StoreLocator().delete(Store1), returnsNormally);
    expect(() => StoreLocator().delete(Store2), returnsNormally);
    expect(() => StoreLocator().delete(0), returnsNormally);
    expect(() => StoreLocator().delete(0), returnsNormally);
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

  test("emits changed even after deleting the stores", () async {
    final keys = <StoreKey>[];

    subscription = StoreLocator().changes.listen(keys.add);

    useStore1().increment();
    await microtask();
    expect(keys, [Store1]);

    await StoreLocator().delete(Store1);
    await microtask();
    expect(keys, [Store1]);

    useStore1().increment();
    await microtask();
    expect(keys, [Store1, Store1]);

    useStore1().reset();
    await microtask();
    expect(keys, [Store1, Store1, Store1]);

    await StoreLocator().deleteAll();
    await microtask();
    expect(keys, [Store1, Store1, Store1]);

    useStore1().increment();
    await microtask();
    expect(keys, [Store1, Store1, Store1, Store1]);
  });

  test("dispose closes the changes stream", () async {
    final keys = <StoreKey>[];

    subscription = StoreLocator().changes.listen(keys.add);

    useStore1().increment();
    await microtask();
    expect(keys, [Store1]);

    await StoreLocator().dispose();
    await microtask();

    useStore1().increment();
    await microtask();
    expect(keys, [Store1]);

    useStore1().reset();
    await microtask();
    expect(keys, [Store1]);
  });
}
