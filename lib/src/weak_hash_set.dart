// https://github.com/henrichen/weak
// weak_hash_set.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2022-2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
import 'dart:collection';

import 'weak_hash_map.dart';

/// An unordered hash-table based [Set] implementation with weak referenced
/// elements. An element in this weak hash set will be automatically removed
/// when it is garbage collected. That is, when there is no other way for the
/// program to access the weak referenced element, it is likely removed from
/// this [WeakHashSet] anytime.
///
/// Note that the element object of type [E] must be a type that can be
/// applied into [WeakReference] target. i.e. [E] must NOT be numbers, strings,
/// booleans, records, null, dart:ffi pointers, dart:ffi structs, or
/// dart:ffi unions.
///
/// Besides the weak referenced elements, the attributes of this [WeakHashSet]
/// is the same to regular [HashSet].
class WeakHashSet<E extends Object> with SetMixin<E> {
  final WeakHashMap<E, dynamic> _weakHashMap;

  /// Create a hash set using the provided equals as equality.
  ///
  /// The provided [equals] must define a stable equivalence relation, and
  /// [hashCode] must be consistent with [equals].
  ///
  /// If [equals] or [hashCode] are omitted, the set uses the elements'
  /// intrinsic [Object.==] and [Object.hashCode].
  ///
  /// If you supply one of [equals] and [hashCode], you should generally also
  /// supply the other.
  ///
  /// Some [equals] or [hashCode] functions might not work for all objects. If
  /// [isValidKey] is supplied, it's used to check a potential element which is
  /// not necessarily an instance of [E], like the argument to contains which is
  /// typed as Object?. If [isValidKey] returns false, for an object, the
  /// [equals] and [hashCode] functions are not called, and no key equal to
  /// that object is assumed to be in the map. The [isValidKey] function
  /// defaults to just testing if the object is an instance of [E]
  WeakHashSet(
      {bool Function(E, E)? equals,
      int Function(E)? hashCode,
      bool Function(dynamic)? isValidKey})
      : _weakHashMap = WeakHashMap<E, dynamic>(
            equals: equals, hashCode: hashCode, isValidKey: isValidKey);

  /// Creates an unordered identity-based set.
  factory WeakHashSet.identity() =>
      WeakHashSet(equals: identical, hashCode: identityHashCode);

  /// Create a hash set containing all [elements].
  ///
  /// Creates a hash set as by WeakHashSet<E>() and adds all given [elements]
  /// to the set. The [elements] are added in order. If [elements] contains
  /// two entries that are equal, but not identical, then the first one is the
  /// one in the resulting set.
  ///
  /// All the [elements] should be instances of [E]. The elements iterable
  /// itself may have any element type, so this constructor can be used to
  /// down-cast a Set.
  WeakHashSet.from(Iterable<dynamic> elements)
      : _weakHashMap = WeakHashMap<E, dynamic>.fromIterable(elements,
            key: (e) => e, value: (e) => null);

  /// Create a hash set containing all [elements].
  ///
  /// Creates a hash set as by WeakHashSet<E>() and adds all given [elements]
  /// to the set. The [elements] are added in order. If [elements] contains
  /// two entries that are equal, but not identical, then the first one is the
  /// one in the resulting set.
  WeakHashSet.of(Iterable<E> elements)
      : _weakHashMap = WeakHashMap<E, dynamic>.fromIterable(elements,
            key: (e) => e, value: (e) => null);

  @override
  bool add(E value) {
    if (!_weakHashMap.containsKey(value)) {
      _weakHashMap[value] = null;
      return true;
    }
    return false;
  }

  @override
  bool contains(Object? element) => _weakHashMap.containsKey(element);

  @override
  Iterator<E> get iterator => _weakHashMap.keys.iterator;

  @override
  int get length => _weakHashMap.length;

  @override
  E? lookup(Object? element) => getTargetKey(_weakHashMap, element);

  @override
  bool remove(Object? value) => _weakHashMap.remove(value) != null;

  @override
  Set<E> toSet() => _weakHashMap.keys.toSet();

  @override
  bool get isEmpty => _weakHashMap.isEmpty;

  @override
  bool get isNotEmpty => _weakHashMap.isNotEmpty;

  @override
  void clear() => _weakHashMap.clear();
}
