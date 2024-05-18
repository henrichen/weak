// https://github.com/henrichen/weak
// weak_list_gc_test.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
library weak_list_gc_test;

import 'package:weak/weak.dart';
import 'package:test/test.dart';
import 'gc_util.dart';

/// IMPORTANT: set VM options
///
/// `--enable-vm-service`
///
/// so we can force GC.
Future<void> main() async {
  // Log.printOn(kTag);

  final vmService = await VmServiceUtil.create();

  group('WeakList []=, [] operators, and containsKey()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakListGetSet(count, vmService);
      await _testFixedWeakListGetSet(count, vmService);
      await _testUnmodifiableWeakListGetSet(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakListGetSet(count, vmService);
      await _testFixedWeakListGetSet(count, vmService);
      await _testUnmodifiableWeakListGetSet(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakListGetSet(count, vmService);
      await _testFixedWeakListGetSet(count, vmService);
      await _testUnmodifiableWeakListGetSet(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakListGetSet(count, vmService);
      await _testFixedWeakListGetSet(count, vmService);
      await _testUnmodifiableWeakListGetSet(count, vmService);
    });
  });

  group('WeakList elements iterables', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakListIterable(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakListIterable(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakListIterable(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakListIterable(count, vmService);
    });
  });

  group('WeakList clear()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakListClear(count, vmService);
      await _testFixedWeakListClear(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakListClear(count, vmService);
      await _testFixedWeakListClear(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakListClear(count, vmService);
      await _testFixedWeakListClear(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakListClear(count, vmService);
      await _testFixedWeakListClear(count, vmService);
    });
  });

  group('WeakList add()', () {
    test('1 entry', () async {
      const count = 1;
      await _testFixedWeakListAdd(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListAdd(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testFixedWeakListAdd(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testFixedWeakListAdd(count, vmService);
    });
  });

  group('WeakList addAll()', () {
    test('1 entry', () async {
      const count = 1;
      await _testFixedWeakListAddAll(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListAddAll(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testFixedWeakListAddAll(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testFixedWeakListAddAll(count, vmService);
    });
  });

  group('WeakList insert()', () {
    test('1 entry', () async {
      const count = 1;
      await _testFixedWeakListInsert(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListInsert(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testFixedWeakListInsert(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testFixedWeakListInsert(count, vmService);
    });
  });

  group('WeakList insertAll()', () {
    test('1 entry', () async {
      const count = 1;
      await _testFixedWeakListInsertAll(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListInsertAll(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testFixedWeakListInsertAll(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testFixedWeakListInsertAll(count, vmService);
    });
  });

  group('WeakList remove()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakListRemove(count, vmService);
      await _testFixedWeakListRemove(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakListRemove(count, vmService);
      await _testFixedWeakListRemove(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakListRemove(count, vmService);
      await _testFixedWeakListRemove(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakListRemove(count, vmService);
      await _testFixedWeakListRemove(count, vmService);
    });
  });

  group('WeakList removeAt()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakListRemoveAt(count, vmService);
      await _testFixedWeakListRemoveAt(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakListRemoveAt(count, vmService);
      await _testFixedWeakListRemoveAt(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakListRemoveAt(count, vmService);
      await _testFixedWeakListRemoveAt(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakListRemoveAt(count, vmService);
      await _testFixedWeakListRemoveAt(count, vmService);
    });
  });

  group('WeakList length=', () {
    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListLength(count, vmService);
    });
  });

  group('WeakList removeLast()', () {
    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListRemoveLast(count, vmService);
    });
  });

  group('WeakList removeRange()', () {
    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListRemoveRange(count, vmService);
    });
  });

  group('WeakList replaceRange()', () {
    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListReplaceRange(count, vmService);
    });
  });

  group('WeakList removeWhere()', () {
    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListRemoveWhere(count, vmService);
    });
  });

  group('WeakList retainWhere()', () {
    test('17 entry', () async {
      const count = 17;
      await _testFixedWeakListRetainWhere(count, vmService);
    });
  });
}

Future<void> _testWeakListGetSet(int count, VmServiceUtil vmService) async {

  final weakList = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList.add(xGcKeys[j]);
  }

  // test operator []=
  expect(weakList, isNotEmpty, reason: '$weakList');
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    var x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
    // 20240322, Henri: important to nullify this variable(`x`) in test code
    // or it might stay referencing the target value and the last value kept
    // referenced and not GCed.
    x = null;
  }

  // null and wait for GC
  for (var j = 0; j < count; ++j) {
    xGcKeys[j] = null;
  }

  for (var j = 0; j < count; ++j) {
    expect(xGcKeys[j], isNull);
  }

  await vmService.gc();

  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNull);
  }
}

