// https://github.com/henrichen/weak
// weak_list.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.

import 'dart:collection';
import 'dart:math' show min, max;
import 'utils.dart';

/// An ordered [List] implementation with weak referenced elements. An element
/// in this weak list will be automatically nullified when it is garbage
/// collected. That is, when there is no other way for the program to access
/// the weak referenced element, it is likely nullified from this [WeakList]
/// anytime. That is, the (List.[]) operator may return null if the element at
/// the specified index is garbage collected.
///
/// Note that the element object of type [E] must be a type that can be
/// applied into [WeakReference] target. i.e. [E] must NOT be numbers, strings,
/// booleans, records, null, dart:ffi pointers, dart:ffi structs, or
/// dart:ffi unions.
///
/// Besides the weak referenced elements, the attributes of this [WeakList]
/// is the same to regular [List].
class WeakList<E extends Object> with ListMixin<E?> {
  /// For performance reason, we don't scan the whole list and purge GCed
  /// elements immediately. Instead, only the GCed elements exceeds the
  /// specified threshold of all valid elements that we do a scan purge.
  static final double _gcThreshold = 0.5;

  /// Management of GCed elements
  late final Finalizer<_Token<E>> _finalizer;

  /// count of element GCed
  int _gcCount;

  /// count of really weak referenced elements
  int _elmCount;

  List<_Seg<E>> _segList;

  int _length;

  bool _growable;

  bool _unmodifiable;

  WeakList()
      : _length = 0, _segList = <_Seg<E>>[], _gcCount = 0, _elmCount = 0, _growable = true, _unmodifiable = false {
    _finalizer = Finalizer((token) => this._gcCount += 1);
  }

  /// Create a new empty WeakList.
  factory WeakList.empty({bool growable = false}) =>
      WeakList<E>().._segList = List<_Seg<E>>.empty(growable: growable).._growable = growable;

  /// Create a WeakList of the given [length] with [fill] at each position.
  factory WeakList.filled(int length, E? fill, {bool growable = false}) {
    RangeError.checkNotNegative(length, "length");
    if (length == 0) return WeakList<E>.empty(growable: growable);
    if (fill == null) {
      return WeakList<E>().._length = length.._growable = growable;
    }

    final wref = WeakReference(fill);
    final seg = _Seg<E>(0, elements: List<WeakReference<E>>.filled(length, wref, growable: true));
    return WeakList<E>._fromSegs([seg], length).._growable = growable;
  }

  /// Create a WeakList from [elements] in its iteration order. Note all
  /// [elements] must be type of [E] or null.
  factory WeakList.from(Iterable elements, {bool growable = true}) {
    final segList = <_Seg<E>>[];
    int index = 0;
    _Seg<E>? seg;
    for (E? elm in elements) {
      if (elm != null) {
        seg ??= _Seg(index);
        seg.add(WeakReference(elm));
      } else if (seg != null) {
        segList.add(seg);
        seg = null;
      }
      ++index;
    }
    if (seg != null) {
      segList.add(seg);
    }
    return WeakList<E>._fromSegs(segList, index).._growable = growable;
  }

  /// Create a WeakList from [elements] in its iteration order.
  factory WeakList.of(Iterable<E?> elements, {bool growable = true}) =>
      WeakList<E>.from(elements, growable: growable);

  /// Generates a list of values.
  /// Create a WeakList with [length] positions and fills it with values created
  /// by calling [generator] for each index in the range `0` .. `length - 1`
  /// in increasing order.
  factory WeakList.generate(int length, E? Function(int index) generator, {bool growable = true}) {
    RangeError.checkNotNegative(length, "length");
    return WeakList<E>.of(
        _indexesGeneratorIterable(length, generator), growable: growable);
  }

  /// Creates an unmodifiable WeakList containing all [elements] in its
  /// iteration order.
  ///
  /// An unmodifiable list cannot have its length or elements changed except
  /// the element is garbage collected.
  factory WeakList.unmodifiable(Iterable elements) =>
      WeakList<E>.from(elements, growable: false).._unmodifiable = true;

  factory WeakList._fromSegs(List<_Seg<E>> segList, int len) {
    RangeError.checkNotNegative(len, "len");
    assert(segList.isEmpty || segList.last.end <= len, 'segList.end(${segList.last.end} should less than or equal to len($len)');
    final wlist = WeakList<E>().._segList = segList.._length = len;
    for (final seg in wlist._segList) {
      for (final weakRef in seg._elements) {
        wlist._finalizer.attach(weakRef.target!, _Token());
      }
      wlist._elmCount += seg.length;
    }
    return wlist;
  }
  
  @override
  int get length {
    _tryPurgeGcElements();
    return _length;
  }

  @override
  set length(int len) {
    _checkUnmodifiableAndFixLength();

    RangeError.checkNotNegative(len, "len");
    if (len == 0) {
      // special case, zero length
      clear();
      return;
    }

    if (_segList.isNotEmpty && len < _segList.first.start) {
      // special case, before first element
      clear();
      _length = len;
      return;
    }

    if (_length < len || _segList.isEmpty || _segList.last.end <= len) {
      // special case, after last
      _length = len;
      return;
    }

    _tryPurgeGcElements();

    final (j, seg) = _getSeg(len);

    var j0 = j;
    if (seg != null) {
      if (seg.start < len) {
        // case b
        final idx0 = len - seg.start;
        final elements = seg._elements;
        _elmCount -= elements.length - idx0;
        elements.removeRange(idx0, elements.length);
        j0 += 1;
      }
    } else {
      // case c
      j0 += 1;
    }

    // case c or case a: detach and remove all after(inclusive) j0
    int removeCount = 0;
    for (var k = _segList.length; --k >= j0;) {
      final seg = _segList[k];
      removeCount += seg.length;
    }
    _segList.removeRange(j0, _segList.length);
    _length = len;
    _elmCount -= removeCount;
  }

  @override
  void clear() {
    _checkUnmodifiableAndFixLength();

    _length = 0; // purge GCed
    _segList = <_Seg<E>>[];
    _elmCount = 0;
    _gcCount = 0;
  }

  @override
  Iterator<E?> get iterator {
    _tryPurgeGcElements();

    return _weakListIterable<E>(this).iterator;
  }

  @override
  void add(E? element) {
    _checkUnmodifiableAndFixLength();

    final index = length; // purge GCed
    _length = _length + 1;

    if (element != null) {
      _assignValue(index, element);
    }
  }

