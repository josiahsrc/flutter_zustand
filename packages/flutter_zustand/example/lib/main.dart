import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';

void main() {
  runApp(const StoreScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyStore extends Store {
  bool loading = false;
  int counter = 0;
  int lastCounter = 0;
  int thisVariableIsNotObserved = 0;

  bool get counterChanged => lastCounter != counter;

  void incrementA() {
    set(() {
      lastCounter = counter;
      counter++;
    });
  }

  void changeNonObservedVariable() {
    set(() {
      thisVariableIsNotObserved++;
    });
  }

  Future<void> longInit() async {
    set(() {
      loading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    set(() {
      loading = false;
    });
  }

  Future<void> longDispose() async {
    set(() {
      loading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    set(() {
      loading = false;
    });
  }
}

MyStore useMyStore() => create(() => MyStore());

int rebuilds = 0;

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    rebuilds++;

    final counter = useMyStore().select(context, (store) => store.counter);
    final isLoading = useMyStore().select(context, (store) => store.loading);

    final page = Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Zustand Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text("UI has rebuilt this many time: $rebuilds"),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              useMyStore().changeNonObservedVariable();
            },
            child: const Icon(Icons.question_answer),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              useMyStore().incrementA();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );

    // Maybe there's a better api here?
    return StoreListener<MyStore>(
      child: page,
      onInit: (context, store) {
        store.longInit();
      },
      onChange: (context, store) {
        if (store.counterChanged && store.counter % 5 == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have reached ${store.counter}'),
            ),
          );
        }
      },
      onDispose: (context, store) {
        store.longDispose();
      },
    );
  }
}
