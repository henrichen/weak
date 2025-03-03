// https://github.com/henrichen/weak
// utils.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
library;

import 'dart:math';
import 'package:test/test.dart';
import 'package:weak/weak.dart';
import 'gc_util.dart';

/// IMPORTANT: set VM options
///
/// `--enable-vm-service`
///
/// so we can force GC.
void main() async {
  final vmService = await VmServiceUtil.create();

  void Function(X? elm) expectEach(List<X?> expected) {
    int j = 0;
    return (elm) => expect(elm, equals(expected[j++]));
  }

  void expectGetRange(WeakList<X> list, List<X?> expected) {
    final len = expected.length;
    for (int s = 0; s <= len; ++s) {
      for (int e = s; e <= len; ++e) {
        expect(list.getRange(s, e), equals(expected.getRange(s, e)),
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

  group("empty or one element list ", () {
    late WeakList<X> list;
    late List<X?> expected;
    late List<X?> strongList;
    setUp(() {
      list = WeakList();
      strongList = <X?>[];
    });

    test('empty list', () {
      list.validElementCount();
      expected = [];
      expect(list.length, equals(0));
      expect(list, isEmpty);
      expect(list.isNotEmpty, isFalse);
      expect(() => list.single, throwsStateError);
      expect(() => list.first, throwsStateError);
      expect(() => list.last, throwsStateError);
      expectAny(list, expected);
      expectAsMap(list, expected);
      expectContains(list, expected);
      expectElementAt(list, expected);
      expectEvery(list, expected);
      expect(list.expand((element) => [element]), orderedEquals(expected));

      expect(() => list.firstWhere((elm) => elm == null), throwsStateError);
      expect(() => list.firstWhere((elm) => elm == X(0)), throwsStateError);
      expectFirstWhere(list, expected, X(0));

      expect(list.fold(0, (int pre, X? elm) => pre + (elm?.value ?? 1)),
          equals(0));
      expect(list.followedBy(list), orderedEquals(list.followedBy(list)));
      list.forEach(expectEach(expected));

      expectGetRange(list, expected);
      expectIndexOf(list, expected);
      expectLastIndexOf(list, expected);
      expectIndexWhere(list, expected);
      expectLastIndexWhere(list, expected);

      expect(list.join(), equals(expected.join()));

      expect(() => list.lastWhere((elm) => elm == null), throwsStateError);
      expect(() => list.lastWhere((elm) => elm == X(0)), throwsStateError);
      expectLastWhere(list, expected, X(0));

      expect(list.map((elm) => elm?.value),
          orderedEquals(expected.map((elm) => elm?.value)));
      expect(
          () => list.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1))),
          throwsStateError);

      expect(() => list.singleWhere((elm) => elm == null), throwsStateError);
      expect(() => list.singleWhere((elm) => elm == X(0)), throwsStateError);
      expectSingleWhere(list, expected, X(0));

      expectSkip(list, expected);
      expectSkipWhile(list, expected);

      expectTake(list, expected);
      expectTakeWhile(list, expected);

      expectWhere(list, expected);
    });

    test('one element list', () async {
      final elm = X(0);
      X? x = X(0);
      list.add(x);
      list.validElementCount();
      strongList.add(x);
      x = null;
      expect(list.length, equals(1));
      expect(list, isNotEmpty);
      expect(list.isEmpty, isFalse);
      expect(list.single, equals(elm));
      expected = <X?>[X(0)];
      expect(list, orderedEquals(expected));
      expect(list.first, equals(elm));
      expect(list.last, equals(elm));
      expectAny(list, expected);
      expectAsMap(list, expected);
      expectContains(list, expected);
      expectElementAt(list, expected);
      expectEvery(list, expected);
      expect(list.expand((element) => [element]), orderedEquals(expected));

      expect(() => list.firstWhere((elm) => elm == null), throwsStateError);
      expectFirstWhere(list, expected, X(0));

      expect(list.fold(0, (int pre, X? elm) => pre + (elm?.value ?? 1)),
          equals(0));
      expect(list.followedBy(list), orderedEquals(list.followedBy(list)));
      list.forEach(expectEach(expected));

      expectGetRange(list, expected);
      expectIndexOf(list, expected);
      expectIndexWhere(list, expected);
      expectLastIndexOf(list, expected);
      expectLastIndexWhere(list, expected);

      expect(list.join(), equals(expected.join()));

      expect(() => list.lastWhere((elm) => elm == null), throwsStateError);
      expectLastWhere(list, expected, X(0));

      expect(list.map((elm) => elm?.value),
          orderedEquals(expected.map((elm) => elm?.value)));
      expect(
          list.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1))),
          equals(X(0)));

      expect(() => list.singleWhere((elm) => elm == null), throwsStateError);
      expectSingleWhere(list, expected, X(0));

      expectSkip(list, expected);
      expectSkipWhile(list, expected);

      expectTake(list, expected);
      expectTakeWhile(list, expected);

      expectWhere(list, expected);

      // null and wait for GC
      for (var j = 0; j < strongList.length; ++j) {
        strongList[j] = null;
      }

      for (var j = 0; j < strongList.length; ++j) {
        expect(strongList[j], isNull);
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(1));

      for (var j = 0; j < strongList.length; ++j) {
        expect(list[j], isNull);
      }
    });

    test('one null list', () {
      final elm = null;
      list.add(null);
      list.validElementCount();
      expect(list.length, equals(1));
      expect(list, isNotEmpty);
      expect(list.isEmpty, isFalse);
      expect(list.single, equals(elm));
      expected = <X?>[null];
      expect(list, orderedEquals(expected));
      expect(list.first, equals(elm));
      expect(list.last, equals(elm));
      expectAny(list, expected);
      expectAsMap(list, expected);
      expectContains(list, expected);
      expectElementAt(list, expected);
      expectEvery(list, expected);
      expect(list.expand((element) => [element]), orderedEquals(expected));

      expect(() => list.firstWhere((elm) => elm == X(0)), throwsStateError);
      expectFirstWhere(list, expected, X(0));

      expect(list.fold(0, (int pre, X? elm) => pre + (elm?.value ?? 1)),
          equals(1));
      expect(list.followedBy(list), orderedEquals(list.followedBy(list)));
      list.forEach(expectEach(expected));

      expectGetRange(list, expected);
      expectIndexOf(list, expected);
      expectIndexWhere(list, expected);
      expectLastIndexOf(list, expected);
      expectLastIndexWhere(list, expected);

      expect(list.join(), equals(expected.join()));

      expect(() => list.lastWhere((elm) => elm == X(0)), throwsStateError);
      expectLastWhere(list, expected, X(0));

      expect(list.map((elm) => elm?.value),
          orderedEquals(expected.map((elm) => elm?.value)));
      expect(
          list.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1))),
          equals(null));

      expect(() => list.singleWhere((elm) => elm == X(0)), throwsStateError);
      expectSingleWhere(list, expected, X(0));

      expectSkip(list, expected);
      expectSkipWhile(list, expected);

      expectTake(list, expected);
      expectTakeWhile(list, expected);

      expectWhere(list, expected);
    });

    test('two equal elements list', () async {
      final elm = X(0);
      X? x = X(0);
      list.add(x);
      list.add(x);
      list.validElementCount();
      strongList.add(x);
      strongList.add(x);
      x = null;
      expect(list.length, equals(2));
      expect(list, isNotEmpty);
      expect(list.isEmpty, isFalse);
      expect(() => list.single, throwsStateError);
      expected = <X?>[X(0), X(0)];
      expect(list, orderedEquals(expected));
      expect(list.first, equals(elm));
      expect(list.last, equals(elm));
      expectAny(list, expected);
      expectAsMap(list, expected);
      expectContains(list, expected);
      expectElementAt(list, expected);
      expectEvery(list, expected);
      expect(list.expand((element) => [element]), orderedEquals(expected));

      expect(() => list.firstWhere((elm) => elm == null), throwsStateError);
      expectFirstWhere(list, expected, X(0));

      expect(list.fold(0, (int pre, X? elm) => pre + (elm?.value ?? 1)),
          equals(0));
      expect(list.followedBy(list), orderedEquals(list.followedBy(list)));
      list.forEach(expectEach(expected));

      expectGetRange(list, expected);
      expectIndexOf(list, expected);
      expectIndexWhere(list, expected);
      expectLastIndexOf(list, expected);
      expectLastIndexWhere(list, expected);

      expect(list.join(), equals(expected.join()));

      expect(() => list.lastWhere((elm) => elm == null), throwsStateError);
      expectLastWhere(list, expected, X(0));

      expect(list.map((elm) => elm?.value),
          orderedEquals(expected.map((elm) => elm?.value)));
      expect(
          list.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1))),
          equals(X(0)));

      expect(() => list.singleWhere((elm) => elm == null), throwsStateError);
      expect(() => list.singleWhere((elm) => elm == X(0)), throwsStateError);

      // expect(list.singleWhere((elm) => elm == null, orElse: () => X(0)), equals(X(0)));
      expectSkip(list, expected);
      expectSkipWhile(list, expected);

      expectTake(list, expected);
      expectTakeWhile(list, expected);

      expectWhere(list, expected);

      // null and wait for GC
      for (var j = 0; j < strongList.length; ++j) {
        strongList[j] = null;
      }

      for (var j = 0; j < strongList.length; ++j) {
        expect(strongList[j], isNull);
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(2));

      for (var j = 0; j < strongList.length; ++j) {
        expect(list[j], isNull);
      }
    });

    test('two null list', () {
      final elm = null;
      list.add(null);
      list.add(null);
      list.validElementCount();
      expect(list.length, equals(2));
      expect(list, isNotEmpty);
      expect(list.isEmpty, isFalse);
      expect(() => list.single, throwsStateError);
      expected = <X?>[null, null];
      expect(list, orderedEquals(expected));
      expect(list.first, equals(elm));
      expect(list.last, equals(elm));
      expectAny(list, expected);
      expectAsMap(list, expected);
      expectContains(list, expected);
      expectElementAt(list, expected);
      expectEvery(list, expected);
      expect(list.expand((element) => [element]), orderedEquals(expected));

      expect(() => list.firstWhere((elm) => elm == X(0)), throwsStateError);
      expectFirstWhere(list, expected, X(0));

      expect(list.fold(0, (int pre, X? elm) => pre + (elm?.value ?? 1)),
          equals(2));
      expect(list.followedBy(list), orderedEquals(list.followedBy(list)));
      list.forEach(expectEach(expected));

      expectGetRange(list, expected);
      expectIndexOf(list, expected);
      expectLastIndexOf(list, expected);
      expectIndexWhere(list, expected);
      expectLastIndexWhere(list, expected);

      expect(list.join(), equals(expected.join()));

      expect(() => list.lastWhere((elm) => elm == X(0)), throwsStateError);
      expectLastWhere(list, expected, X(0));

      expect(list.map((elm) => elm?.value),
          orderedEquals(expected.map((elm) => elm?.value)));
      expect(
          list.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1))),
          equals(X(2)));

      expect(() => list.singleWhere((elm) => elm == null), throwsStateError);
      expect(() => list.singleWhere((elm) => elm == X(0)), throwsStateError);

      expectSkip(list, expected);
      expectSkipWhile(list, expected);

      expectTake(list, expected);
      expectTakeWhile(list, expected);

      expectWhere(list, expected);
    });
  });

  group("length, [], and []=", () {
    const count = 17;
    late WeakList<X> list;
    late List<X?> expected;
    late List<X?> strongList;

    setUp(() {
      strongList = <X?>[];
      list = WeakList();
      expected = <X?>[];
      for (int j = 0; j < count; ++j) {
        X? x = X(j);
        strongList.add(x);
        list.add(x);
        expected.add(X(j));
        x = null;
      }
      list.validElementCount();
    });

    test('basic', () {
      expect(list, isNotEmpty);
      expect(list.length, equals(count));
      expect(list, orderedEquals(expected));
      expect(list.reversed, orderedEquals(expected.reversed));
      for (int j = 0; j < count; ++j) {
        expect(list[j], equals(expected[j]));
      }
      for (int j = count; --j >= 0;) {
        expect(list[j], equals(expected[j]));
      }
      for (int j = 0; j < count; ++j) {
        expect(list.elementAt(j), equals(expected[j]));
      }
      for (int j = count; --j >= 0;) {
        expect(list.elementAt(j), equals(expected[j]));
      }
      expect(list.first, equals(expected.first));
      expect(list.last, equals(expected.last));
      expect(() => list.single, throwsStateError);
      expectAny(list, expected);
      expectAsMap(list, expected);
      expectContains(list, expected);
      expectEvery(list, expected);
      expect(list.expand((element) => list),
          orderedEquals(expected.expand((element) => expected)));

      expect(() => list.firstWhere((elm) => elm == null), throwsStateError);
      expectFirstWhere(list, expected, X(0));

      expect(list.fold(0, (int pre, X? elm) => pre + (elm?.value ?? 1)),
          equals((0 + count - 1) * count ~/ 2));
      expect(list.followedBy(list), orderedEquals(list.followedBy(list)));
      list.forEach(expectEach(expected));

      expectGetRange(list, expected);
      expectIndexOf(list, expected);
      expectLastIndexOf(list, expected);
      expectIndexWhere(list, expected);
      expectLastIndexWhere(list, expected);

      expect(list.join(), equals(expected.join()));

      expect(() => list.lastWhere((elm) => elm == null), throwsStateError);
      expectLastWhere(list, expected, X(0));

      expect(list.map((elm) => elm?.value),
          orderedEquals(expected.map((elm) => elm?.value)));
      expect(
          list.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1))),
          equals(expected.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1)))));

      expect(() => list.singleWhere((elm) => elm == null), throwsStateError);
      expectSingleWhere(list, expected, X(0));

      expectSkip(list, expected);
      expectSkipWhile(list, expected);

      expectTake(list, expected);
      expectTakeWhile(list, expected);

      expectWhere(list, expected);
    });

    test('null even and wait GC', () async {
      // null even and wait for GC
      for (var j = 0; j < strongList.length; j += 2) {
        strongList[j] = null;
      }

      for (var j = 0; j < strongList.length; ++j) {
        if (j.isEven) {
          expect(strongList[j], isNull);
        } else {
          expect(strongList[j], equals(X(j)));
        }
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(count));

      for (var j = 0; j < strongList.length; ++j) {
        if (j.isEven) {
          expect(list[j], isNull);
        } else {
          expect(list[j], equals(X(j)));
        }
      }
      // print('even @626, $list');
    });

    test('null odd and wait GC', () async {
      // null odd and wait for GC
      for (var j = 1; j < strongList.length; j += 2) {
        strongList[j] = null;
      }

      for (var j = 0; j < strongList.length; ++j) {
        if (j.isOdd) {
          expect(strongList[j], isNull);
        } else {
          expect(strongList[j], equals(X(j)));
        }
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(count));

      for (var j = 0; j < strongList.length; ++j) {
        if (j.isOdd) {
          expect(list[j], isNull);
        } else {
          expect(list[j], equals(X(j)));
        }
      }
      // print('odd @655, $list');
    });

    test('null triple and wait GC', () async {
      // null triple and wait for GC
      for (var j = 2; j < strongList.length; j += 3) {
        strongList[j] = null;
      }

      for (var j = 0; j < strongList.length; ++j) {
        if ((j + 1) % 3 == 0) {
          expect(strongList[j], isNull);
        } else {
          expect(strongList[j], equals(X(j)));
        }
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(count));

      for (var j = 0; j < strongList.length; ++j) {
        if ((j + 1) % 3 == 0) {
          expect(list[j], isNull);
        } else {
          expect(list[j], equals(X(j)));
        }
      }
      // print('even @626, $list');
    });

    test('length $count -> ${count - 1}', () {
      expect(() => list.length = -1, throwsRangeError);
      list.length = count - 1;
      list.validElementCount();
      expect(list.length, equals(count - 1));
      expected.removeLast();
      expect(list, orderedEquals(expected));
      for (int j = 0; j < list.length; ++j) {
        expect(list[j], equals(expected[j]));
      }
      for (int j = list.length; --j >= 0;) {
        expect(list[j], equals(expected[j]));
      }
    });

    test('length $count -> ${count + 1}', () {
      list.length = count + 1;
      list.validElementCount();
      expect(list.length, equals(count + 1));
      expected.add(null);
      expect(list, orderedEquals(expected));
      for (int j = 0; j < list.length; ++j) {
        expect(list[j], equals(expected[j]));
      }
      for (int j = list.length; --j >= 0;) {
        expect(list[j], equals(expected[j]));
      }
    });

    test('length $count -> ${count - 1} then $count', () {
      list.length = count - 1;
      list.length = count;
      list.validElementCount();
      expect(list.length, equals(count));
      expected.removeLast();
      expected.add(null);
      expect(list, orderedEquals(expected));
      for (int j = 0; j < list.length; ++j) {
        expect(list[j], equals(expected[j]));
      }
      for (int j = list.length; --j >= 0;) {
        expect(list[j], equals(expected[j]));
      }
    });

    test('[oddJ]= null then ...', () async {
      for (int j = 1; j < count; j += 2) {
        list[j] = null;
        strongList[j] = null;
        expected[j] = null;
      }
      list.validElementCount();
      expect(list, orderedEquals(expected), reason: '$list');

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(count));
      expect(list, orderedEquals(expected), reason: '$list');

      // change length
      list.length = count ~/ 2;
      list.validElementCount();
      strongList.length = count ~/ 2;
      expect(list,
          orderedEquals(expected..removeRange(count ~/ 2, expected.length)));
      // put back X3
      X? x = X(3);
      list[3] = x;
      list.validElementCount();
      strongList[3] = x;
      expected[3] = X(3);
      expect(list, orderedEquals(expected));

      // put back the end one
      final idx0 = count ~/ 2 - 1;
      x = X(idx0);
      list[idx0] = x;
      list.validElementCount();
      strongList[idx0] = x;
      x = null;
      expected[idx0] = X(idx0);

      expect(list, orderedEquals(expected));

      expect(list.first, equals(expected.first));
      expect(list.last, equals(expected.last));
      expect(() => list.single, throwsStateError);
      expectAny(list, expected);
      expectAsMap(list, expected);
      expectContains(list, expected);
      expectElementAt(list, expected);
      expectEvery(list, expected);
      expect(list.expand((element) => [element]), orderedEquals(expected));

      expectFirstWhere(list, expected, X(0));

      expect(
          list.fold(0, (int pre, X? elm) => pre + (elm?.value ?? 1)),
          equals(expected.fold<int>(
              0, (int pre, X? elm) => pre + (elm?.value ?? 1))));
      expect(list.followedBy(list), orderedEquals(list.followedBy(list)));
      list.forEach(expectEach(expected));

      expectGetRange(list, expected);
      expectIndexOf(list, expected);
      expectLastIndexOf(list, expected);
      expectIndexWhere(list, expected);
      expectLastIndexWhere(list, expected);

      expect(list.join(), equals(expected.join()));

      expectLastWhere(list, expected, X(0));

      expect(list.map((elm) => elm?.value),
          orderedEquals(expected.map((elm) => elm?.value)));
      expect(
          list.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1))),
          equals(expected.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1)))));

      expect(() => list.singleWhere((elm) => elm == null), throwsStateError);

      expectSkip(list, expected);
      expectSkipWhile(list, expected);

      expectTake(list, expected);
      expectTakeWhile(list, expected);

      expectWhere(list, expected);

      strongList[3] = null;
      strongList[idx0] = null;
      expected[3] = null;
      expected[idx0] = null;

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(count ~/ 2));

      for (var j = 0; j < strongList.length; ++j) {
        expect(list[j], equals(expected[j]));
      }
      list.validElementCount();
    });

    test('[evenJ]= null then ...', () async {
      for (int j = 0; j < count; j += 2) {
        list[j] = null;
        strongList[j] = null;
        expected[j] = null;
      }
      list.validElementCount();
      expect(list, orderedEquals(expected), reason: '$list');

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(count));
      expect(list, orderedEquals(expected), reason: '$list');

      // change length
      list.length = count ~/ 2;
      list.validElementCount();
      strongList.length = count ~/ 2;
      expect(list,
          orderedEquals(expected..removeRange(count ~/ 2, expected.length)));
      // put back X4
      X? x = X(4);
      list[4] = x;
      strongList[4] = x;
      x = null;
      expected[4] = X(4);
      expect(list, orderedEquals(expected));

      expect(list.first, equals(expected.first));
      expect(list.last, equals(expected.last));
      expect(() => list.single, throwsStateError);
      expectAny(list, expected);
      expectAsMap(list, expected);
      expectContains(list, expected);
      expectElementAt(list, expected);
      expectEvery(list, expected);
      expect(list.expand((element) => [element]), orderedEquals(expected));

      expect(() => list.firstWhere((elm) => elm == X(0)), throwsStateError);
      expectFirstWhere(list, expected, X(0));

      expect(
          list.fold(0, (int pre, X? elm) => pre + (elm?.value ?? 1)),
          equals(expected.fold<int>(
              0, (int pre, X? elm) => pre + (elm?.value ?? 1))));
      expect(list.followedBy(list), orderedEquals(list.followedBy(list)));
      list.forEach(expectEach(expected));

      expectGetRange(list, expected);
      expectIndexOf(list, expected);
      expectLastIndexOf(list, expected);
      expectIndexWhere(list, expected);
      expectLastIndexWhere(list, expected);

      expect(list.join(), equals(expected.join()));

      expect(() => list.lastWhere((elm) => elm == X(0)), throwsStateError);
      expectLastWhere(list, expected, X(0));

      expect(list.map((elm) => elm?.value),
          orderedEquals(expected.map((elm) => elm?.value)));
      expect(
          list.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1))),
          equals(expected.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1)))));

      expect(() => list.singleWhere((elm) => elm == null), throwsStateError);
      expect(() => list.singleWhere((elm) => elm == X(0)), throwsStateError);

      expectSkip(list, expected);
      expectSkipWhile(list, expected);

      expectTake(list, expected);
      expectTakeWhile(list, expected);

      expectWhere(list, expected);

      strongList[4] = null;
      expected[4] = null;

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(count ~/ 2));

      expect(list, orderedEquals(expected), reason: '$list');
      list.validElementCount();
    });
  });

  group('Odd index null', () {
    const count = 17;
    late WeakList<X> list;
    late List<X?> expected;
    late List<X?> strongList;

    void create() {
      list = WeakList();
      expected = <X?>[];
      strongList = <X?>[];
      for (int j = 0; j < count; ++j) {
        if (j.isOdd) {
          list.add(null);
          expected.add(null);
          strongList.add(null);
        } else {
          final x = X(j);
          strongList.add(x);
          list.add(x);
          expected.add(X(j));
        }
      }
      list.validElementCount();
    }

    setUp(() => create());

    test('basic', () async {
      expect(list, orderedEquals(expected), reason: '$list');

      // nullify and wait GC
      for (int j = 0; j < count; ++j) {
        strongList[j] = null;
        expected[j] = null;
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(count));

      expect(list, orderedEquals(expected), reason: '$list');
      list.validElementCount();
    });

    test('add()', () async {
      const extraCount = count ~/ 2;
      for (int j = count; j < count + extraCount; ++j) {
        if (j.isOdd) {
          expected.add(X(j));
          X? x = X(j);
          list.add(x);
          strongList.add(x);
          x = null; // must set to null to make GC
        } else {
          expected.add(null);
          list.add(null);
          strongList.add(null);
        }
      }
      list.validElementCount();
      expect(list, orderedEquals(expected));
      // nullify and wait GC
      for (int j = count; j < count + extraCount; ++j) {
        if (j.isOdd) {
          expected[j] = null;
          strongList[j] = null;
        }
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(expected.length));

      expect(list, orderedEquals(expected), reason: '$list');
      list.validElementCount();
    });

    test('addAll()', () async {
      const extraCount = count ~/ 2;
      List<X?> extra = <X?>[];
      final expectExtra = <X?>[];
      for (int j = count; j < count + extraCount; ++j) {
        if (j.isOdd) {
          extra.add(X(j));
          expectExtra.add(X(j));
        } else {
          extra.add(null);
          expectExtra.add(null);
        }
      }
      expected.addAll(expectExtra);
      list.addAll(extra);
      list.validElementCount();
      strongList.addAll(extra);
      expect(list, orderedEquals(expected));
      extra = <X?>[]; // empty to make GC
      list.validElementCount();
      for (int j = count; j < count + extraCount; ++j) {
        if (j.isOdd) {
          strongList[j] = null;
          expected[j] = null;
        }
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(expected.length));

      expect(list, orderedEquals(expected), reason: '$list');
      list.validElementCount();
    });

    test('fillRange()', () async {
      final len = expected.length;
      const extraCount = count ~/ 2;
      for (int j = count; j < count + extraCount; ++j) {
        X? x = j.isOdd ? X(j) : null;
        for (int s = 0; s < len; ++s) {
          for (int e = s; e < len; ++e) {
            list.fillRange(s, e, x);
            strongList.fillRange(s, e, x);
            expected.fillRange(s, e, x);
            expect(list, orderedEquals(expected));
          }
        }
        x = null;
      }

      list.validElementCount();

      for (int j = 0; j < count; ++j) {
        if (j.isOdd) {
          strongList[j] = null;
          expected[j] = null;
        }
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(expected.length));

      expect(list, orderedEquals(expected), reason: '$list');
      list.validElementCount();
    });

    test('clear()', () {
      expected.clear();
      list.clear();
      list.validElementCount();
      expect(list, orderedEquals(expected));
    });

    test('insert()', () async {
      final len = expected.length;
      const extraCount = count ~/ 2;
      for (int s = 0; s < len; ++s) {
        for (int j = count; j < count + extraCount; ++j) {
          final x = j.isOdd ? X(j) : null;
          strongList.insert(s, x);
          list.insert(s, x);
          expected.insert(s, x);
          expect(list, orderedEquals(expected), reason: 'j: $j, x: $x');
        }
      }
      list.validElementCount();

      for (int j = 0; j < expected.length; ++j) {
        if (j.isOdd) {
          strongList[j] = null;
          expected[j] = null;
        }
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(expected.length));

      expect(list, orderedEquals(expected), reason: '$list');
      list.validElementCount();
    });

    test('insertAll()', () async {
      final len = expected.length;
      const extraCount = count ~/ 2;
      List<X?> extra = <X?>[];
      final expectExtra = <X?>[];
      for (int j = count; j < count + extraCount; ++j) {
        extra.add(j.isOdd ? X(j) : null);
        expectExtra.add(j.isOdd ? X(j) : null);
      }
      for (int s = 0; s < len; ++s) {
        list.insertAll(s, extra);
        strongList.insertAll(s, extra);
        expected.insertAll(s, expectExtra);
        expect(list, orderedEquals(expected));
      }
      list.validElementCount();
      extra = <X?>[];
      final nullified = <X?>{};
      for (int j = 0; j < expected.length; ++j) {
        final elm = expected[j];
        if (j.isOdd) {
          nullified.add(elm);
          strongList[j] = null;
          expected[j] = null;
        }
      }
      for (int j = 0; j < expected.length; ++j) {
        if (nullified.contains(expected[j])) {
          strongList[j] = null;
          expected[j] = null;
        }
      }

      await vmService.gc();

      expect(list, isNotEmpty);
      expect(list.length, equals(expected.length));

      expect(list, orderedEquals(expected), reason: '$list');
      list.validElementCount();
    });

    test('remove()', () {
      final len = expected.length;
      for (int j = 0; j < len; ++j) {
        final elm = expected[Random().nextInt(expected.length)];
        expect(list.remove(elm), equals(expected.remove(elm)),
            reason: 'j: $j, elm: $elm');
        list.validElementCount();
      }
    });

    test('removeAt()', () {
      final history = <int>[];
      final len = expected.length;
      for (int j = 0; j < len; ++j) {
        final idx = Random().nextInt(expected.length);
        history.add(idx);
        expect(list.removeAt(idx), equals(expected.removeAt(idx)),
            reason: 'idxes: $history\nexpected: $expected\n    list: $list');
        expect(list, orderedEquals(expected),
            reason: 'idxes: $history\nexpected: $expected\n    list: $list');
        list.validElementCount();
      }
    });

    test('removeLast()', () {
      final len = expected.length;
      for (int j = len; --j >= 0;) {
        expect(list.removeLast(), equals(expected.removeLast()),
            reason: 'idx: $j\nexpected: $expected\n    list: $list');
        expect(list, orderedEquals(expected),
            reason: 'idx: $j\nexpected: $expected\n    list: $list');
        list.validElementCount();
      }
    });

    test('removeRange()', () {
      final len = expected.length;
      for (int s = 0; s <= len; ++s) {
        for (int e = s; e <= len; ++e) {
          list.removeRange(s, e);
          expected.removeRange(s, e);
          expect(list, orderedEquals(expected), reason: '($s, $e)');
          list.validElementCount();
          create();
        }
      }
    });

    test('removeWhere()', () {
      while (expected.isNotEmpty) {
        final elm = expected[Random().nextInt(expected.length)];
        list.removeWhere((e) => e == elm);
        expected.removeWhere((e) => e == elm);
        expect(list, orderedEquals(expected), reason: 'elm: $elm');
        list.validElementCount();
      }
    });

    test('retainWhere()', () {
      while (expected.isNotEmpty) {
        final elm = expected[Random().nextInt(expected.length)];
        list.retainWhere((e) => e != elm);
        expected.retainWhere((e) => e != elm);
        expect(list, orderedEquals(expected), reason: 'elm: $elm');
        list.validElementCount();
      }
    });

    test('replaceRange()', () {
      final len = expected.length;
      for (int s = 0; s <= len; ++s) {
        for (int e = s; e <= len; ++e) {
          final contents = <X?>[];
          for (int j = s; j < e; ++j) {
            contents.add(j.isOdd ? null : X(j + count));
          }
          list.replaceRange(s, e, contents);
          expected.replaceRange(s, e, contents);
          expect(list, orderedEquals(expected), reason: '($s, $e)');
          list.validElementCount();
          create();
        }
      }
    });

    test('setAll()', () {
      final len = expected.length;
      expect(() => list.setAll(len, []), throwsRangeError);
      expect(
          () => list.setAll(len - 1, [X(count), X(count)]), throwsStateError);
      for (int s = 0; s < len; ++s) {
        for (int e = s; e <= len; ++e) {
          final contents = <X?>[];
          for (int j = s; j < e; ++j) {
            contents.add(j.isOdd ? null : X(j + count));
          }
          list.setAll(s, contents);
          expected.setAll(s, contents);
          expect(list, orderedEquals(expected), reason: '($s, $e, $contents)');
          list.validElementCount();
          create();
        }
      }
    });

    test('setRange()', () {
      final len = expected.length;
      expect(() => list.setRange(len, len + 1, []), throwsRangeError);
      expect(() => list.setRange(len - 2, len, [null]), throwsStateError);
      expect(
          () => list.setRange(len - 2, len, [null, null], 1), throwsStateError);
      for (int s = 0; s < len; ++s) {
        for (int e = s; e <= len; ++e) {
          final contents = <X?>[];
          final expectContents = <X?>[];
          for (int j = s; j < e; ++j) {
            contents.add(j.isOdd ? null : X(j + count));
            expectContents.add(j.isOdd ? null : X(j + count));
          }
          list.setRange(s, e, contents);
          strongList.setRange(s, e, contents);
          expected.setRange(s, e, expectContents);
          expect(list, orderedEquals(expected), reason: '($s, $e, $contents)');
          list.validElementCount();
          create();
        }
      }
    });
  });

  group('Even index null', () {
    const count = 17;
    late WeakList<X> list;
    late List<X?> expected;
    late List<X?> strongList;

    void create() {
      list = WeakList();
      expected = <X?>[];
      strongList = <X?>[];
      for (int j = 0; j < count; ++j) {
        if (j.isEven) {
          list.add(null);
          strongList.add(null);
          expected.add(null);
        } else {
          final x = X(j);
          list.add(x);
          strongList.add(x);
          expected.add(X(j));
        }
      }
      list.validElementCount();
    }

    setUp(() => create());

    test('basic', () {
      expect(list, orderedEquals(expected), reason: '$list');
    });

    test('add()', () {
      const extraCount = count ~/ 2;
      for (int j = count; j < count + extraCount; ++j) {
        if (j.isOdd) {
          expected.add(X(j));
          final x = X(j);
          list.add(x);
          strongList.add(x);
        } else {
          expected.add(null);
          list.add(null);
          strongList.add(null);
        }
        list.validElementCount();
      }
      expect(list, orderedEquals(expected));
    });

    test('addAll()', () {
      const extraCount = count ~/ 2;
      final extra = <X?>[];
      final expectExtra = <X?>[];
      for (int j = count; j < count + extraCount; ++j) {
        if (j.isOdd) {
          extra.add(X(j));
          expectExtra.add(X(j));
        } else {
          extra.add(null);
          expectExtra.add(null);
        }
      }
      expected.addAll(expectExtra);
      list.addAll(extra);
      list.validElementCount();
      strongList.addAll(extra);
      expect(list, orderedEquals(expected));
    });

    test('fillRange()', () {
      final len = expected.length;
      const extraCount = count ~/ 2;
      for (int j = count; j < count + extraCount; ++j) {
        final x = j.isOdd ? X(j) : null;
        final expectX = j.isOdd ? X(j) : null;
        for (int s = 0; s < len; ++s) {
          for (int e = s; e < len; ++e) {
            list.fillRange(s, e, x);
            try {
              list.validElementCount();
            } catch (ex) {
              print('s: $s, e: $e');
              rethrow;
            }
            strongList.fillRange(s, e, x);
            expected.fillRange(s, e, expectX);
            expect(list, orderedEquals(expected));
          }
        }
      }
    });

    test('clear()', () {
      expected.clear();
      list.clear();
      list.validElementCount();
      expect(list, orderedEquals(expected));
    });

    test('insert()', () {
      final len = expected.length;
      const extraCount = count ~/ 2;
      for (int s = 0; s < len; ++s) {
        for (int j = count; j < count + extraCount; ++j) {
          final x = j.isOdd ? X(j) : null;
          list.insert(s, x);
          list.validElementCount();
          expected.insert(s, x);
          expect(list, orderedEquals(expected), reason: 'j: $j, x: $x');
        }
      }
    });

    test('insertAll()', () {
      final len = expected.length;
      const extraCount = count ~/ 2;
      final extra = <X?>[];
      for (int j = count; j < count + extraCount; ++j) {
        extra.add(j.isOdd ? X(j) : null);
      }
      for (int s = 0; s < len; ++s) {
        list.insertAll(s, extra);
        list.validElementCount();
        expected.insertAll(s, extra);
        expect(list, orderedEquals(expected));
      }
    });

    test('remove()', () {
      final len = expected.length;
      for (int j = 0; j < len; ++j) {
        final elm = expected[Random().nextInt(expected.length)];
        expect(list.remove(elm), equals(expected.remove(elm)),
            reason: 'j: $j, elm: $elm');
        list.validElementCount();
      }
    });

    test('removeAt()', () {
      final history = <int>[];
      final len = expected.length;
      for (int j = 0; j < len; ++j) {
        final idx = Random().nextInt(expected.length);
        history.add(idx);
        expect(list.removeAt(idx), equals(expected.removeAt(idx)),
            reason: 'idxes: $history\nexpected: $expected\n    list: $list');
        expect(list, orderedEquals(expected),
            reason: 'idxes: $history\nexpected: $expected\n    list: $list');
        list.validElementCount();
      }
    });

    test('removeLast()', () {
      final len = expected.length;
      for (int j = len; --j >= 0;) {
        expect(list.removeLast(), equals(expected.removeLast()),
            reason: 'idx: $j\nexpected: $expected\n    list: $list');
        expect(list, orderedEquals(expected),
            reason: 'idx: $j\nexpected: $expected\n    list: $list');
        list.validElementCount();
      }
    });

    test('removeRange()', () {
      final len = expected.length;
      for (int s = 0; s <= len; ++s) {
        for (int e = s; e <= len; ++e) {
          list.removeRange(s, e);
          expected.removeRange(s, e);
          expect(list, orderedEquals(expected), reason: '($s, $e)');
          list.validElementCount();
          create();
        }
      }
    });

    test('removeWhere()', () {
      while (expected.isNotEmpty) {
        final elm = expected[Random().nextInt(expected.length)];
        list.removeWhere((e) => e == elm);
        expected.removeWhere((e) => e == elm);
        expect(list, orderedEquals(expected), reason: 'elm: $elm');
        list.validElementCount();
      }
    });

    test('retainWhere()', () {
      while (expected.isNotEmpty) {
        final elm = expected[Random().nextInt(expected.length)];
        list.retainWhere((e) => e != elm);
        expected.retainWhere((e) => e != elm);
        expect(list, orderedEquals(expected), reason: 'elm: $elm');
        list.validElementCount();
      }
    });

    test('replaceRange()', () {
      final len = expected.length;
      for (int s = 0; s <= len; ++s) {
        for (int e = s; e <= len; ++e) {
          final contents = <X?>[];
          for (int j = s; j < e; ++j) {
            contents.add(j.isOdd ? null : X(j + count));
          }
          list.replaceRange(s, e, contents);
          expected.replaceRange(s, e, contents);
          expect(list, orderedEquals(expected), reason: '($s, $e)');
          try {
            list.validElementCount();
          } catch (ex) {
            print('s: $s, e: $e');
            rethrow;
          }
          create();
        }
      }
    });

    test('setAll()', () {
      final len = expected.length;
      expect(() => list.setAll(len, []), throwsRangeError);
      expect(
          () => list.setAll(len - 1, [X(count), X(count)]), throwsStateError);
      for (int s = 0; s < len; ++s) {
        for (int e = s; e <= len; ++e) {
          final contents = <X?>[];
          for (int j = s; j < e; ++j) {
            contents.add(j.isOdd ? null : X(j + count));
          }
          list.setAll(s, contents);
          try {
            list.validElementCount();
          } catch (ex) {
            print('s: $s, e:$e');
            rethrow;
          }
          expected.setAll(s, contents);
          expect(list, orderedEquals(expected), reason: '($s, $e, $contents)');
          create();
        }
      }
    });

    test('setRange()', () {
      final len = expected.length;
      expect(() => list.setRange(len, len + 1, []), throwsRangeError);
      expect(() => list.setRange(len - 2, len, [null]), throwsStateError);
      expect(
          () => list.setRange(len - 2, len, [null, null], 1), throwsStateError);
      for (int s = 0; s < len; ++s) {
        for (int e = s; e <= len; ++e) {
          final contents = <X?>[];
          for (int j = s; j < e; ++j) {
            contents.add(j.isOdd ? null : X(j + count));
          }
          list.setRange(s, e, contents);
          list.validElementCount();
          expected.setRange(s, e, contents);
          expect(list, orderedEquals(expected), reason: '($s, $e, $contents)');
          create();
        }
      }
    });
  });

  group('triple null', () {
    const count = 21;
    late WeakList<X> list;
    late List<X?> expected;
    late List<X?> strongList;

    void create() {
      list = WeakList();
      expected = <X?>[];
      strongList = <X?>[];
      bool isNull = true;
      for (int j = 0; j < count; ++j) {
        final x = X(j);
        list.add(isNull ? null : x);
        strongList.add(isNull ? null : x);
        expected.add(isNull ? null : X(j));
        if ((j + 1) % 3 == 0) {
          isNull = !isNull;
        }
      }
      list.validElementCount();
    }

    setUp(() => create());

    test('basic', () {
      expect(list, orderedEquals(expected), reason: '$list');
      expect(list.first, equals(expected.first));
      expect(list.last, equals(expected.last));
      expect(() => list.single, throwsStateError);
      expectAny(list, expected);
      expectAsMap(list, expected);
      expectContains(list, expected);
      expectElementAt(list, expected);
      expectEvery(list, expected);
      expect(list.expand((element) => [element]), orderedEquals(expected));

      expect(() => list.firstWhere((elm) => elm == X(0)), throwsStateError);
      expectFirstWhere(list, expected, X(0));

      expect(
          list.fold(0, (int pre, X? elm) => pre + (elm?.value ?? 1)),
          equals(expected.fold<int>(
              0, (int pre, X? elm) => pre + (elm?.value ?? 1))));
      expect(list.followedBy(list), orderedEquals(list.followedBy(list)));
      list.forEach(expectEach(expected));

      expectGetRange(list, expected);
      expectIndexOf(list, expected);
      expectLastIndexOf(list, expected);
      expectIndexWhere(list, expected);
      expectLastIndexWhere(list, expected);

      expect(list.join(), equals(expected.join()));

      expect(() => list.lastWhere((elm) => elm == X(0)), throwsStateError);
      expectLastWhere(list, expected, X(0));

      expect(list.map((elm) => elm?.value),
          orderedEquals(expected.map((elm) => elm?.value)));
      expect(
          list.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1))),
          equals(expected.reduce(
              (X? pre, X? elm) => X((pre?.value ?? 1) + (elm?.value ?? 1)))));

      expect(() => list.singleWhere((elm) => elm == null), throwsStateError);
      expect(() => list.singleWhere((elm) => elm == X(0)), throwsStateError);

      expectSkip(list, expected);
      expectSkipWhile(list, expected);

      expectTake(list, expected);
      expectTakeWhile(list, expected);

      expectWhere(list, expected);
    });

    test('add()', () {
      const extraCount = count ~/ 2;
      for (int j = count; j < count + extraCount; ++j) {
        if (j.isOdd) {
          expected.add(X(j));
          final x = X(j);
          list.add(x);
          strongList.add(x);
        } else {
          expected.add(null);
          list.add(null);
          strongList.add(null);
        }
        list.validElementCount();
      }
      expect(list, orderedEquals(expected));
    });

    test('addAll()', () {
      const extraCount = count ~/ 2;
      final extra = <X?>[];
      final expectExtra = <X?>[];
      for (int j = count; j < count + extraCount; ++j) {
        if (j.isOdd) {
          extra.add(X(j));
          expectExtra.add(X(j));
        } else {
          extra.add(null);
          expectExtra.add(null);
        }
      }
      expected.addAll(expectExtra);
      list.addAll(extra);
      list.validElementCount();
      strongList.addAll(extra);
      expect(list, orderedEquals(expected));
    });

    test('fillRange()', () {
      final len = expected.length;
      const extraCount = count ~/ 2;
      for (int j = count; j < count + extraCount; ++j) {
        final x = j.isOdd ? X(j) : null;
        final expectX = j.isOdd ? X(j) : null;
        for (int s = 0; s < len; ++s) {
          for (int e = s; e < len; ++e) {
            list.fillRange(s, e, x);
            list.validElementCount();
            strongList.fillRange(s, e, x);
            expected.fillRange(s, e, expectX);
            expect(list, orderedEquals(expected));
          }
        }
      }
    });

    test('clear()', () {
      expected.clear();
      list.clear();
      list.validElementCount();
      expect(list, orderedEquals(expected));
    });

    test('insert()', () {
      final len = expected.length;
      const extraCount = count ~/ 2;
      for (int s = 0; s < len; ++s) {
        for (int j = count; j < count + extraCount; ++j) {
          final x = j.isOdd ? X(j) : null;
          list.insert(s, x);
          list.validElementCount();
          expected.insert(s, x);
          expect(list, orderedEquals(expected), reason: 'j: $j, x: $x');
        }
      }
    });

    test('insertAll()', () {
      final len = expected.length;
      const extraCount = count ~/ 2;
      final extra = <X?>[];
      for (int j = count; j < count + extraCount; ++j) {
        extra.add(j.isOdd ? X(j) : null);
      }
      for (int s = 0; s < len; ++s) {
        list.insertAll(s, extra);
        list.validElementCount();
        expected.insertAll(s, extra);
        expect(list, orderedEquals(expected));
      }
    });

    test('remove()', () {
      final len = expected.length;
      for (int j = 0; j < len; ++j) {
        final elm = expected[Random().nextInt(expected.length)];
        expect(list.remove(elm), equals(expected.remove(elm)),
            reason: 'j: $j, elm: $elm');
        list.validElementCount();
      }
    });

    test('removeAt()', () {
      final history = <int>[];
      final len = expected.length;
      for (int j = 0; j < len; ++j) {
        final idx = Random().nextInt(expected.length);
        history.add(idx);
        expect(list.removeAt(idx), equals(expected.removeAt(idx)),
            reason: 'idxes: $history\nexpected: $expected\n    list: $list');
        expect(list, orderedEquals(expected),
            reason: 'idxes: $history\nexpected: $expected\n    list: $list');
        list.validElementCount();
      }
    });

    test('removeLast()', () {
      final len = expected.length;
      for (int j = len; --j >= 0;) {
        expect(list.removeLast(), equals(expected.removeLast()),
            reason: 'idx: $j\nexpected: $expected\n    list: $list');
        expect(list, orderedEquals(expected),
            reason: 'idx: $j\nexpected: $expected\n    list: $list');
        list.validElementCount();
      }
    });

    test('removeRange()', () {
      final len = expected.length;
      for (int s = 0; s <= len; ++s) {
        for (int e = s; e <= len; ++e) {
          list.removeRange(s, e);
          expected.removeRange(s, e);
          expect(list, orderedEquals(expected), reason: '($s, $e)');
          list.validElementCount();
          create();
        }
      }
    });

    test('removeWhere()', () {
      while (expected.isNotEmpty) {
        final elm = expected[Random().nextInt(expected.length)];
        list.removeWhere((e) => e == elm);
        expected.removeWhere((e) => e == elm);
        expect(list, orderedEquals(expected), reason: 'elm: $elm');
        list.validElementCount();
      }
    });

    test('retainWhere()', () {
      while (expected.isNotEmpty) {
        final elm = expected[Random().nextInt(expected.length)];
        list.retainWhere((e) => e != elm);
        expected.retainWhere((e) => e != elm);
        expect(list, orderedEquals(expected), reason: 'elm: $elm');
        list.validElementCount();
      }
    });

    test('replaceRange()', () {
      final len = expected.length;
      for (int s = 0; s <= len; ++s) {
        for (int e = s; e <= len; ++e) {
          final contents = <X?>[];
          for (int j = s; j < e; ++j) {
            contents.add(j.isOdd ? null : X(j + count));
          }
          list.replaceRange(s, e, contents);
          expected.replaceRange(s, e, contents);
          expect(list, orderedEquals(expected), reason: '($s, $e)');
          try {
            list.validElementCount();
          } catch (ex) {
            print('s:$s, e:$e');
            rethrow;
          }
          create();
        }
      }
    });

    test('setAll()', () {
      final len = expected.length;
      expect(() => list.setAll(len, []), throwsRangeError);
      expect(
          () => list.setAll(len - 1, [X(count), X(count)]), throwsStateError);
      for (int s = 0; s < len; ++s) {
        for (int e = s; e <= len; ++e) {
          final contents = <X?>[];
          for (int j = s; j < e; ++j) {
            contents.add(j.isOdd ? null : X(j + count));
          }
          list.setAll(s, contents);
          list.validElementCount();
          expected.setAll(s, contents);
          expect(list, orderedEquals(expected), reason: '($s, $e, $contents)');
          create();
        }
      }
    });

    test('setRange()', () {
      final len = expected.length;
      expect(() => list.setRange(len, len + 1, []), throwsRangeError);
      expect(() => list.setRange(len - 2, len, [null]), throwsStateError);
      expect(
          () => list.setRange(len - 2, len, [null, null], 1), throwsStateError);
      for (int s = 0; s < len; ++s) {
        for (int e = s; e <= len; ++e) {
          final contents = <X?>[];
          for (int j = s; j < e; ++j) {
            contents.add(j.isOdd ? null : X(j + count));
          }
          list.setRange(s, e, contents);
          list.validElementCount();
          expected.setRange(s, e, contents);
          expect(list, orderedEquals(expected), reason: '($s, $e, $contents)');
          create();
        }
      }
    });
  });
}

class X {
  final int value;
  X(this.value);

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is X && value == other.value);

  @override
  String toString() => 'X$value';
}
