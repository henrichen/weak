// https://github.com/henrichen/weak
// weak_hash_map.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2022-2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
import 'dart:math' show pow;
import 'dart:collection' show MapMixin, IterableMixin;

import 'utils.dart' show maxInt;
import 'weak_reference_queue.dart' show WeakReferenceQueue;

/// An unordered hash-table based [Map] implementation with weak referenced
/// keys. An entry in this weak hash map will be automatically removed when its
/// key is garbage collected. That is, when there is no other way for the
/// program to access the weak referenced key, its associated entry in this
/// [WeakHashMap] is likely removed anytime.
///
/// Note that the key object of type [K] must be a type that can be applied
/// into [WeakReference] target. i.e. [K] must NOT be numbers, strings,
/// booleans, records, null, dart:ffi pointers, dart:ffi structs, or
/// dart:ffi unions.
///
/// Besides the weak referenced keys, the attributes of this [WeakHashMap]
/// is the same to regular [HashMap].
class WeakHashMap<K extends Object, V> with MapMixin<K, V> {
  /// The default initial capacity -- MUST be a power of two.
  static const _defaultCapacity = 16;

  /// The maximum capacity, used if a higher value is implicitly specified
  /// by either of the constructors with arguments.
  /// MUST be a power of two <= 1^30.
  static const _maxCapacity = 1 << 30;

  /// The load factor used when none specified in constructor.
  static const _defaultLoadFactor = 0.75;
  
  /// The entry table, resized as necessary; length MUST be a power of two.
  List<_Entry<K,V>?> _table = <_Entry<K,V>?>[];

  /// The next threshold size to resize (capacity * load factor).
  int _threshold = 0;

  /// The load factor for the _hash table.
  late final double _loadFactor;

  /// Key equal function
  late final bool Function(K a, K b) _keyEquals;

  /// Key hash code function
  late final int Function(K k) _keyHash;

  /// Key validation function
  late final bool Function(dynamic k) _keyValid;

  /// The count of entries contained in this WeakHashMap.
  int _length = 0;

  /// Count that WeakHashMap has been modified by structure.
  int _modCount = 0;

  /// Management of GCed Keys and their associated entries.
  late final WeakReferenceQueue<K, _Entry<K, V>> _queue;

  /// Create an unordered hash-table based [Map] with weak referenced keys.
  ///
  /// if [equals] is provided, it will be used to compare the key in this map;
  /// otherwise, [Object.==] is used instead.
  ///
  /// if [hashCode] is provided, it will be used to calculate the hashCode of
  /// the key in this map; otherwise, [Object.hashCode] is used instead.
  ///
  /// The used [equals] and [hashCode] method should always be consistent
  /// because they are used to locate the key in the hash-table.
  ///
  /// If [isValidKey] is provided, it is used to check potentially non-[K] type
  /// keys. If [isValidKey] return false, the [equals] and [hashCode] will NOT
  /// be called and no key in the map is assumed existed. The default
  /// [isValidKey] checks whether the key is [K] type.
  ///
  /// Note the internal hash table with the optional [initCapacity](default
  /// to 16) and optional [loadFactor](default to 0.75). Adjusting these two
  /// arguments to fine tune memory usage and initialization performance.
  WeakHashMap({
    bool Function(K, K)? equals,
    int Function(K)? hashCode,
    bool Function(dynamic)? isValidKey,
    int initCapacity = _defaultCapacity,
    double loadFactor = _defaultLoadFactor}) {

    _queue = WeakReferenceQueue(
        'WeakHashMap-${identityHashCode(this).toRadixString(16)}');
    _keyEquals = equals ?? _defaultKeyEquals;
    _keyHash = hashCode ?? _defaultKeyHash;
    _keyValid = isValidKey ?? _defaultKeyValid;

    final capacity = initCapacity == _defaultCapacity
        ? _defaultCapacity
        : initCapacity > _maxCapacity
        ? _maxCapacity
        : initCapacity <= 0
        ? _defaultCapacity
        : pow(2, (initCapacity - 1).bitLength).toInt();

    if (loadFactor <= 0 || loadFactor > 1) {
      loadFactor = _defaultLoadFactor;
    }

    _loadFactor = loadFactor;
    _threshold = (capacity * loadFactor).ceil();
    _table = _newTable(capacity);
  }