Future<void> _testFixedWeakListGetSet(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);
  weakList0 = null;

  // test operator []=
  expect(weakList, isNotEmpty, reason: '$weakList');
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    var x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
    // 20240322, Henri: important to nullify this variable(`x`) in test code
    // or it might stay referencing the target value and the last value kept
    // referenced and not GCed.
    x = null;
  }

  // null and wait for GC
  for (var j = 0; j < count; ++j) {
    xGcKeys[j] = null;
  }

  for (var j = 0; j < count; ++j) {
    expect(xGcKeys[j], isNull);
  }

  await vmService.gc();

  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNull);
  }
}

Future<void> _testUnmodifiableWeakListGetSet(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.unmodifiable(weakList0);
  weakList0 = null;

  // test operator []=
  expect(weakList, isNotEmpty, reason: '$weakList');
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    var x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
    // 20240322, Henri: important to nullify this variable(`x`) in test code
    // or it might stay referencing the target value and the last value kept
    // referenced and not GCed.
    x = null;
  }

  // null and wait for GC
  for (var j = 0; j < count; ++j) {
    xGcKeys[j] = null;
  }

  for (var j = 0; j < count; ++j) {
    expect(xGcKeys[j], isNull);
  }

  await vmService.gc();

  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNull);
  }

  for (var j = 0; j < count; ++j) {
    expect(() => weakList[j] = xGcKeys[j], throwsUnsupportedError);
  }
}

Future<void> _testWeakListIterable(int count, VmServiceUtil vmService) async {

  final weakList = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList.add(xGcKeys[j]);
  }

  // test elements iterable
  expect(weakList, orderedEquals(xKeys));

  // null even number and wait for GC
  for (var j = 0; j < count; j += 2) {
    xGcKeys[j] = null;
  }

  // request 2Mb memory to trigger GC
  // var dummy = List.filled(1024*1024*2, Y(10000));

  await vmService.gc();

  // even is null
  for (var j = 0; j < count; j += 2) {
    expect(weakList[j], isNull, reason: 'Seems not GCed. j: $j, weakList:${weakList.length}\n$weakList');
  }

  // odd exists
  for (var j = 1; j < count; j += 2) {
    expect(weakList[j], equals(xKeys[j]));
  }

  int j = 0;
  for (final x in weakList) {
    expect(x, equals(xGcKeys[j]), reason: 'j: $j');
    j += 1;
  }

}

Future<void> _testWeakListClear(int count, VmServiceUtil vmService) async {

  final weakList = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList.add(xGcKeys[j]);
  }

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  weakList.clear();

  // request 2Mb memory to trigger GC
  // var dummy = List.filled(1024*1024*2, Y(10000));
  await vmService.gc();
  // print('null xGcKeys and force GC');

  expect(weakList, isEmpty, reason: '${weakList.length}');
  expect(weakList.length, equals(0));
  for (var j = 0; j < count; ++j) {
    expect(() => weakList[j], throwsRangeError);
  }
}

Future<void> _testFixedWeakListClear(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.clear(), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.clear(), throwsUnsupportedError);

  }
}

Future<void> _testFixedWeakListAdd(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.add(X(1000)), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.add(X(1000)), throwsUnsupportedError);

  }
}

Future<void> _testWeakListRemove(int count, VmServiceUtil vmService) async {

  final weakList = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList.add(xGcKeys[j]);
  }

  // test keys iterable
  expect(weakList, orderedEquals(xKeys));

  // remove even X number
  for (var j = 0; j < count; j += 2) {
    weakList.remove(xKeys[j]);
  }

  weakList.validElementCount();

  expect(weakList.length, equals(count ~/2), reason: 'Seems not removed. weakList:${weakList.length}\n$weakList');

  // only odd element exists
  for (final x in weakList) {
    expect(x!.value.isOdd, isTrue);
  }
}