  @override
  void addAll(Iterable<E?> iterable) {
    _checkUnmodifiableAndFixLength();
    if (iterable.isEmpty) return;
    var index = length; // purge GCed
    _Seg<E>? preSeg = _segList.isNotEmpty && _segList.last.end == index
        ? _segList.last : null;
    final len = _length;
    for (final e in iterable) {
      if (this._length != len) throw ConcurrentModificationError(this);
      if (e != null) {
        if (preSeg == null) {
          preSeg = _Seg<E>(index);
          _segList.add(preSeg);
        }
        final weakRef = WeakReference(e);
        _finalizer.attach(e, _Token());
        preSeg.add(weakRef);
        _elmCount += 1;
      } else {
        preSeg = null;
      }
      index += 1;
    }
    _length = index;
  }

  @override
  void insert(int index, E? element) {
    _checkUnmodifiableAndFixLength();

    final len = this.length; // purge GCed
    RangeError.checkValueInInterval(index, 0, len, "index");
    if (len == index) {
      add(element);
      return; // done
    }
    var (j, seg) = _getSeg(index);
    if (element == null) {
      _insertNull(j, seg, index);
    } else {
      _insertValue(j, seg, index, element);
    }
  }
  
  @override
  void insertAll(int index, Iterable<E?> iterable) {
    _checkUnmodifiableAndFixLength();
    if (iterable.isEmpty) return;

    final len = this.length; // purge GCed
    RangeError.checkValueInInterval(index, 0, len, "index");
    if (iterable.isEmpty) {
      return; // done; nothing to insert
    }
    if (index == len) {
      addAll(iterable);
      return; // done
    }
    final (j, seg) = _getSeg(index);
    final (k, offset) = _insertIterable(j, seg, index, iterable);
    _shift(k, offset);
  }

  @override
  int lastIndexOf(Object? element, [int? start]) =>
      element == null
          ? lastIndexWhere(_testNull, start)
          : lastIndexWhere((E? elm) => element == elm, start);

  @override
  int lastIndexWhere(bool Function(E? element) test, [int? start]) {
    final len = this.length; // purge GCed
    if (start == null || start >= len) start = len - 1;
    if (start < 0) return -1;

    final matchNull = test(null);
    var (j, seg) = _getSeg(start);
    if (matchNull && seg == null) return start;
    if (seg != null) {
      for (int m = start - seg.start; m >= 0; --m) {
        if (test(seg._elements[m].target)) return m + seg.start;
        if (len != this._length) {
          throw ConcurrentModificationError(this);
        }
      }
      if (matchNull) {
        return seg.start > 0 ? seg.start - 1 : -1;
      }
    } else {
      j += 1;
    }

    while (--j >= 0) {
      final seg0 = _segList[j];
      for (int m = seg0.length; --m >= 0;) {
        if (test(seg0._elements[m].target)) return m + seg0.start;
        if (len != this._length) {
          throw ConcurrentModificationError(this);
        }
      }
    }
    return -1;
  }

  @override
  E? removeAt(int index) {
    _checkUnmodifiableAndFixLength();

    final len = length - 1; // purge GCed
    RangeError.checkValueInInterval(index, 0, len, "index");
    final (j, seg) = _getSeg(index);
    if (seg == null) {
      // case c
      _shift(j + 1, -1);
      return null;
    }

    // case a or b
    final elements = seg._elements;
    final idx0 = index - seg.start;
    final elm = elements.removeAt(idx0);
    _elmCount -= 1;
    _shift(j + 1, -1);
    if (elements.isEmpty) {
      // All elements in seg is removed; remove the segment
      _segList.removeAt(j);
    }
    return elm.target;
  }

  @override
  E? removeLast() {
    _checkUnmodifiableAndFixLength();

    if (length == 0) { // purge GCed
      throw IterableElementError.noElement();
    }

    if (_segList.isEmpty) {
      _length -= 1;
      return null;
    }

    final seg = _segList.last;
    if (seg.end < _length) {
      _length -= 1;
      return null;
    }
    final elements = seg._elements;
    final elmWeakRef = elements.removeLast();
    _elmCount -= 1;
    final elm = elmWeakRef.target;
    if (elements.isEmpty) {
      // all elements removed in the segment; remove the segment
      _segList.removeLast();
    }
    _length -= 1;
    return elm;
  }

  @override
  bool remove(Object? element) {
    _checkUnmodifiableAndFixLength();

    if (length == 0) return false; // purge GCed

    if (element == null) {
      if (_segList.isEmpty) {
        _length -= 1;
        return true;
      }
      // remove the first null element
      final seg = _segList.first;
      if (seg.start > 0) {
        // before first
        _shift(0, -1);
        return true;
      } else if (seg.end < _length) {
        // after first
        _shift(1, -1);
        return true;
      }
      return false;
    }

    // element != null
    final len = _segList.length;
    for (int j = 0; j < len; ++j) {
      int k = 0;
      final seg0 = _segList[j];
      final elements = seg0._elements;
      for (final elm in elements) {
        if (elm.target == element) {
          // found
          elements.removeAt(k);
          _elmCount -= 1;
          if (elements.isEmpty) {
            // total removed; remove this segment
            _segList.removeAt(j);
          }
          _shift(j + 1, -1);
          return true;
        }
        k += 1;
      }
    }

    return false;
  }

  @override
  void removeRange(int start, int end) {
    _checkUnmodifiableAndFixLength();

    final len = this.length; // purge GCed
    RangeError.checkValidRange(start, end, len);
    if (start == end) return;

    var (sj, sseg) = _getSeg(start);
    var (ej, eseg) = _getSeg(end);
    final offset = start - end; // negative offset
    if (sseg != null && identical(sseg, eseg)) {
      // on the same segment; remove range of the segment (no way of total remove)
      sseg.removeRange(start, end);
      _elmCount -= end - start;
      _shift(sj + 1, offset);
      return; // done
    }
    // not on the same segment
    if (sseg != null) {
      // cut tail of sseg
      final cutCount = sseg.end - start;
      final (headSeg1, _) = sseg._cut(start, sseg.end);
      if (headSeg1 != null) {
        // not total cut
        _elmCount -= cutCount;
        sj += 1;
      } else {
        // total cut
        sseg = null;
      }
    } else {
      sj += 1;
    }
    if (eseg != null) {
      // cut head of eseg (no way of total cut)
      _elmCount -= end - eseg.start;
      eseg._cut(eseg.start, end);
      if (sj > 0) {
        // check if merge eseg to sseg
        if (sseg != null) {
          sseg.mergeSeg(eseg);
          _segList.removeAt(ej);
        }
      }
    } else {
      ej += 1;
    }
    _removeCountInSegs(sj, ej);
    _segList.removeRange(sj, ej);
    _shift(sj, offset);
  }

