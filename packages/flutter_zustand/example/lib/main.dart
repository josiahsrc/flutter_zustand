import 'package:example/counter.dart';
import 'package:example/todo_list.dart';
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

class DemoTile extends StatelessWidget {
  const DemoTile({
    super.key,
    required this.title,
    required this.builder,
  });

  final Widget title;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: builder,
        ));
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Zustand Examples"),
      ),
      body: ListView(
        children: [
          DemoTile(
            title: const Text("Counter"),
            builder: (context) => const CounterPage(),
          ),
          DemoTile(
            title: const Text("Todo List"),
            builder: (context) => const TodoListPage(),
          ),
        ],
      ),
    );
  }
}
