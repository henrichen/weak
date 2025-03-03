// https://github.com/henrichen/weak
// weak_hash_set_gc_test.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
library;

import 'dart:async';

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

  group('WeakHashSet add(), contains(), lookup()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakHashSetAddContains(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakHashSetAddContains(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakHashSetAddContains(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakHashSetAddContains(count, vmService);
    });
  });

  group('WeakHashSet iterables', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakHashSetIterable(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakHashSetIterable(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakHashSetIterable(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakHashSetIterable(count, vmService);
    });
  });

  group('WeakHashMap clear()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakSetClear(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakSetClear(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakSetClear(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakSetClear(count, vmService);
    });
  });

  group('WeakHashMap remove()', () {
    test('1 entry', () async {
      const count = 1;
      await _testWeakSetRemove(count, vmService);
    });

    test('17 entry', () async {
      const count = 17;
      await _testWeakSetRemove(count, vmService);
    });

    test('33 entry', () async {
      const count = 33;
      await _testWeakSetRemove(count, vmService);
    });

    test('65 entry', () async {
      const count = 65;
      await _testWeakSetRemove(count, vmService);
    });
  });
}

FutureOr _testWeakHashSetAddContains(int count, VmServiceUtil vmService) async {
  print('add(), lookup(), contains(): test $count entries');

  final weakSet = WeakHashSet<X>();
  final gcValues = <X?>[];
  final values = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    gcValues.add(X(j));
    values.add(X(j));
  }

  // populate WeakSet
  for (var j = 0; j < count; ++j) {
    weakSet.add(gcValues[j]!);
  }

  // test operator add()
  expect(weakSet, isNotEmpty);
  expect(weakSet.length, equals(count));

  // test contains(), lookup()
  for (var j = 0; j < count; ++j) {
    expect(weakSet.contains(values[j]), isTrue);
    var y = weakSet.lookup(values[j]);
    expect(y, isNotNull);
    expect(y, equals(gcValues[j]));
    expect(identical(y, gcValues[j]), isTrue);
    // 20240318, Henri: important to nullify this variable(`y`) in test code
    // or it might stay referencing the target value and the last value kept
    // referenced and not GCed.
    y = null;
  }

  var xExtra = X(count);
  expect(weakSet.contains(xExtra), isFalse);
  expect(weakSet.lookup(xExtra), isNull);

  // null and wait for GC
  for (var j = 0; j < count; ++j) {
    gcValues[j] = null;
  }
  for (var j = 0; j < count; ++j) {
    expect(gcValues[j], isNull);
  }
  // request 1Mb memory to trigger GC
  // var dummy = List.filled(1024*1024, Y(10000));
  await vmService.gc();
  expect(weakSet, isEmpty,
      reason: 'Seems not fully GCed. ${weakSet.length}\n$weakSet');
}

FutureOr _testWeakSetClear(int count, VmServiceUtil vmService) async {
  print('clear(): test $count entries');

  final weakSet = WeakHashSet<X>();
  final gcValues = <X?>[];
  final values = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    gcValues.add(X(j));
    values.add(X(j));
  }

  // populate WeakSet
  for (var j = 0; j < count; ++j) {
    weakSet.add(gcValues[j]!);
  }

  // test operator add()
  expect(weakSet, isNotEmpty);
  expect(weakSet.length, equals(count));

  // test contains(), lookup()
  for (var j = 0; j < count; ++j) {
    expect(weakSet.contains(values[j]), isTrue);
    var y = weakSet.lookup(values[j]);
    expect(y, isNotNull);
    expect(y, equals(gcValues[j]));
    expect(identical(y, gcValues[j]), isTrue);
    // 20240318, Henri: important to nullify this variable(`y`) in test code
    // or it might stay referencing the target value and the last value kept
    // referenced and not GCed.
    y = null;
  }

  var xExtra = X(count);
  expect(weakSet.contains(xExtra), isFalse);
  expect(weakSet.lookup(xExtra), isNull);

  // clear
  weakSet.clear();

  // request 1Mb memory to trigger GC
  // var dummy = List.filled(1024*1024, Y(10000));
  await vmService.gc();
  expect(weakSet, isEmpty,
      reason: 'Seems not fully GCed. ${weakSet.length}\n$weakSet');
}

FutureOr _testWeakHashSetIterable(int count, VmServiceUtil vmService) async {
  print('iterator: test $count entries');

  final weakSet = WeakHashSet<X>();
  final gcValues = <X?>[];
  final values = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    gcValues.add(X(j));
    values.add(X(j));
  }

  // populate WeakHashSet
  for (var j = 0; j < count; ++j) {
    weakSet.add(gcValues[j]!);
  }

  // test values iterable
  expect(weakSet, unorderedEquals(values));

  // null even number and wait for GC
  for (var j = 0; j < count; j += 2) {
    gcValues[j] = null;
  }

  // request 1Mb memory to trigger GC
  // var dummy = List.filled(1024*1024, Y(10000));
  await vmService.gc();
  // print('null even gcValues and force GC');

  // even is null
  if (weakSet.length == count ~/ 2) {
    for (var j = 0; j < count; j += 2) {
      expect(weakSet.lookup(values[j]), isNull,
          reason: 'Seems not GCed. weakSet:${weakSet.length}\n$weakSet');
    }

    // odd exists
    int len = 0;
    for (var j = 1; j < count; j += 2) {
      expect(weakSet.lookup(values[j]), equals(values[j]));
      expect(identical(weakSet.lookup(values[j]), gcValues[j]), isTrue);
      len += 1;
    }
    expect(len, equals(weakSet.length), reason: 'Seems not GCed. $weakSet');
  }
}

FutureOr _testWeakSetRemove(int count, VmServiceUtil vmService) async {
  print('remove() even: test $count entries');

  final weakSet = WeakHashSet<X>();
  final gcValues = <X?>[];
  final values = <X>[];

  // initial
  for (var j = 0; j < count; ++j) {
    gcValues.add(X(j));
    values.add(X(j));
  }

  // populate WeakHashSet
  for (var j = 0; j < count; ++j) {
    weakSet.add(gcValues[j]!);
  }

  // test values iterable
  expect(weakSet, unorderedEquals(values));

  // remove even number and wait for GC
  for (var j = 0; j < count; j += 2) {
    weakSet.remove(values[j]);
  }

  // request 1Mb memory to trigger GC
  // var dummy = List.filled(1024*1024, Y(10000));
  await vmService.gc();
  // print('null even gcValues and force GC');

  // even is null
  if (weakSet.length == count ~/ 2) {
    for (var j = 0; j < count; j += 2) {
      expect(weakSet.lookup(values[j]), isNull,
          reason: 'Seems not GCed. weakSet:${weakSet.length}\n$weakSet');
    }

    // odd exists
    int len = 0;
    for (var j = 1; j < count; j += 2) {
      expect(weakSet.lookup(values[j]), equals(values[j]));
      expect(identical(weakSet.lookup(values[j]), gcValues[j]), isTrue);
      len += 1;
    }
    expect(len, equals(weakSet.length), reason: 'Seems not GCed. $weakSet');
  }
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