  @override
  E? get first {
    if (length == 0) { // purge GCed
      throw IterableElementError.noElement();
    }
    return _segList.isNotEmpty ? _segList.first.at(0) : null;
  }

  @override
  E? get last {
    if (length == 0) { // purge GCed
      throw IterableElementError.noElement();
    }
    return _segList.isNotEmpty ? _segList.last.at(_length - 1) : null;
  }

  @override
  E? operator [](int index) {
    RangeError.checkValueInInterval(index, 0, length - 1, "index");

    _tryPurgeGcElements();

    return _getSeg(index).$2?.at(index);
  }

  @override
  void operator []=(int index, E? value) {
    _checkUnmodifiable();

    final len = length - 1; // purge GCed
    RangeError.checkValueInInterval(index, 0, len, "index");

    if (value == null) {
      final (j, seg) = _getSeg(index);
      if (seg == null) return;
      _elmCount -= 1;
      final (_, tailSeg) = seg._cut(index, index + 1);
      if (tailSeg != null) {
        _segList.insert(j + 1, tailSeg);
      }
    } else {
      _assignValue(index, value);
    }
  }

  @override
  Iterable<E?> get reversed {
    _tryPurgeGcElements();

    return _weakListReversedIterable<E>(this);
  }

  @override
  E? get single {
    if (length == 0) throw IterableElementError.noElement(); // purge GCed
    if (_length > 1) throw IterableElementError.tooMany();
    return _segList.isEmpty ? null : _segList.first.at(0);
  }

  @override
  bool any(bool Function(E? element) test) {
    final len = this.length; // purge GCed
    if (test(null) && _hasNull) return true;
    for (final elm in _weakListNonNullIterable(this)) {
      if (test(elm)) return true;
      if (len != this._length) {
        throw ConcurrentModificationError(this);
      }
    }
    return false;
  }
  
  @override
  Map<int, E?> asMap() {
    _tryPurgeGcElements();
    return _WeakListMapView(this);
  }

  @override
  bool every(bool Function(E? element) test) {
    final len = this.length; // purge GCed
    if (test(null)) {
      if (_segList.isEmpty) return true;
    } else if (_hasNull) {
      return false;
    }
    for (final elm in _weakListNonNullIterable(this)) {
      if (!test(elm)) return false;
      if (len != this._length) {
        throw ConcurrentModificationError(this);
      }
    }
    return true;
  }

  @override
  void fillRange(int start, int end, [E? fill]) {
    _checkUnmodifiable();

    final len = this.length; // purge GCed
    RangeError.checkValidRange(start, end, len);
    if (start == end) return;

    var (sj, sseg) = _getSeg(start);
    var (ej, eseg) = _getSeg(end);

    if (fill == null) {
      _fillNull(start, end, sj, sseg, ej, eseg);
    } else {
      _fillValue(start, end, sj, sseg, ej, eseg, fill);
    }
  }

