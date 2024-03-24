import 'package:zustand/zustand.dart';

abstract class BaseStore extends Store<int> {
  BaseStore() : super(0);

  void increment() => set(state + 1);
  void reset() => set(0);
}

class Store1 extends BaseStore {}

class Store2 extends BaseStore {}

Store1 useStore1() => create(() => Store1());
Store2 useStore2() => create(() => Store2());

Future<void> microtask() async {
  await Future.delayed(Duration.zero);
}