  /// Create a [WeakHashMap] containing the provided [entries]. If multiple
  /// [entries] have the same key and value, the 1st entry is preserved.
  /// If multiple [entries] have the same key, the 1st key is preserved
  /// and value overwritten.
  factory WeakHashMap.fromEntries(Iterable<MapEntry<K,V>> entries) =>
      WeakHashMap<K,V>()..addEntries(entries);

  /// Creates a [WeakHashMap] where the [key]s and [value]s are computed from
  /// the [iterable] elements.
  factory WeakHashMap.fromIterable(Iterable iterable, {
    K Function(dynamic element)? key, V Function(dynamic element)? value}) {
    final key0 = key ?? _identityFunc<K>;
    final val0 = value ?? _identityFunc<V>;
    final map = WeakHashMap<K,V>();
    for (final e in iterable) {
      map[key0(e)] = val0(e);
    }
    return map;
  }

  /// Creates a [WeakHashMap] per the provided [keys] and [values] iterables.
  /// It is an error if [keys] and [values] do not have the same length.
  factory WeakHashMap.fromIterables(Iterable<K> keys, Iterable<V> values) {
    final map = WeakHashMap<K,V>();
    final itK = keys.iterator;
    final itV = values.iterator;
    while (itK.moveNext()) {
      if (!itV.moveNext()) throw ArgumentError('Iterables do not have same length.');
      final k = itK.current;
      final v = itV.current;
      map[k] = v;
    }
    if (itV.moveNext()) throw ArgumentError('Iterables do not have same length.');
    return map;
  }

  /// Create a [WeakHashMap] per the provided [other] map. The [other]'s keys
  /// must be [K] type while values must be [V] type. However, the [other] map
  /// itself can have any type.
  factory WeakHashMap.from(Map other) {
    final map = WeakHashMap<K, V>();
    other.forEach((dynamic k, dynamic v) {
      map[k as K] = v as V;
    });
    return map;
  }

  /// Create a [WeakHashMap] per the provided [other] map of the same [K] type
  /// keys and [V] type values.
  factory WeakHashMap.of(Map<K,V> other) => WeakHashMap()..addAll(other);

  /// Create an unordered identity-based map. Keys in this map are considered
  /// equal only if they are the same object.
  factory WeakHashMap.identity() =>
      WeakHashMap(equals: identical, hashCode: identityHashCode);

  @override
  int get length {
    if (_length == 0) return 0;
    _purgeGcEntries();
    return _length;
  }

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  V? operator [](Object? key) => isEmpty ? null : _getEntry(key)?.value;

  @override
  bool containsKey(Object? key) => _getEntry(key) != null;

  @override
  void operator []=(K key, V value) {
    final keyHashCode = _keyHash(key);
    final h = _hash(keyHashCode);
    final tb = _getTable();
    var j = _indexFor(h, tb.length);

    for (var curr = tb[j]; curr != null; curr = curr.next) {
      if (h == curr._hash && _entryKeyEquals(key, curr._keyTarget)) {
        final oldValue = curr.value;
        if (value != oldValue) {
          curr.value = value;
        }
        return;
      }
    }

    _modCount++;
    final entry = tb[j];
    final newEntry = _Entry(key, value, h, entry);
    _queue.attach(newEntry._keyWeakRef, newEntry); // manage WeakReferenced key
    tb[j] = newEntry;
    if (++_length >= _threshold) {
      _resize(tb.length * 2);
    }
  }

  @override
  void addAll(Map<K, V> other) => addEntries(other.entries);

  @override
  void addEntries(Iterable<MapEntry<K,V>> newEntries) {
    final numKeysToBeAdded = newEntries.length;
    if (numKeysToBeAdded == 0) return;

    // expand the table if the number to be added is greater than or equal
    // to threshold.
    if (numKeysToBeAdded > _threshold) {
      var targetCapacity = (numKeysToBeAdded / _loadFactor + 1).toInt();
      if (targetCapacity > _maxCapacity) {
        targetCapacity = _maxCapacity;
      }
      if (_table.length < targetCapacity) {
        final newCapacity = pow(2, (targetCapacity - 1).bitLength).toInt();
        _resize(newCapacity);
      }
    }

    for (final entry in newEntries) {
      this[entry.key] = entry.value;
    }
  }

  @override
  V? remove(Object? key) {
    if (!_keyValid(key)) return null;
    final keyHashCode = _keyHash(key as K);
    final h = _hash(keyHashCode);
    final tb = _getTable();
    final j = _indexFor(h, tb.length);
    var prev = tb[j];
    var curr = prev;

    while (curr != null) {
      final next = curr.next;
      if (h == curr._hash && _entryKeyEquals(key, curr._keyTarget)) {
        _modCount++;
        _length--;
        if (prev == curr) {
          tb[j] = next;
        } else {
          prev!.next = next;
        }
        _queue.detach(curr._keyWeakRef);
        return curr.value;
      }
      prev = curr;
      curr = next;
    }

    return null;
  }

