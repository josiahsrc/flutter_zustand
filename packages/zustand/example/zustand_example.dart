import 'package:zustand/zustand.dart';

class CounterStore extends Store<int> {
  CounterStore() : super(0);

  void increment() => set(state + 1);
  void reset() => set(0);
}

CounterStore useCounterStore() => create(() => CounterStore());

Future<void> main() async {
  final counter = useCounterStore();

  counter.stream.listen((state) {
    print('Counter: $state');
  });

  counter.increment();
  counter.increment();
  counter.reset();

  await StoreLocator().dispose();
}
