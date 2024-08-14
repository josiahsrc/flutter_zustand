# Atoms

Existing atom implementations are boiler platey.

Desired api might be something like

```dart
final countAtom = atom(0);

Widget build(BuildContext context) {
  final count = countAtom.watch(context);

  return TextButton(
    onPressed: () => count.value += 1,
    child: Text("Count: $count"),
  );
}
```