  @override
  void clear() {
    // clear GCed queue.
    _queue.clear();

    _modCount++;
    _table = <_Entry<K,V>?>[];
    _length = 0;
  }

  @override
  bool containsValue(Object? value) {
    final tb = _getTable();
    for (var j = tb.length; --j >= 0;) {
      for (var curr = tb[j]; curr != null; curr = curr.next) {
        if (value == curr.value) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Iterable<MapEntry<K, V>> get entries => _EntryIterable(this);

  @override
  Iterable<K> get keys => _KeyIterable(this);

  @override
  Iterable<V> get values => _ValueIterable(this);

  /// Returns the entry associated with the [key]; return null
  /// if no mapping for the [key].
  _Entry<K,V>? _getEntry(Object? key) {
    if (!_keyValid(key)) return null;
    final keyHashCode = _keyHash(key as K);
    final h = _hash(keyHashCode);
    final tb = _getTable();
    final index = _indexFor(h, tb.length);
    var curr = tb[index];
    while (curr != null && (curr._hash != h || !_entryKeyEquals(key, curr._keyTarget))) {
      curr = curr.next;
    }
    return curr;
  }

  /// Create a new hash table; [length] must be in power of two
  List<_Entry<K,V>?> _newTable(int length)
  => <_Entry<K,V>?>[]..length = length;

  /// Purge GCed entries
  void _purgeGcEntries() {
    for (var entry = _queue.poll(); entry != null; entry = _queue.poll()) {
      var j = _indexFor(entry._hash, _table.length);

      _Entry<K,V>? prev;
      var curr = _table[j];
      while (curr != null) {
        final next = curr.next;
        if (identical(curr, entry)) { // use identical
          // found GCed entry
          if (prev == null) {
            // first in slot
            _table[j] = next;
          } else {
            // link next to previous
            prev.next = next;
          }
          _length--;
          break;
        }
        prev = curr;
        curr = next;
      }
    }
  }

  /// Returns the table after purge GCed entries.
  List<_Entry<K,V>?> _getTable() {
    _purgeGcEntries();
    return _table;
  }

  /// Transfers all entries from src to dest tables
  void _transfer(List<_Entry<K,V>?> src, List<_Entry<K,V>?> dest) {
    for (var j = 0; j < src.length; ++j) {
      var curr = src[j];
      src[j] = null;
      while (curr != null) {
        final next = curr.next;
        final key = curr._keyTarget;
        if (key == null) {
          curr.next = null;
          _length--;
        } else {
          final k = _indexFor(curr._hash, dest.length);
          curr.next = dest[k];
          dest[k] = curr;
        }
        curr = next;
      }
    }
  }

  /// Re-hashes the contents of this map into a new hash table with a
  /// larger capacity. This method is called when the number of keys in
  /// this map reaches its threshold.
  ///
  /// If current capacity is MAXIMUM_CAPACITY, this method does not
  /// resize the map, but sets threshold to maximum integer.
  void _resize(int newCapacity) {
    final oldTb = _getTable();
    final oldCapacity = oldTb.length;
    if (oldCapacity == _maxCapacity) {
      _threshold = maxInt;
      return;
    }

    final newTb = _newTable(newCapacity);
    _transfer(oldTb, newTb);
    _table = newTb;

    // Restore old table if shrink to under threshold.
    if (_length >= _threshold ~/ 2) {
      _threshold = (newCapacity * _loadFactor).toInt();
    } else {
      _purgeGcEntries();
      _transfer(newTb, oldTb);
      _table = oldTb;
    }
  }

  bool _entryKeyEquals(K a, K? b) {
    if (b == null) return false;
    return _keyEquals(a, b);
  }
  bool _defaultKeyEquals(K a, K b) => a == b;
  int _defaultKeyHash(K k) => k.hashCode;
  bool _defaultKeyValid(dynamic k) => k is K;
}

/// Returns table slot index for hashCode [h] and table [capacity]
/// (must be power of 2).
int _indexFor(int h, int capacity) => h & (capacity-1);

/// Ensures hashCodes [h] that differ only by constant multiples at each bit
/// position have a bounded number of collisions (approximately 8 at default
/// load factor 0.75).
int _hash(int h) {
  h ^= (h >>> 20) ^ (h >>> 12);
  return h ^ (h >>> 7) ^ (h >>> 4);
}

/// WeakEntry of the WeakHashMap whose key is referenced by [WeakReference].
class _Entry<K extends Object, V> {
  final int _hash;
  final WeakReference<K> _keyWeakRef;
  V value;
  _Entry<K,V>? next;

  // Constructor
  _Entry(K key, this.value, this._hash, this.next)
      : _keyWeakRef = WeakReference(key);

  K get key => _keyWeakRef.target!;

  K? get _keyTarget => _keyWeakRef.target;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    if (other is _Entry<K, V>) {
      return _keyTarget == other._keyTarget
          && value == other.value;
    }

    if (other is MapEntry<K, V>) {
      return _keyTarget == other.key
          && value == other.value;
    }
    return false;
  }

  @override
  int get hashCode
  => (_keyTarget == null ? 0 : _keyTarget.hashCode) ^ value.hashCode;

  @override
  String toString()
  => '$_keyTarget: $value; $_hash';
}

/// Entries for WeakHashMap
class _EntryIterable<K extends Object, V> with IterableMixin<MapEntry<K,V>> {
  final WeakHashMap<K, V> _owner;

  _EntryIterable(this._owner);

  @override
  Iterator<MapEntry<K, V>> get iterator => _EntryIterator(_owner);
}

/// Keys for WeakHashMap
class _KeyIterable<K extends Object, V> with IterableMixin<K> {
  final WeakHashMap<K, V> _owner;

  _KeyIterable(this._owner);

  @override
  Iterator<K> get iterator => _KeyIterator(_owner);
}

/// Values for WeakHashMap
class _ValueIterable<K extends Object, V> with IterableMixin<V> {
  final WeakHashMap<K, V> _owner;

  _ValueIterable(this._owner);

  @override
  Iterator<V> get iterator => _ValueIterator(_owner);
}

/// Iterator for WeakHashMap
abstract class _WeakMapIterator<K extends Object, V> {
  int _index = -1;

  /// current entry
  _Entry<K,V>? _entry;

  /// current key
  K? _key;

  final WeakHashMap<K,V> _owner;
  final List<_Entry<K,V>?> _table;
  final int _expectedModCount;

  _WeakMapIterator(this._owner)
      : _table = _owner._getTable(),
        _expectedModCount = _owner._modCount {
    _index = _owner.isEmpty ? 0 : _table.length;
  }

  _Entry<K, V>? _nextEntryInSlot(_Entry<K,V> entry) {
    _Entry<K,V>? curr = entry;
    do {
      curr = curr!.next;
    } while (curr != null && curr._keyTarget == null);
    return curr;
  }

  bool _moveNextEntry() {
    while (true) {
      // find in a slot
      if (_entry != null) {
        _entry = _nextEntryInSlot(_entry!);
        _key = _entry?._keyTarget;
        if (_key == null) {
          continue;
        }
      }

      // find next slot in table
      var curr = _entry;
      var j = _index;
      while (curr == null && j > 0) {
        curr = _table[--j];
      }
      _entry = curr;
      _index = j;
      if (curr == null) {
        // no more slot in table
        _key = null;
        return false;
      }
      _key = curr._keyTarget;
      if (_key != null) break; // found the entry
    }
    if (_expectedModCount != _owner._modCount) {
      throw ConcurrentModificationError(_owner);
    }
    return true;
  }
}

class _EntryIterator<K extends Object, V> extends _WeakMapIterator<K, V> implements Iterator<MapEntry<K,V>> {
  _EntryIterator(super.owner);

  @override
  bool moveNext() => _moveNextEntry();

  @override
  MapEntry<K, V> get current => MapEntry(_entry!.key, _entry!.value);
}

class _KeyIterator<K extends Object, V> extends _WeakMapIterator<K, V> implements Iterator<K> {
  _KeyIterator(super.owner);

  @override
  bool moveNext() => _moveNextEntry();

  @override
  K get current => _key!;
}

class _ValueIterator<K extends Object, V> extends _WeakMapIterator<K, V> implements Iterator<V> {
  _ValueIterator(super.owner);

  @override
  bool moveNext() => _moveNextEntry();

  @override
  V get current => _entry!.value;
}

T _identityFunc<T>(T e) => e;

K? getTargetKey<K extends Object,V>(WeakHashMap<K, V> map, Object? key) =>
    map._getEntry(key)?.key;