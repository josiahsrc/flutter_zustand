import 'package:flutter/material.dart';
import 'package:flutter_zustand/flutter_zustand.dart';

void main() {
  runApp(const ZustandScope(child: MyApp()));
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
  int counter = 0;

  void incrementA() {
    set(() {
      counter++;
    });
  }
}

MyStore useMyStore() => create(() => MyStore());

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = useMyStore().select(context, (store) => store.counter);

    useMyStore().listen(
      context,
      (state) {
        if (state.counter == 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('a changed to ${state.counter}')),
          );
        }
      },
      dependencies: (state) => [state.counter],
    );

    return Scaffold(
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          useMyStore().incrementA();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
