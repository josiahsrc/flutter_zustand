import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:zustand/zustand.dart';

class StoreScope extends SingleChildStatelessWidget {
  const StoreScope({
    super.key,
    required Widget child,
  }) : super(child: child);

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return InheritedProvider<StoreLocator>.value(
      value: StoreLocator(),
      startListening: _startListening,
      lazy: false,
      child: child,
    );
  }

  static VoidCallback _startListening(
    InheritedContext<StoreLocator?> e,
    StoreLocator value,
  ) {
    final subscription = value.changes.listen(
      (dynamic _) => e.markNeedsNotifyDependents(),
    );
    return subscription.cancel;
  }
}
