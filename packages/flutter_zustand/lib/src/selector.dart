import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zustand/zustand.dart';

extension StoreSelectorX<V> on Store<V> {
  T select<T>(
    BuildContext context,
    T Function(V state) selector,
  ) {
    return context.select<StoreLocator, T>(
      (_) => selector(state),
    );
  }
}
