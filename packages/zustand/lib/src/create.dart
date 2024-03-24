import 'locator.dart';
import 'store.dart';

S create<S extends Store<V>, V>(S Function() create) {
  StoreLocator().putFactory(S, create);
  return StoreLocator().get(S);
}
