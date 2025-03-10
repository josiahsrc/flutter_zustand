import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

/// Encodes a store key into a dependable aspect.
///
/// Converts the given [key] into a string representation which is used as an
/// aspect identifier for dependency tracking.
String encodeDependency(dynamic key) {
  return key.toString();
}

/// Holds scope-related information for store dependency tracking.
///
/// This class tracks a set of changes and a counter that represents how many
/// changes have been recorded. It is used to determine if specific aspects
/// of a store have changed.
class ScopeData {
  /// A set of changes recorded in this scope.
  final Set<dynamic> changes;

  /// A counter indicating the number of changes.
  final int count;

  /// Creates a new [ScopeData] instance.
  ///
  /// The [changes] parameter is a set of changes that have occurred, and
  /// [count] represents the number of changes. By default, [changes] is an
  /// empty set and [count] is zero.
  const ScopeData({
    this.changes = const {},
    this.count = 0,
  });

  /// Returns a new [ScopeData] instance with an added [change].
  ///
  /// This method creates a copy of the current [ScopeData] with the given
  /// [change] added to the [changes] set and increments the [count] by one.
  ScopeData withNewChange(dynamic change) {
    return ScopeData(
      changes: changes.toSet()..add(change),
      count: count + 1,
    );
  }

  @override
  int get hashCode => changes.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScopeData) return false;
    return const DeepCollectionEquality().equals(other.changes, changes) &&
        other.count == count;
  }
}

/// An [InheritedModel] that provides [ScopeData] to its descendants.
///
/// [InheritedStoreScope] is used to propagate store change information
/// down the widget tree and trigger rebuilds for widgets that depend on
/// specific aspects of store changes.
class InheritedStoreScope extends InheritedModel<String> {
  /// The scope data containing the set of changes and update counter.
  final ScopeData data;

  /// Whether notifications should be sent to dependents.
  ///
  /// If `false`, dependents will not be notified even if [data] has changed.
  final bool notify;

  /// Creates an [InheritedStoreScope] widget.
  ///
  /// The [data] parameter provides the [ScopeData] to be propagated, and
  /// [notify] indicates whether dependents should be notified when [data]
  /// changes. The [child] widget is the subtree that will have access to
  /// the provided data.
  const InheritedStoreScope({
    super.key,
    required this.data,
    required this.notify,
    required super.child,
  });

  @override
  bool updateShouldNotify(InheritedStoreScope oldWidget) =>
      data != oldWidget.data && notify;

  @override
  bool updateShouldNotifyDependent(
    InheritedStoreScope oldWidget,
    Set<String> dependencies,
  ) {
    // Check each change in the current [data] and notify if its encoded
    // representation is included in the [dependencies].
    for (final change in data.changes) {
      if (dependencies.contains(encodeDependency(change))) {
        return true;
      }
    }

    return false;
  }

  /// Retrieves the nearest [InheritedStoreScope] for the given [aspect].
  ///
  /// This method is used to obtain the [InheritedStoreScope] from the
  /// widget tree that provides the dependency for a specific aspect. Returns
  /// `null` if no matching [InheritedStoreScope] is found.
  static InheritedStoreScope? of(BuildContext context, String aspect) {
    return InheritedModel.inheritFrom<InheritedStoreScope>(
      context,
      aspect: aspect,
    );
  }
}
