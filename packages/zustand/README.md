<p align="center">
  <img src="https://raw.githubusercontent.com/josiahsrc/flutter_zustand/main/assets/bear_dart.jpg" />
</p>

> This package aims to bring the joy of [zustand](https://github.com/pmndrs/zustand?tab=readme-ov-file) to dart. A huge shoutout to @dai-shi, the original author of zustand.

A small, fast and scalable bearbones state-management solution using simplified flux principles. Has a comfy API. Isn't boilerplatey or opinionated.

Don't disregard it because it's cute. It has quite the claws. Lot's of time was spent making the API flexible while keeping it simple and easy to use.

:warning: This package is in its early stages and the API may change.

- [Pub package](https://pub.dev/packages/zustand)
- [Source code](https://github.com/josiahsrc/flutter_zustand/blob/main/packages/zustand)

## Usage

A simple app demonstrating the usage of zustand.

```dart
// 1. Create the store
class BearStore extends Store<int> {
  BearStore() : super(0);

  void increasePopulation() => set(state + 1);
  void removeAllBears() => set(0);
}

// 2. Create the store hook
BearStore useBearStore() => create(() => BearStore());

Future<void> main() async {
  // 3. Use the store
  useBearStore().stream.listen((state) {
    print('Bears: $state');
  });

  useBearStore().increasePopulation();
  useBearStore().increasePopulation();
  useBearStore().removeAllBears();

  // 4. Remember to dispose of the store when you're done
  await StoreLocator().dispose();
}
```

---

# Recipes

## Manually registering a store

You can manually place a store instance in the store locator. Bear in mind that the locator will dispose of the store when the app is closed.

```dart
StoreLocator().put(BearStore, BearStore());
```

## Manually driving a store

You can create a store and dispose of it yourself if you want.

```dart
final store = BearStore();
store.increasePopulation();
await store.dispose();
```

## Destroying a store

You can destroy a store manually. If the store is registered as a factory, it will be recreated the next time it's accessed.

```dart
final store1 = useBearStore()
await StoreLocator().destroy(BearStore);

// A new instance of the store will be created
final store2 = useBearStore();
```

## Listening for changes to all stores

Use the locator's `changes` stream to observe changes to stores by their keys.

```dart
final subscription = StoreLocator().changes.listen((key) {
  print('Store changed: $key');
});

useBearStore().increasePopulation();
useBearStore().increasePopulation();

await subscription.cancel();
```

## Getting a store by key

You can look up a store by its key using the locator.

```dart
final store = StoreLocator().get<BearStore, int>(key);
store.increasePopulation();
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
void setUp() {
  _sub = useBearStore().stream.listen((state) {
    print("Bears: $state");
  });
}

void tearDown() {
  // don't forget to cancel
  _sub?.cancel(); 
}
```

# Motivation

If you'd like to learn more about why this library exists, check out the [motivation document](https://github.com/josiahsrc/flutter_zustand/blob/main/docs/motivation.md).

# Contributing

If you like the package and want to contribute, feel free to [open and issue or create a PR](https://github.com/josiahsrc/flutter_zustand/tree/main). I'm always open to suggestions and improvements.

---

keywords: flutter, state management, zustand, bear, cute, simple, fast, scalable, flux, store, action, state, provider, riverpod, bloc
