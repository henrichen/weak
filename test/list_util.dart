// https://github.com/henrichen/weak
// utils.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
library;

import 'dart:math';
import 'package:test/test.dart';
import 'package:weak/weak.dart';
import 'data_util.dart';

void Function(X? elm) expectEach(List<X?> expected) {
  int j = 0;
  return (elm) => expect(elm, equals(expected[j++]));
}

void expectGetRange(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    for (int e = s; e <= len; ++e) {
      expect(list.getRange(s, e), orderedEquals(expected.getRange(s, e)),
          reason: '($s, $e)');
    }
  }
  expect(() => list.getRange(len + 1, len + 1), throwsRangeError);
}

void expectAny(WeakList<X> list, List<X?> expected) {
  expect(list.any((e) => e == null), equals(expected.any((e) => e == null)));
  final len = expected.length;
  for (int s = 0; s < len; ++s) {
    final x = expected[s];
    expect(list.any((e) => e == x), equals(expected.any((e) => e == x)));
  }
}

void expectAsMap(WeakList<X> list, List<X?> expected) {
  expect(list.asMap().keys, orderedEquals(expected.asMap().keys));
  expect(list.asMap().values, orderedEquals(expected.asMap().values));
}

void expectContains(WeakList<X> list, List<X?> expected) {
  expect(list.contains(null), equals(expected.contains(null)));
  final len = expected.length;
  for (int s = 0; s < len; ++s) {
    final x = expected[s];
    expect(list.any((e) => e == x), equals(expected.any((e) => e == x)));
  }
}

void expectElementAt(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  expect(() => list.elementAt(-1), throwsRangeError);
  expect(() => list.elementAt(len), throwsRangeError);
  for (int j = 0; j < len; ++j) {
    expect(list.elementAt(j), equals(expected.elementAt(j)), reason: '$j');
  }
}

void expectEvery(WeakList<X> list, List<X?> expected) {
  expect(
      list.every((e) => e == null), equals(expected.every((e) => e == null)));
  final len = expected.length;
  for (int s = 0; s < len; ++s) {
    final x = expected[s];
    expect(list.every((e) => e == x), equals(expected.every((e) => e == x)));
  }
  for (int s = 0; s < len; ++s) {
    expect(list.every((e) => e == null || e.value < len),
        equals(expected.every((e) => e == null || e.value < len)));
  }
}

void expectIndexOf(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    expect(list.indexOf(null, s), equals(expected.indexOf(null, s)));
  }
  if (len > 0) {
    final elm = expected[Random().nextInt(len)];
    for (int s = 0; s <= len; ++s) {
      expect(list.indexOf(elm, s), equals(expected.indexOf(elm, s)));
    }
  }
}

void expectLastIndexOf(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    expect(list.lastIndexOf(null, s), equals(expected.lastIndexOf(null, s)));
  }
  if (len > 0) {
    final elm = expected[Random().nextInt(len)];
    for (int s = 0; s <= len; ++s) {
      expect(list.lastIndexOf(elm, s), equals(expected.lastIndexOf(elm, s)),
          reason: 'start: $s, elm: $elm');
    }
  }
}

void expectIndexWhere(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    expect(list.indexWhere((elm) => elm == null, s),
        equals(expected.indexWhere((elm) => elm == null, s)));
  }
  if (len > 0) {
    final elm0 = expected[Random().nextInt(len)];
    for (int s = 0; s <= len; ++s) {
      expect(list.indexWhere((elm) => elm == elm0, s),
          equals(expected.indexWhere((elm) => elm == elm0, s)));
    }
  }
}

void expectLastIndexWhere(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    expect(list.lastIndexWhere((elm) => elm == null, s),
        equals(expected.lastIndexWhere((elm) => elm == null, s)));
  }
  if (len > 0) {
    final elm0 = expected[Random().nextInt(len)];
    for (int s = 0; s <= len; ++s) {
      expect(list.lastIndexWhere((elm) => elm == elm0, s),
          equals(expected.lastIndexWhere((elm) => elm == elm0, s)));
    }
  }
}

void expectWhere(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  expect(list.where((elm) => elm == null),
      equals(expected.where((elm) => elm == null)));
  for (int s = 0; s <= len; ++s) {
    expect(list.where((elm) => elm != null && elm.value < s),
        equals(expected.where((elm) => elm != null && elm.value < s)));
  }
}

