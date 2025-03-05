import 'package:flutter/material.dart';
import 'package:flutter_atomic/flutter_atomic.dart';

final numAtom1 = atom(0);
final numAtom2 = atom(0);
final equalsAtom = atomCombiner(
  () {
    return numAtom1.value + numAtom2.value;
  },
  [numAtom1, numAtom2],
);

// final loadFishies = asyncAtom(
//   () async {},
//   [numAtom1],
// );

class DerivedPage extends StatelessWidget {
  const DerivedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final num1 = numAtom1.watch(context);
    final num2 = numAtom2.watch(context);
    final equals = equalsAtom.watch(context);

    final page = Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Zustand Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$num1 + $num2 = $equals',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: Wrap(
        spacing: 8,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              numAtom1.value++;
            },
            child: const Icon(Icons.chevron_left),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              numAtom2.value++;
            },
            child: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );

    return page;
  }
}
