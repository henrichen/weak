// https://github.com/henrichen/weak
// utils.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2022-2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
import 'dart:math' show min, max;

const maxInt = 9007199254740992; // 2^53
const minInt = -9007199254740992; // -2^53

typedef ComparatorKV<K extends Object, V extends Object> = int Function(
    K key, V value);

/// Binary search a [sorted] WeakReference target list with a [key] and
/// specified comparator.
int binarySearchWeakReferences<K extends Object, V extends Object>(
    List<WeakReference<V>> sorted,
    K key,
    ComparatorKV<K, V> comparator,
    Set<int> toRemove,
    {int? minIndex,
    int? maxIndex}) {
  var low = minIndex == null ? 0 : max(0, minIndex);
  var hgh =
      maxIndex == null ? sorted.length - 1 : min(sorted.length - 1, maxIndex);
  while (low <= hgh) {
    final mid = (low + hgh) ~/ 2;
    final val = sorted[mid].target;
    if (val == null) {
      toRemove.add(mid);
      if (mid == low) {
        low = mid + 1;
      } else {
        hgh = mid - 1;
      }
      continue;
    }
    final cmp = comparator(key, val);
    if (cmp == 0) {
      return mid;
    } else if (cmp < 0) {
      hgh = mid - 1;
    } else {
      low = mid + 1;
    }
  }
  return -(low + 1);
}

/// Errors thrown by [Iterable].
abstract class IterableElementError {
  /// Error if no element.
  static StateError noElement() => StateError("No element");

  /// Error if too many element.
  static StateError tooMany() => StateError("Too many elements");

  /// Error if too few element.
  static StateError tooFew() => StateError("Too few elements");
}