void expectFirstWhere(WeakList<X> list, List<X?> expected, X? elseX) {
  final len = expected.length;
  expect(list.firstWhere((elm) => elm == null, orElse: () => elseX),
      equals(expected.firstWhere((elm) => elm == null, orElse: () => elseX)));
  for (int s = 0; s < len; ++s) {
    final x = expected[s];
    expect(list.firstWhere((elm) => elm == x, orElse: () => null),
        equals(expected.firstWhere((elm) => elm == x, orElse: () => null)));
  }
}

void expectLastWhere(WeakList<X> list, List<X?> expected, X? elseX) {
  final len = expected.length;
  expect(list.lastWhere((elm) => elm == null, orElse: () => elseX),
      equals(expected.lastWhere((elm) => elm == null, orElse: () => elseX)));
  for (int s = 0; s < len; ++s) {
    final x = expected[s];
    expect(list.lastWhere((elm) => elm == x, orElse: () => null),
        equals(expected.lastWhere((elm) => elm == x, orElse: () => null)));
  }
}

void expectSingleWhere(WeakList<X> list, List<X?> expected, X? elseX) {
  final len = expected.length;
  expect(
      list.singleWhere((elm) => elm == null, orElse: () => elseX),
      equals(
          expected.singleWhere((elm) => elm == null, orElse: () => elseX)));
  for (int s = 0; s < len; ++s) {
    final x = expected[s];
    expect(list.singleWhere((elm) => elm == x, orElse: () => null),
        equals(expected.singleWhere((elm) => elm == x, orElse: () => null)));
  }
}

void expectSkip(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    expect(list.skip(s), equals(expected.skip(s)));
  }
}

void expectSkipWhile(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    expect(list.skipWhile((elm) => elm == null),
        equals(expected.skipWhile((elm) => elm == null)));
  }
  if (len > 0) {
    for (int s = 0; s <= len; ++s) {
      expect(list.skipWhile((elm) => elm == null || elm.value < s),
          equals(expected.skipWhile((elm) => elm == null || elm.value < s)));
    }
  }
}

void expectTake(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    expect(list.take(s), equals(expected.take(s)));
  }
}

void expectTakeWhile(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    expect(list.takeWhile((elm) => elm == null),
        equals(expected.takeWhile((elm) => elm == null)));
  }
  if (len > 0) {
    for (int s = 0; s <= len; ++s) {
      expect(list.takeWhile((elm) => elm == null || elm.value < s),
          equals(expected.takeWhile((elm) => elm == null || elm.value < s)));
    }
  }
}

void expectNonNulls(WeakList<X> list, List<X?> expected) {
  expect(list.nonNulls, orderedEquals(expected.nonNulls));
}

void expectNonNullsReversed(WeakList<X> list, List<X?> expected) {
  expect(list.nonNullsReversed, orderedEquals(expected.nonNulls.toList().reversed));
}

void expectGetNonNullRange(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    for (int e = s; e <= len; ++e) {
      expect(list.getNonNullRange(s, e), orderedEquals(getNonNullRange(expected, s, e)),
          reason: '($s, $e)');
    }
  }
  expect(() => list.getNonNullRange(len + 1, len + 1), throwsRangeError);
}

void expectGetNonNullRangeReversed(WeakList<X> list, List<X?> expected) {
  final len = expected.length;
  for (int s = 0; s <= len; ++s) {
    for (int e = s; e <= len; ++e) {
      expect(list.getNonNullRangeReversed(s, e), orderedEquals(getNonNullRangeReversed(expected, s, e)),
          reason: '($s, $e)');
    }
  }
  expect(() => list.getNonNullRange(len + 1, len + 1), throwsRangeError);
}

Iterable<X> getNonNullRange(List<X?> expected, int start, int end) sync* {
  for (int j = start; j < end; ++j) {
    final elm = expected[j];
    if (elm != null) yield elm;
  }
}

Iterable<X> getNonNullRangeReversed(List<X?> expected, int start, int end) sync* {
  for (int j = end; --j >= start;) {
    final elm = expected[j];
    if (elm != null) yield elm;
  }
}