Future<void> _testFixedWeakListRemove(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test keys iterable
  expect(weakList, orderedEquals(xKeys));

  // remove even X number
  for (var j = 0; j < count; j += 2) {
    expect(() => weakList.remove(xKeys[j]), throwsUnsupportedError);
  }

  weakList.validElementCount();

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test keys iterable
    expect(weakList, orderedEquals(xKeys));

    // remove even X number
    for (var j = 0; j < count; j += 2) {
      expect(() => weakList.remove(xKeys[j]), throwsUnsupportedError);
    }

    weakList.validElementCount();

  }
}

Future<void> _testWeakListRemoveAt(int count, VmServiceUtil vmService) async {

  final weakList = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList.add(xGcKeys[j]);
  }

  // test keys iterable
  expect(weakList, orderedEquals(xKeys));

  // remove even X number
  for (var j = count - 1; j >= 0; j -= 2) {
    weakList.removeAt(j);
  }

  weakList.validElementCount();

  expect(weakList.length, equals(count ~/2), reason: 'Seems not removed. weakList:${weakList.length}\n$weakList');

  // only odd element exists
  for (final x in weakList) {
    expect(x!.value.isOdd, isTrue);
  }
}

Future<void> _testFixedWeakListRemoveAt(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test keys iterable
  expect(weakList, orderedEquals(xKeys));

  // remove even X number
  for (var j = count - 1; j >= 0; j -= 2) {
    expect(() => weakList.removeAt(j), throwsUnsupportedError);
  }

  weakList.validElementCount();

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test keys iterable
    expect(weakList, orderedEquals(xKeys));

    // remove even X number
    for (var j = count - 1; j >= 0; j -= 2) {
      expect(() => weakList.removeAt(j), throwsUnsupportedError);
    }

    weakList.validElementCount();

  }
}

Future<void> _testFixedWeakListAddAll(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.addAll(xKeys), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.addAll(xKeys), throwsUnsupportedError);

  }
}

Future<void> _testFixedWeakListInsert(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.insert(0, X(1000)), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.insert(0, X(1000)), throwsUnsupportedError);

  }
}

Future<void> _testFixedWeakListInsertAll(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.insertAll(0, xKeys), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.insertAll(0, xKeys), throwsUnsupportedError);

  }
}

Future<void> _testFixedWeakListLength(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.length = count - 1, throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.length = count - 1, throwsUnsupportedError);

  }
}

Future<void> _testFixedWeakListRemoveLast(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.removeLast(), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.removeLast(), throwsUnsupportedError);

  }
}

Future<void> _testFixedWeakListRemoveRange(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.removeRange(0, count), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.removeRange(0, count), throwsUnsupportedError);

  }
}

Future<void> _testFixedWeakListReplaceRange(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.replaceRange(0, count, xKeys), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.replaceRange(0, count, xKeys), throwsUnsupportedError);

  }
}

Future<void> _testFixedWeakListRemoveWhere(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  // clear
  expect(() => weakList.removeWhere((e) => e == X(1000)), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.removeWhere((e) => e == X(1000)), throwsUnsupportedError);

  }
}

Future<void> _testFixedWeakListRetainWhere(int count, VmServiceUtil vmService) async {

  List<X?>? weakList0 = WeakList<X>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
  }

  // populate WeakList
  for (var j = 0; j < count; ++j) {
    weakList0.add(xGcKeys[j]);
  }

  final weakList = WeakList.of(weakList0, growable: false);

  // test operator []=
  expect(weakList, isNotEmpty);
  expect(weakList.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    final x = weakList[j];
    expect(x, isNotNull);
    expect(x, equals(xKeys[j]));
  }

  expect(() => weakList.retainWhere((e) => e == X(1000)), throwsUnsupportedError);

  {
    final weakList = WeakList.unmodifiable(weakList0);
    weakList0 = null;

    // test operator []=
    expect(weakList, isNotEmpty);
    expect(weakList.length, equals(count));

    // test operator []
    for (var j = 0; j < count; ++j) {
      final x = weakList[j];
      expect(x, isNotNull);
      expect(x, equals(xKeys[j]));
    }

    // clear
    expect(() => weakList.retainWhere((e) => e == X(1000)),
        throwsUnsupportedError);
  }
}
