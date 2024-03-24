import 'locator.dart';
import 'store.dart';

/// Registers a [Store] factory function with the [StoreLocator] and returns
/// the [Store] instance created by the factory. This is a convenience method
/// meant to mirror the API of the [original Zustand library](https://pub.dev/packages/zustand).
///
/// The recommended usage for this is:
///
/// ```
/// // Define the hook
/// BearStore useBearStore() => create(() => BearStore());
///
/// // Use the hook
/// useBearStore().increasePopulation();
/// ```
S create<S extends Store<V>, V>(S Function() create) {
  StoreLocator().putFactory(S, create);
  return StoreLocator().get(S);
}
