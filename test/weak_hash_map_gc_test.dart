// https://github.com/henrichen/weak
// weak_hash_map_gc_test.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
library weak_hash_map_gc_test;

import 'package:weak/weak.dart';
import 'package:test/test.dart';
import 'gc_util.dart';

/// IMPORTANT: set VM options
///
/// `--enable-vm-service`
///
/// so we can force GC.
void main() async {
  final vmService = await VmServiceUtil.create();

  group('WeakHashMap []=, [] operators, and containsKey()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakMapGetSet(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakMapGetSet(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakMapGetSet(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakMapGetSet(count, vmService);
    });
  });

  group('WeakHashMap keys, values iterables', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakMapIterable(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakMapIterable(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakMapIterable(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakMapIterable(count, vmService);
    });
  });

  group('WeakHashMap clear()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakMapClear(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakMapClear(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakMapClear(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakMapClear(count, vmService);
    });
  });

  group('WeakHashMap remove()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakMapRemove(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakMapRemove(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakMapRemove(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakMapRemove(count, vmService);
    });
  });
}

Future<void> _testWeakMapGetSet(int count, VmServiceUtil vmService) async {
  print('[]=, [], containsKey(): test $count entries');

  final weakMap = WeakHashMap<X, Y>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];
  final yValues = <Y>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
    yValues.add(Y(j));
  }

  // populate WeakHashMap
  for (var j = 0; j < count; ++j) {
    weakMap[xGcKeys[j]!] = yValues[j];
  }

  // test operator []=
  expect(weakMap, isNotEmpty);
  expect(weakMap.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    expect(weakMap.containsKey(xKeys[j]), isTrue);
    expect(weakMap.containsKey(xGcKeys[j]), isTrue);
    final y = weakMap[xKeys[j]];
    expect(y, isNotNull);
    expect(y, equals(yValues[j]));
  }

  var xExtra = X(count);
  expect(weakMap[xExtra], isNull);

  // null and wait for GC
  for (var j = 0; j < count; ++j) {
    xGcKeys[j] = null;
  }

  // request 2Mb memory to trigger GC
  // var dummy = List.filled(1024*1024*2, Y(10000));
  await vmService.gc();
  // print('null xGcKeys and force GC');

  expect(weakMap, isEmpty, reason: '${weakMap.length}');
  expect(weakMap.length, equals(0));
  for (var j = 0; j < count; ++j) {
    final y = weakMap[xKeys[j]];
    expect(y, isNull);
  }
}

Future<void> _testWeakMapIterable(int count, VmServiceUtil vmService) async {
  print('Iterator: test $count entries');

  final weakMap = WeakHashMap<X, Y>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];
  final yValues = <Y>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
    yValues.add(Y(j));
  }

  // populate WeakHashMap
  for (var j = 0; j < count; ++j) {
    weakMap[xGcKeys[j]!] = yValues[j];
  }

  // test values iterable
  expect(weakMap.values, unorderedEquals(yValues));

  // test keys iterable
  expect(weakMap.keys, unorderedEquals(xKeys));

  // null even number and wait for GC
  for (var j = 0; j < count; j += 2) {
    xGcKeys[j] = null;
  }

  // request 2Mb memory to trigger GC
  // var dummy = List.filled(1024*1024*2, Y(10000));

  await vmService.gc();
  // print('null even xGcKeys and force GC');

  // even is null
  for (var j = 0; j < count; j += 2) {
    expect(weakMap[xKeys[j]], isNull,
        reason: 'Seems not GCed. weakMap:${weakMap.length}\n$weakMap');
  }

  // odd exists
  for (var j = 1; j < count; j += 2) {
    expect(weakMap[xKeys[j]], equals(yValues[j]));
  }
}

Future<void> _testWeakMapClear(int count, VmServiceUtil vmService) async {
  print('clear(): test $count entries');

  final weakMap = WeakHashMap<X, Y>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];
  final yValues = <Y>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
    yValues.add(Y(j));
  }

  // populate WeakHashMap
  for (var j = 0; j < count; ++j) {
    weakMap[xGcKeys[j]!] = yValues[j];
  }

  // test operator []=
  expect(weakMap, isNotEmpty);
  expect(weakMap.length, equals(count));

  // test operator []
  for (var j = 0; j < count; ++j) {
    expect(weakMap.containsKey(xKeys[j]), isTrue);
    expect(weakMap.containsKey(xGcKeys[j]), isTrue);
    final y = weakMap[xKeys[j]];
    expect(y, isNotNull);
    expect(y, equals(yValues[j]));
  }

  var xExtra = X(count);
  expect(weakMap[xExtra], isNull);

  // clear
  weakMap.clear();

  // request 2Mb memory to trigger GC
  // var dummy = List.filled(1024*1024*2, Y(10000));
  await vmService.gc();
  // print('null xGcKeys and force GC');

  expect(weakMap, isEmpty, reason: '${weakMap.length}');
  expect(weakMap.length, equals(0));
  for (var j = 0; j < count; ++j) {
    final y = weakMap[xKeys[j]];
    expect(y, isNull);
  }
}

Future<void> _testWeakMapRemove(int count, VmServiceUtil vmService) async {
  print('Remove even: test $count entries');

  final weakMap = WeakHashMap<X, Y>();
  final xGcKeys = <X?>[];
  final xKeys = <X>[];
  final yValues = <Y>[];

  // initial
  for (var j = 0; j < count; ++j) {
    xGcKeys.add(X(j));
    xKeys.add(X(j));
    yValues.add(Y(j));
  }

  // populate WeakHashMap
  for (var j = 0; j < count; ++j) {
    weakMap[xGcKeys[j]!] = yValues[j];
  }

  // test values iterable
  expect(weakMap.values, unorderedEquals(yValues));

  // test keys iterable
  expect(weakMap.keys, unorderedEquals(xKeys));

  // remove even number and wait for GC
  for (var j = 0; j < count; j += 2) {
    weakMap.remove(xKeys[j]);
  }

  // request 2Mb memory to trigger GC
  // var dummy = List.filled(1024*1024*2, Y(10000));

  await vmService.gc();
  // print('null even xGcKeys and force GC');

  // even is null because it is removed from the map but xGcKeys still hold X.
  for (var j = 0; j < count; j += 2) {
    expect(weakMap[xKeys[j]], isNull,
        reason: 'Seems not removed. weakMap:${weakMap.length}\n$weakMap');
  }

  // odd exists
  for (var j = 1; j < count; j += 2) {
    expect(weakMap[xKeys[j]], equals(yValues[j]));
  }
}
