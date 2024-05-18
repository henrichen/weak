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

  WeakHashSet({
    bool Function(E, E)? equals,
    int Function(E)? hashCode,
    bool Function(dynamic)? isValidKey})
      : _weakHashMap = WeakHashMap<E, dynamic>(
          equals: equals,
          hashCode: hashCode,
          isValidKey: isValidKey);

  factory WeakHashSet.identity() =>
      WeakHashSet(equals: identical, hashCode: identityHashCode);

  WeakHashSet.from(Iterable<dynamic> elements)
      : _weakHashMap = WeakHashMap<E, dynamic>.fromIterable(
          elements, key: (e) => e, value: (e) => null);

  WeakHashSet.of(Iterable<E> elements)
      : _weakHashMap = WeakHashMap<E, dynamic>.fromIterable(
          elements, key: (e) => e, value: (e) => null);

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
