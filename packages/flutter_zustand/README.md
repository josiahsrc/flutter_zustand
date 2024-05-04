<p align="center">
  <img src="https://raw.githubusercontent.com/josiahsrc/flutter_zustand/main/assets/bear_flutter.jpg" />
</p>

> This package aims to bring the joy of [zustand](https://github.com/pmndrs/zustand?tab=readme-ov-file) to flutter. A huge shoutout to @dai-shi, the original author of zustand.

A small, fast and scalable bearbones state-management solution using simplified flux principles. Has a comfy API. Isn't boilerplatey or opinionated.

Don't disregard it because it's cute. It has quite the claws. Lot's of time was spent making the API flexible while keeping it simple and easy to use.

:warning: This package is in its early stages and the API may change.

- [Pub package](https://pub.dev/packages/flutter_zustand)
- [Source code](https://github.com/josiahsrc/flutter_zustand/blob/main/packages/flutter_zustand)

## First, wrap your app in a scope

Zustand uses scope to notify widgets to rebuild.

```dart
void main() {
  runApp(const StoreScope(child: MyApp()));
}
```

## Next, create a store

Your store receives actions and emits state. State has to be updated immutably.

```dart
class BearStore extends Store<int> {
  BearStore() : super(0);

  void increasePopulation() => set(state + 1);
  void removeAllBears() => set(0);
}

BearStore useBearStore() => create(() => BearStore());
```

## Then bind your widgets, and that's it!

Use the store anywhere. Call it or select from it to rebuild when it changes.

```dart
Widget build(BuildContext context) {
  final bears = useBearStore().select(context, (state) => state);
  return ElevatedButton(
    onPressed: useBearStore().increasePopulation,
    child: Text('Bears: $bears'),
  );
}
```

### Why zustand over BloC?

- Simple and un-opinionated
- Less boilerplate
- Access stores without context
- Wrap your app once

### Why zustand over riverpod?

- Doesn't require code generation
- Simple
- Less boilerplate

### Why zustand over provider?

- Less boilerplate
- Centralized, action-based state management
- Context-free usage

---

# Recipes

## Fetching everything

You can, but bear in mind that it will cause the component to update on every state change!

```dart
final bears = useBearStore().select(context, (state) => state);
```

## Selecting multiple state slices

It detects changes with equality (old == new). This is efficient for atomic state picks.

```dart
Widget build(BuildContext context) {
  final nuts = useBearStore().select(context, (state) => state.nuts);
  final honey = useBearStore().select(context, (state) => state.honey);
}
```

## Reacting to state changes

You can add listeners to any store using the `StoreListener` widget.

```dart
Widget build(BuildContext context) {
  return StoreListener(
    [
      useBearStore().listen(
        (context, state) {
          print("There are $state bears");
        },
        condition: (prev, next) => prev != next && next == 5,
      ),
    ],
    child: Container(...),
  );
}
```

## Async actions

Just call set when you're ready, zustand doesn't care if your actions are async or not.

```dart
class BearStore extends Store<int> {
  BearStore() : super(0);

  Future<void> loadFishies() async {
    final fishies = await fetch(pond);
    set(fishies.length);
  }
}
```

## Read from state in actions

Each store exposes a `state` property that you can access directly in your actions.

```dart
class BearStore extends Store<int> {
  BearStore() : super(0);

  void increasePopulation() {
    set(state + 1);
  }
}
```

## Subscribe to store changes manually

If you want to watch state changes from outside of the `build` method, you can listen to changes to state directly.

```dart
void initState() {
  _sub = useBearStore().stream.listen((state) {
    print("Bears: $state");
  });
}

void dispose() {
  // don't forget to cancel
  _sub?.cancel(); 
}
```

## Clean up resources

You can dispose of stores automatically using the `StoreDisposer` widget.

```dart
Widget build(BuildContext context) {
  return StoreDisposer(
    [
      useBearStore(),
    ],
    child: Container(...),
  );
}
```

# Motivation

If you'd like to learn more about why this library exists, check out the [motivation document](https://github.com/josiahsrc/flutter_zustand/blob/main/docs/motivation.md).

# Contributing

If you like the package and want to contribute, feel free to [open and issue or create a PR](https://github.com/josiahsrc/flutter_zustand/tree/main). I'm always open to suggestions and improvements.

---

keywords: flutter, state management, zustand, bear, cute, simple, fast, scalable, flux, store, action, state, provider, riverpod, bloc
