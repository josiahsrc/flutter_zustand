// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:zustand/zustand.dart';

import 'utility.dart';

class AtomStore<T> extends Store<T> {
  AtomStore(super.state);
}

class Atom<T> {
  Atom(String id) : _id = id;

  final String _id;

  @protected
  @visibleForTesting
  AtomStore<T> get store => StoreLocator().get(_id);

  Stream<T> get stream => store.stream;

  T get value => store.state;

  set value(T value) => store.set(value);
}

String registerAtomStore<T>(T value) {
  final id = generateRandomId();
  StoreLocator().putFactory(id, () => AtomStore<T>(value));
  return id;
}

Atom<T> atom<T>(T value) {
  return Atom(registerAtomStore(value));
}

typedef DerivedBuilder<T> = T Function();

class DerivedAtom<T> extends Atom<T> {
  DerivedAtom({
    required String id,
    required DerivedBuilder<T> builder,
    required List<Atom> dependencies,
  }) : super(id) {
    CombineLatestStream.list(
      dependencies.map((atom) async* {
        yield atom.value;
        yield* atom.stream;
      }).toList(),
    ).skip(1).listen((_) {
      value = builder();
    });
  }
}

DerivedAtom<T> derivedAtom<T>(
  DerivedBuilder<T> builder,
  List<Atom> dependencies,
) {
  return DerivedAtom<T>(
    id: registerAtomStore(builder()),
    builder: builder,
    dependencies: dependencies,
  );
}

extension AtomSelectorX<T> on Atom<T> {
  T watch(BuildContext context) {
    return select(context, (value) => value);
  }

  S select<S>(BuildContext context, S Function(T value) selector) {
    return context.select<StoreLocator, S>((_) => selector(value));
  }
}

final count = atom(0);
final count2 = atom(0);

final added = derivedAtom(
  () {
    return count.value + count2.value;
  },
  [count, count2],
);

void something() {
  count.value += 1;
}