  @override
  E? firstWhere(bool Function(E? element) test, {E? Function()? orElse}) {
    final len = this.length; // purge GCed
    final iterable = test(null)
        ? this as Iterable<E?> : _weakListNonNullIterable(this);
    for (final elm in iterable) {
      if (test(elm)) return elm;
      if (len != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  E? lastWhere(bool Function(E? element) test, {E? Function()? orElse}) {
    _tryPurgeGcElements();
    final iterable = test(null)
        ? this.reversed : _weakListNonNullReversedIterable(this);
    for (final elm in iterable) {
      if (test(elm)) return elm;
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Iterable<T> map<T>(T Function(E? element) f) =>
      _weakListMapIterable<E, T>(this, f);

  @override
  void forEach(void Function(E? element) action) {
    final len = this.length; // purge GCed
    for (final elm in this) {
      action(elm);
      if (len != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
  }

  @override
  Iterable<E?> getRange(int start, int end) {
    RangeError.checkValidRange(start, end, this.length);
    return _weakListRangeIterable<E>(this, start, end);
  }

  @override
  E? reduce(E? Function(E? previousValue, E? element) combine) {
    final len = this.length; // purge GCed
    if (len == 0) throw IterableElementError.noElement();
    final it = iterator;
    it.moveNext();
    var value = it.current;
    while (it.moveNext()) {
      value = combine(value, it.current);
      if (len != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    return value;
  }

  @override
  void removeWhere(bool Function(E? element) test) => _filter(test, false);

  @override
  void retainWhere(bool Function(E? element) test) => _filter(test, true);

  @override
  void replaceRange(int start, int end, Iterable<E?> newContents) {
    _checkUnmodifiableAndFixLength();

    final len = this.length; // purge GCed
    RangeError.checkValidRange(start, end, len);
    if (start == len) {
      addAll(newContents);
      return; // done
    }
    if (start == end) {
      insertAll(start, newContents);
      return; // done
    }
    if (newContents.isEmpty) {
      removeRange(start, end);
      return; // done
    }

    final (j, seg) = _getSeg(start);
    final (k, offset) = _insertIterable(j, seg, start, newContents, mergeEnd: false);
    var (ej, eseg) = _getSeg(end, k); // search from index k
    final offset0 = offset + start - end;
    if (eseg != null) {
      _elmCount -= end - eseg.start;
      eseg.removeRange(eseg.start, end);
      eseg.start = end;
      // check if preSeg.end adjacent to eseg.start
      if (k > 0 && _segList[k - 1].end == start + offset) {
        _segList[k - 1].addAll(eseg._elements);
        _elmCount += eseg.length;
        ej += 1;
      }
    } else {
      ej += 1;
    }
    _removeCountInSegs(k, ej);
    _segList.removeRange(k, ej);
    _shift(k, offset0);
  }

  @override
  void setAll(int index, Iterable<E?> iterable) {
    _checkUnmodifiable();

    final len = this.length; // purge GCed
    RangeError.checkValueInInterval(index, 0, len - 1, "index");
    final (j, seg) = _getSeg(index);
    final (k, offset) = _insertIterable(j, seg, index, iterable,
        mergeEnd: false,
        validInsert: (int idx) {
          if (idx >= len) throw IterableElementError.tooMany();
        });
    final end = index + offset;
    var (ej, eseg) = _getSeg(end, k); // search from index k
    if (eseg != null) {
      _elmCount -= end - eseg.start;
      eseg.removeRange(eseg.start, end);
      eseg.start = end;
      // check if preSeg.end adjacent to eseg.start after remove
      if (k > 0 && _segList[k - 1].end == end) {
        _segList[k - 1].addAll(eseg._elements);
        _elmCount += eseg._elements.length;
        ej += 1;
      }
    } else {
      ej += 1;
    }
    _removeCountInSegs(k, ej);
    _segList.removeRange(k, ej);
  }

  @override
  void setRange(int start, int end, Iterable<E?> iterable, [int skipCount = 0]) {
    _checkUnmodifiable();

    final len = this.length; // purge GCed
    RangeError.checkValidRange(start, end, len);
    final len0 = end - start;
    if (len0 == 0) return;
    RangeError.checkNotNegative(skipCount, "skipCount");

    List<E?> list;
    int sj;
    if (iterable is List<E?>) {
      list = iterable;
      sj = skipCount;
    } else {
      list = iterable.skip(skipCount).toList(growable: false);
      sj = 0;
    }
    if (sj + len0 > list.length) {
      throw IterableElementError.tooFew();
    }

    replaceRange(start, end, list);
  }

  @override
  E? singleWhere(bool Function(E? element) test, {E? Function()? orElse}) {
    _tryPurgeGcElements();
    if (test(null)) {
      // special case
      if (_segList.length >= 3) throw IterableElementError.tooMany();
      if (_segList.length == 2
          && (_segList.first.start > 0 || _segList.last.end < _length)) {
        throw IterableElementError.tooMany();
      }
      if (_segList.length == 1
          && _segList.first.start > 0 && _segList.last.end < _length) {
        throw IterableElementError.tooMany();
      }
      if (_segList.isEmpty && _length >= 2) {
        throw IterableElementError.tooMany();
      }
    }
    E? elm0;
    bool matchOnce = false;
    final iterable = test(null)
        ? this as Iterable<E?> : _weakListNonNullIterable(this);
    for (final elm in iterable) {
      if (test(elm)) {
        if (matchOnce) throw IterableElementError.tooMany();
        matchOnce = true;
        elm0 = elm;
      }
    }
    if (matchOnce) return elm0;
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E? element) combine) {
    var value = initialValue;
    final len = this.length; // purge GCed
    for (final elm in this) {
      value = combine(value, elm);
      if (len != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    return value;
  }

  @override
  Iterable<E?> followedBy(Iterable<E?> other) {
    _tryPurgeGcElements();
    return _weakListFollowedByIterable<E>(this, other);
  }

  @override
  int indexOf(Object? element, [int start = 0]) =>
      element == null
          ? indexWhere(_testNull, start)
          : indexWhere((E? elm) => elm == element, start);

  @override
  int indexWhere(bool Function(E? element) test, [int start = 0]) {
    final len = this.length; // purge GCed
    if (start < 0) start = 0;
    if (start >= len) return -1;
    final matchNull = test(null);
    final (j, seg) = _getSeg(start);
    if (matchNull) {
      if (seg == null) return start;
    }
    if (seg != null) {
      for (int m = start - seg.start; m < seg.length; ++m) {
        if (test(seg._elements[m].target)) return m + seg.start;
        if (len != this._length) {
          throw ConcurrentModificationError(this);
        }
      }
      if (matchNull) {
        return seg.end == len ? -1 : seg.end;
      }
    }
    for (int k = j + 1; k < _segList.length; ++k) {
      final seg0 = _segList[k];
      for (int m = 0; m < seg0.length; ++m) {
        if (test(seg0._elements[m].target)) return m + seg0.start;
        if (len != this._length) {
          throw ConcurrentModificationError(this);
        }
      }
    }
    return -1;
  }

  @override
  Iterable<E?> skip(int count) =>
      _weakListRangeIterable(this, count, _length);

  @override
  Iterable<E?> skipWhile(bool Function(E? elm) test) =>
      test(null)
          ? _weakListSkipWhileNullIterable(this, test)
          : super.skipWhile(test);

  /// Default comparison would deem null element as largest, i.e. null would be
  /// at the end of this List. If you want to change this default
  /// behaviour, must provide a new [compare] function.
  @override
  void sort([int Function(E? a, E? b)? compare]) {
    _checkUnmodifiable();

    _compactElements();
    final len = length; // purge GCed
    if (len == 0 || _segList.isEmpty) return; // nothing to do

    final compare0 = compare ?? _largeNullCompare;
    final smallNull = _segList.isNotEmpty && compare0(null, _segList.first._elements.first.target) < 0;
    final result = _Seg<E>(0);
    for (final seg in _segList) {
      result.mergeSeg(seg);
    }
    int compare1(WeakReference<E> a, WeakReference<E> b) =>
        compare0(a.target, b.target);
    result._elements.sort(compare1);
    if (smallNull) {
      result.start = len - result.length;
    }
    _segList = <_Seg<E>>[result];
    for (final weakRef in result._elements) {
      _finalizer.attach(weakRef, _Token());
    }
  }

  /// Returns a new [WeakList] containing the elements between [start] and
  /// [end].
  /// Note that sublist of this WeakList is also a WeakList.
  @override
  WeakList<E> sublist(int start, [int? end]) {
    final len = this.length; // purge GCed
    end ??= len;

    RangeError.checkValidRange(start, end, len);

    var (sj, sseg) = _getSeg(start);
    var (ej, eseg) = _getSeg(end);
    final segList = <_Seg<E>>[];
    if (sseg != null) {
      if (identical(sseg, eseg)) {
        // on the same segment
        segList.add(_Seg(0, elements: _deepCopy(sseg, start, end)));
        return WeakList._fromSegs(segList, end - start);
      }
      segList.add(_Seg(0, elements: _deepCopy(sseg, start, sseg.end)));
    }
    sj += 1;

    if (eseg == null) ej += 1;

    for (int k = sj; k < ej; ++k) {
      final seg0 = segList[k];
      segList.add(seg0.deepCopy()..start = seg0.start - start);
    }

    if (eseg != null) {
      segList.add(_Seg(eseg.start - start, elements: _deepCopy(eseg, eseg.start, end)));
    }

    return WeakList._fromSegs(segList, end - start);
  }
  
  @override
  Iterable<E?> take(int count) =>
      _weakListRangeIterable(this, 0, count);

  @override
  Iterable<E?> takeWhile(bool Function(E? value) test) =>
      _weakListTakeWhileIterable(this, test);

  @override
  bool contains(Object? element) {
    _tryPurgeGcElements();

    if (element == null) {
      return _hasNull;
    }
    // element != null
    for (final elm in _weakListNonNullIterable(this)) {
      if (element == elm) return true;
    }
    return false;
  }

  @override
  Iterable<E?> where(bool Function(E? value) test) =>
      _weakListWhereIterable(this, test);


  List<WeakReference<E>> _deepCopy(_Seg<E> seg, int start, int end) {
    final src = seg.sublist(start, end);
    final tgt = <WeakReference<E>>[];
    for (final elm in src) {
      tgt.add(WeakReference(elm.target!));
    }
    return tgt;
  }
  
  void _removeCountInSegs(int sj, int ej) {
    for (int j = sj; j < ej; ++j) {
      _elmCount -= _segList[j].length;
    }
  }

  void _assignValue(int index, E element) {
    final (j, seg) = _getSeg(index);

    var elmWeakRef = WeakReference(element);
    _finalizer.attach(element, _Token());

    if (seg != null) {
      // case a and b
      final oldWeakRef = seg.assign(index, elmWeakRef);
      if (oldWeakRef != null) {
        // _finalizer.detach(oldWeakRef);
      } else {
        _elmCount += 1;
      }
    } else {
      // case c
      _mergeAndAssignValue(j + 1, index, elmWeakRef);
    }
  }

  void _insertValue(int j, _Seg<E>? seg, int index, E element) {
    final elmWeakRef = WeakReference(element);
    _finalizer.attach(element, _Token());
    _elmCount += 1;
    if (seg != null) {
      seg.insert(index, elmWeakRef);
    } else {
      // check if adjacent to end of previous segment
      if (j >= 0 && _segList[j].end == index) {
        // adjacent
        _segList[j].add(elmWeakRef);
      } else {
        _segList.insert(j += 1, _Seg(index, elements: [elmWeakRef]));
      }
    }
    _shift(j + 1, 1);
  }

  void _insertNull(int j, _Seg<E>? seg, int index) {
    if (seg != null) {
      final (headSeg, tailSeg) = seg._split(index);
      if (headSeg == null) {
        // split at seg.start, shift including this seg
        _shift(j, 1);
      } else if (tailSeg != null) {
        _segList.insert(j + 1, tailSeg);
        _shift(j + 1, 1);
      }
    } else {
      _shift(j + 1, 1);
    }
  }


  bool _testNull(E? elm) => elm == null;

  // _Seg at _segList[j]; element at _Seg._element[index];
  // return old WeakReference if any.
  void _mergeAndAssignValue(int j, int index, WeakReference<E> elmWeakRef) {
    _elmCount += 1;
    // try merge with previous seg
    _Seg<E>? prevSeg;
    if (j > 0) {
      final i = j - 1;
      final prevSeg0 = _segList[i];
      if (prevSeg0.end == index) {
        // adjacent to previous seg; use it
        prevSeg = prevSeg0;
      }
    }

    // try merge with next seg
    _Seg<E>? nextSeg;
    if (j < _segList.length) {
      final nextSeg0 = _segList[j];
      if (nextSeg0.start == index + 1) {
        nextSeg = nextSeg0;
      }
    }

    if (prevSeg != null) {
      prevSeg.assign(index, elmWeakRef); // append to prevSeg
      if (nextSeg != null) {
        prevSeg.mergeSeg(nextSeg); // merge nextSeg to prevSeg
        _segList.removeAt(j); // remove the merged nextSeg from _segList
      }
    } else if (nextSeg != null) {
      nextSeg
          ..start = index
          ..insert(index, elmWeakRef); // insert into nextSeg
    } else {
      // neither merge-able; insert a new _Seg
      _segList.insert(j, _Seg(index, elements: [elmWeakRef]));
    }
  }

  /// Returns (index of the segment in _segList list, the segment); the [j]
  /// would need to be add 1 if segment is null (not exists).
  (int, _Seg<E>?) _getSeg(int index, [int? minIdx, int? maxIdx]) {
    final key = _Seg(index);
    final j = binarySearch(_segList, key, _compareSeg, minIdx, maxIdx); // compare _Seg.start
    // |-|-|-|-|   |-|-|-|
    //  ^   ^    ^
    //  a   b    c
    if (j >= 0) {
      // case a
      final seg = _segList[j];
      return (j, seg);
    }

    // case b or c
    final i = -j-1-1; // find previous one
    if (i < 0) {
      // before first seg (case c)
      return (-1, null);
    } else {
      final seg = _segList[i];
      return index < seg.end
          ? (i, seg) // case b
          : (i, null); // case c
    }
  }

  /// Shift indexes on remove / insert
  /// [j] is the index in _segList
  void _shift(int j, int offset) {
    if (offset == 0) return;
    for (var k = _segList.length; --k >= j;) {
      final seg = _segList[k];
      seg.start += offset;
    }
    _length += offset;
  }

  /// Try to purge GCed elements if gcCount exceeds a threshold percentage
  void _tryPurgeGcElements() {
    if (_elmCount == 0 || _gcCount / _elmCount < _gcThreshold) return;
    _purgeGcElements();
  }

  void _purgeGcElements() {
    final result = <_Seg<E>>[];
    _elmCount = 0;
    _Seg<E>? seg0;
    for (final seg in _segList) {
      int si = seg.start;
      for (final weakRef in seg._elements) {
        if (weakRef.target != null) {
          seg0 ??= _Seg(si);
          seg0.add(weakRef);
        } else if (seg0 != null) {
          result.add(seg0);
          _elmCount += seg0.length;
          seg0 = null;
        }
        ++si;
      }
      if (seg0 != null) {
        result.add(seg0);
        _elmCount += seg0.length;
        seg0 = null;
      }
    }
    if (seg0 != null) {
      result.add(seg0);
      _elmCount += seg0.length;
    }
    _segList = result;
    _gcCount = 0;
  }

  void _compactElements() {
    final seg0 = _Seg<E>(0);
    for (final seg in _segList) {
      for (final weakRef in seg._elements) {
        if (weakRef.target != null) {
          seg0.add(weakRef);
        }
      }
    }
    _elmCount = seg0.length;
    _segList = seg0.isEmpty ? <_Seg<E>>[] : [seg0];
    _gcCount = 0;
    // do not change length
  }

  // For test and debug
  @override
  String toString() => '$_segList';

  // whether this list has null element
  bool get _hasNull =>
      isNotEmpty && (_segList.length != 1 || _segList.first.length != _length);

  void _removeAllNull() {
    _compactElements();
    this.length = _elmCount;
  }

  void _filter(bool Function(E? element) test, bool retain) {
    _checkUnmodifiableAndFixLength();

    _tryPurgeGcElements();
    if (test(null) != retain) {
      _removeAllNull(); // only zero or one non-null segment
      if (isEmpty) return;
      final elements = _segList.last._elements;
      int j = elements.length;
      while (--j >= 0) {
        final elmWeakRef = elements[j];
        final elm = elmWeakRef.target;
        if (test(elm) != retain) {
          // _finalizer.detach(elmWeakRef);
          elements.removeAt(j);
          --_elmCount;
        }
      }
    } else {
      final retainedSegs = <_Seg<E>>[];
      int startX = 0;
      int si = 0;
      for (int j = 0; j < _segList.length; ++j) {
        final seg = _segList[j];
        final retained = <WeakReference<E>>[];
        if (seg.start > si) {
          final nullLen = seg.start - si;
          startX += nullLen;
        }
        si = seg.end;
        for (final elmWeakRef in seg._elements) {
          if (test(elmWeakRef.target) == retain) {
            retained.add(elmWeakRef);
          } else {
            // _finalizer.detach(elmWeakRef);
            --_elmCount;
          }
        }
        if (retained.isNotEmpty) {
          final segX = _Seg(startX, elements: retained);
          startX += retained.length;
          retainedSegs.add(segX);
        }
      }
      // tail null
      _length = startX + (_length - si);
      _segList = retainedSegs;
    }
  }

  void _fillValue(int start, int end, int sj, _Seg<E>? sseg, int ej, _Seg<E>? eseg, E fill) {
    final elements = <WeakReference<E>>[];
    for (int j = start; j < end; ++j) {
      final weakReference = WeakReference(fill);
      elements.add(weakReference);
      _finalizer.attach(fill, _Token());
    }
    if (sseg != null && identical(sseg, eseg)) {
      // on the same segment; fill the segment
      // final detached = sseg.fillRange(start, end, elements);
      // for (final weakRef in detached) {
      //   _finalizer.detach(weakRef);
      // }
      sseg.fillRange(start, end, elements);
      return; // done
    }
    // not on the same segment
    if (sseg != null) {
      // not on the same segment; cut tail of sseg
      _elmCount -= sseg.end - start;
      final (headSeg1, _) = sseg._cut(start, sseg.end);
      if (headSeg1 != null) {
        // not total cut
        sseg.addAll(elements);
      } else {
        // total cut
        _segList[sj] = _Seg(start, elements: elements);
      }
      sj += 1;
    } else {
      // check if start adjacent to end of previous seg
      if (sj >= 0 && _segList[sj].end == start) {
        // adjacent
        _segList[sj].addAll(elements);
      } else {
        _segList.insert(sj += 1, _Seg(start, elements: elements));
        ej += 1;
      }
      sj += 1;
    }
    if (eseg != null) {
      // cut head of eseg (no way of total cut)
      _elmCount -= end - eseg.start;
      eseg._cut(eseg.start, end);
      _segList[sj - 1].addAll(eseg._elements);
    }
    _removeCountInSegs(sj, ej + 1);
    _elmCount += elements.length;
    _segList.removeRange(sj, ej + 1);
  }

  void _fillNull(int start, int end, int sj, _Seg<E>? sseg, int ej, _Seg<E>? eseg) {
    if (sseg != null && identical(sseg, eseg)) {
      // on the same segment; cut the segment (no way of total cut)
      _elmCount -= end - start;
      final (_, tailSeg) = sseg._cut(start, end);
      if (tailSeg != null) {
        // with an extra tail seg
        _segList.insert(sj + 1, tailSeg);
      }
      return; // done
    }
    // not on the same segment
    if (sseg != null) {
      // cut tail of sseg
      _elmCount -= sseg.end - start;
      final (headSeg1, _) = sseg._cut(start, sseg.end);
      if (headSeg1 != null) {
        // not total cut
        sj += 1;
      }
    } else {
      sj += 1;
    }
    if (eseg != null) {
      // cut head of eseg (no way of total cut)
      _elmCount -= end - eseg.start;
      eseg._cut(eseg.start, end);
    } else {
      ej += 1;
    }
    _removeCountInSegs(sj, ej);
    _segList.removeRange(sj, ej);
  }

  // Return the (_segList index, offset for shifting)
  (int, int) _insertIterable(int j, _Seg<E>? seg, int index, Iterable<E?> iterable,
      {bool mergeEnd = true, void Function(int index)? validInsert}) {
    final result = <_Seg<E>>[];
    _Seg<E>? segX;

    int k = index;
    bool isNull = false;
    for (final elm in iterable) {
      if (validInsert != null) validInsert(k);
      if (elm == null) {
        if (!isNull) {
          // start of a new null range
          isNull = true;
          if (segX != null) {
            _elmCount += segX.length;
            segX = null;
          }
        }
      } else {
        // elm not null
        if (isNull) {
          // was null; set as non-null
          isNull = false;
        }
        // handle the non-null element
        final elmWeakRef = WeakReference(elm);
        _finalizer.attach(elm, _Token());
        if (segX == null) {
          segX = _Seg(k, elements: [elmWeakRef]);
          result.add(segX);
        } else {
          segX.add(elmWeakRef);
        }
      }
      k += 1;
    }
    if (segX != null) {
      _elmCount += segX.length;
    }
    final offset = k - index;

    _Seg<E>? preSeg;
    if (seg != null) {
      final (headSeg, tailSeg) = seg._split(index);
      if (headSeg != null) {
        preSeg = headSeg; // operate at j seg
        j += 1;
        if (tailSeg != null) {
          // split an extra tailSeg
          _segList.insert(j, tailSeg);
        }
      }
    } else {
      // check if adjacent to previous seg
      if (j >= 0 && _segList[j].start == index) {
        preSeg = _segList[j]; // operate at j seg
      }
      j += 1;
    }

    if (mergeEnd) {
      // check if segs.last adjacent to nextSeg.start
      final seg0 = _segList[j];
      if (j < _segList.length && seg0.start == index
          && result.isNotEmpty && result.last.end == k) {
        // adjacent
        result.last.mergeSeg(seg0);
        _segList.removeAt(j);
      }
    }

    if (preSeg != null) {
      // check if segs.first adjacent to preSeg
      if (result.isNotEmpty && preSeg.end == result.first.start) {
        preSeg.mergeSeg(result.first);
        result.removeAt(0);
      }
    }

    // insert segs
    _segList.insertAll(j, result);
    j += result.length;
    return (j, offset);
  }

  // for debug only
  void validElementCount() {
    int count = 0;
    for (final seg in _segList) {
      count += seg.length;
    }
    assert(_elmCount == count, 'elmCount($_elmCount) should equals to $count');
  }

  void _checkUnmodifiableAndFixLength() {
    _checkUnmodifiable();
    _checkFixLength();
  }

  void _checkFixLength() {
    if (!_growable) {
      throw UnsupportedError('Cannot change the length of a fixed-length list');
    }
  }

  void _checkUnmodifiable() {
    if (_unmodifiable) {
      throw UnsupportedError('Cannot change the length or element from an unmodifiable list');
    }
  }
}

class _Seg<E extends Object> {
  int start; // first index of this elements segment
  final List<WeakReference<E>> _elements;

  _Seg(this.start, {List<WeakReference<E>>? elements} )
      : _elements = elements ?? <WeakReference<E>>[];

  _Seg<E> deepCopy() {
    final tgt = <WeakReference<E>>[];
    for (final weakRef in _elements) {
      tgt.add(WeakReference(weakRef.target!));
    }
    return _Seg<E>(this.start, elements: tgt);
  }
  
  int get end => start + _elements.length;

  int get length => _elements.length;

  bool get isEmpty => _elements.isEmpty;

  E? at(int index) =>
      index < start || index >= end ? null : _elements[index - start].target;

  WeakReference<E>? assign(int index, WeakReference<E> weakRef) {
    final idx0 = index - start;
    if (index < end) {
      var oldWeakRef = _elements[idx0];
      _elements[idx0] = weakRef;
      return oldWeakRef;
    } else {
      _elements.insert(idx0, weakRef);
      return null;
    }
  }

  void mergeSeg(_Seg<E> nextSeg) => _elements.addAll(nextSeg._elements);

  void insert(int index, WeakReference<E> weakRef) {
    _elements.insert(index - start, weakRef);
  }
  
  void add(WeakReference<E> weakRef) => _elements.add(weakRef);

  void addAll(Iterable<WeakReference<E>> elements) => _elements.addAll(elements);

  List<WeakReference<E>> sublist(int start, int end) =>
      _elements.sublist(max(start - this.start, 0), min(end - this.start, length));

  /// fill the range with the fillValue; returns the overwritten elements
  List<WeakReference<E>> fillRange(int start, int end, [List<WeakReference<E>>? fillValues]) {
    if (start == end) return List.empty(); // no-op
    final start0 = start - this.start;
    final end0 = end - this.start;
    final len = min(end0, length);
    final result = _elements.sublist(start0, len);
    if (fillValues == null) {
      _cut(start, end);
      return result;
    }
    if (end - start > fillValues.length) throw IterableElementError.tooFew();
    _elements.setRange(start0, len, fillValues);
    _elements.addAll(fillValues.skip(len - start0));
    return result;
  }

  List<WeakReference<E>> removeRange(int start, int end) {
    if (start == end) return List.empty(); // no-op
    final start0 = start - this.start;
    final end0 = end - this.start;
    final len = min(end0, length);
    final result = _elements.sublist(start0, len);
    _elements.removeRange(start0, len);
    return result;
  }

  // Split at the specified index of this segment into headSeg and tailSeg; and
  // return the results as (headSeg, tailSeg).
  (_Seg<E>?, _Seg<E>?) _split(int index) {
    if (index == this.start) {
      return (null, this);
    }
    if (index == this.end) {
      return (this, null);
    }
    final idx0 = index - start;
    final tailSeg = _Seg(index, elements: _elements.sublist(idx0));
    this._elements.removeRange(idx0, _elements.length);
    return (this, tailSeg);
  }

  // Cut the specified range from start(inclusive) to end(exclusive) of
  // this _Seg and return the split segments:
  // (headSeg, tailSeg): split a new tail segment
  // (headSeg, null): no operation or only this segment changed
  // (null, null): total cut
  (_Seg<E>?, _Seg<E>?) _cut(int start, int end) {
    if (start == end) return (this, null); // no-op
    final start0 = start - this.start;
    final end0 = end - this.start;
    _Seg<E>? headSeg, tailSeg;
    if (start0 > 0) {
      // has head seg
      if (end0 < length) {
        // has tail seg
        tailSeg = _Seg(end, elements: _elements.sublist(end0));
      }
      // make this seg as head seg
      _elements.removeRange(start0, length);
      headSeg = this;
    } else if (end0 < length) {
      // no head seg, has tail seg; make this seg as head seg
      _elements.removeRange(0, end0);
      this.start = end;
      headSeg = this;
    } // else { // no head seg nor tail seg; total cut
    return (headSeg, tailSeg);
  }

  @override
  String toString() =>
      '$start~$end: ${_elements.map((e) => e.target)}';
}

int binarySearch<T>(List<T> sorted, T key, Comparator<T> comparator,
    [int? minIdx, int? maxIdx]) {
  int low = minIdx == null ? 0 : max(0, minIdx);
  int hgh = maxIdx == null ? sorted.length - 1 : min(sorted.length - 1, maxIdx);
  while (low <= hgh) {
    final int mid = (low + hgh) ~/ 2;
    final val = sorted[mid];
    final num cmp = comparator(key, val);
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

int _compareSeg(_Seg a, _Seg b) => a.start - b.start;

Iterable<E?> _weakListNonNullIterable<E extends Object>(WeakList<E> weakList, [int segIndex = 0]) sync* {
  final segList = weakList._segList;
  final len = segList.length;
  for (int j = segIndex; j < len; ++j) {
    final seg = segList[j];
    for (final weakRef in seg._elements) {
      yield weakRef.target;
    }
  }
}

Iterable<E?> _weakListNonNullReversedIterable<E extends Object>(WeakList<E> weakList, [int? segIndex]) sync* {
  final segList = weakList._segList;
  final len = segList.length;
  segIndex ??= len - 1;
  for (int j = segIndex; j >= 0; --j) {
    final seg = segList[j];
    for (final element in seg._elements.reversed) {
      yield element.target;
    }
  }
}

Iterable<E?> _weakListIterable<E extends Object>(WeakList<E> weakList) sync* {
  for (final w in _weakListReferenceIterable(weakList)) {
    yield w?.target;
  }
}

Iterable<WeakReference<E>?> _weakListReferenceIterable<E extends Object>(WeakList<E> weakList) sync* {
  int si = 0;
  for (final seg in weakList._segList) {
    final ei = seg.start;
    // return null if out of seg
    for (var j = si; j < ei; ++j) {
      yield null;
    }
    // return elements in seg
    for (final weakRef in seg._elements) {
      yield weakRef;
    }
    si = seg.end;
  }
  for (var j = si; j < weakList._length; ++j) {
    yield null;
  }
}

Iterable<E?> _weakListReversedIterable<E extends Object>(WeakList<E> weakList) sync* {
  int ei = weakList._length;
  for (final seg in weakList._segList.reversed) {
    for (final elm in _reversedYieldSeg(ei, seg, 0)) {
      yield elm;
    }
    ei = seg.start;
  }
  for (var j = ei; --j >= 0;) {
    yield null;
  }
}

Iterable<E?> _indexesGeneratorIterable<E extends Object>(int length, E? Function(int) generator) sync* {
  for (var j = 0; j < length; ++j) {
    yield generator(j);
  }
}

Iterable<int> _weakListIndexesIterable<E extends Object>(WeakList<E> weakList) sync* {
  final len = weakList.length;
  for (var j = 0; j < len; ++j) {
    yield j;
  }
}

Iterable<E?> _weakListFollowedByIterable<E extends Object>(WeakList<E> weakList, Iterable<E?> other) sync* {
  for (final elm in weakList) {
    yield elm;
  }
  for (final elm in other) {
    yield elm;
  }
}

Iterable<E?> _weakListRangeIterable<E extends Object>(WeakList<E> weakList, int start, int end) sync* {
  if (end > weakList._length) end = weakList._length;

  int si = start;
  var (sj, sseg) = weakList._getSeg(start);
  if (sseg != null) {
    final end0 = min(end, sseg.end);
    for (; si < end0; ++si) {
      yield sseg.at(si);
    }
  }
  sj += 1;

  var (ej, eseg) = weakList._getSeg(end);
  if (eseg == null) ej += 1;

  final segList = weakList._segList;
  for (int k = sj; k < ej; ++k) {
    final seg = segList[k];
    for (final elm in _yieldSeg(si, seg, end)) {
      yield elm;
    }
    si = min(seg.end, end);
  }
  if (eseg != null) {
    for (final elm in _yieldSeg(si, eseg, end)) {
      yield elm;
    }
  } else {
    // return tail null until end
    for (var j = si; j < end; ++j) {
      yield null;
    }
  }
}

Iterable<T> _weakListMapIterable<E extends Object, T>(WeakList<E> weakList, T Function(E? element) f) sync* {
  for (final elm in weakList) {
    yield f(elm);
  }
}

/// assume
/// ```
/// [null, seg, null, ..., null, seg, null]
///  ^      ^~ sj                      ^    ^~ ej
///  |                                 |
///  +~ start                          +~ end
/// ```
Iterable<E?> _segListElementIterable<E extends Object>(List<_Seg<E>> segList, int sj, int ej, int start, int end) sync* {
  for (int j = sj; j < ej; ++j) {
    final seg = segList[j];
    for (final elm in _yieldSeg(start, seg, end)) {
      yield elm;
    }
    if (seg.end >= end) {
      return;
    }
    start = seg.end;
  }
  for (int j = start; j < end; ++j) {
    yield null;
  }
}

Iterable<E?> _weakListSkipWhileNullIterable<E extends Object>(WeakList<E> weakList, bool Function(E? value) test) sync* {
  final segList = weakList._segList;
  if (segList.isNotEmpty) {
    final segLen = segList.length;
    final end = weakList._length;
    // locate the first seg which not match the test
    segLoop:
    for (int j = 0; j < segLen; ++j) {
      final seg = segList[j];
      for (int k = 0; k < seg.length; ++k) {
        final elm = seg._elements[k].target;
        if (!test(elm)) {
          // found the segment and 1st element
          // loop thru the rest of this seg
          for (final elm0 in _yieldSeg(seg.start + k, seg, end)) {
            yield elm0;
          }
          // loop thru the rest of weakList
          final it = _segListElementIterable<E>(segList, j + 1, segLen, seg.end, weakList._length).iterator;
          while (it.moveNext()) {
            yield it.current;
          }
          break segLoop;
        }
      }
    }
  }
}

Iterable<E?> _weakListTakeWhileIterable<E extends Object>(WeakList<E> weakList, bool Function(E? value) test) sync* {
  for (final elm in weakList) {
    if (!test(elm)) break;
    yield elm;
  }
}

Iterable<E?> _weakListWhereIterable<E extends Object>(WeakList<E> weakList, bool Function(E? value) test) sync* {
  for (final elm in weakList) {
    if (test(elm)) {
      yield elm;
    }
  }
}

Iterable<E?> _yieldSeg<E extends Object>(int si, _Seg<E> seg, int end) sync* {
  final ei = min(seg.start, end);
  // return null if out of seg
  for (; si < ei; ++si) {
    yield null;
  }
  // return elements in seg
  final ei0 = min(seg.end, end);
  final segStart = seg.start;
  final elements = seg._elements;
  for (; si < ei0; ++si) {
    yield elements[si - segStart].target;
  }
}

Iterable<E?> _reversedYieldSeg<E extends Object>(int ei, _Seg<E> seg, int start) sync* {
  final si = max(seg.end, start);
  // return null if out of seg
  if (ei > si) {
    while (--ei >= si) {
      yield null;
    }
  }
  // return elements in seg
  final segStart = seg.start;
  final si0 = max(segStart, start);
  final elements = seg._elements;
  while (--ei >= si0) {
    yield elements[ei - segStart].target;
  }
}

int _largeNullCompare<E>(E? a, E? b) =>
    a == b ? 0  // null == null
        : a == null ? 1
        : b == null ? -1
        : Comparable.compare(a as Comparable, b as Comparable);

class _WeakListMapView<E extends Object> extends UnmodifiableMapBase<int, E?> {
  final WeakList<E> _weakList;

  _WeakListMapView(this._weakList);

  @override
  E? operator [](Object? key) =>
      containsKey(key) ? _weakList[key as int] : null;

  @override
  int get length => _weakList.length;

  @override
  Iterable<E?> get values => _weakList.map((e) => e);

  @override
  Iterable<int> get keys => _weakListIndexesIterable(_weakList);

  @override
  bool get isEmpty => _weakList.isEmpty;

  @override
  bool get isNotEmpty => _weakList.isNotEmpty;

  @override
  bool containsValue(Object? value) => _weakList.contains(value);

  @override
  bool containsKey(Object? key) => key is int && key >= 0 && key < length;

  @override
  void forEach(void Function(int key, E? value) f) {
    final len = _weakList.length;
    int i = 0;
    for (final elm in _weakList) {
      f(i, elm);
      if (len != _weakList.length) {
        throw ConcurrentModificationError(_weakList);
      }
      ++i;
    }
  }
}

// A marker class
class _Token<E extends Object> {}
