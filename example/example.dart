// https://github.com/henrichen/weak
// example.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
import 'dart:async';

import 'package:weak/weak.dart';

/// Image file cache implementation.
///
/// Different from [Expando] which needs the original Object to retrieve
/// the associated value, [WeakHashMap] allows you to retrieve associated value
/// with *equal* key and with iterable entries. Thus it is useful in some
/// scenarios.
///
/// For example, user can provide the file name and request to load a big image
/// file from the server. To save long loading time, you will need to cache
/// the image file in the client side so it is faster if user requests a file
/// of the same name; make your program more performant.
///
/// In such case, [WeakHashMap] is a perfect match to implement such cache
/// mechanism. We can use [FileName] class as the key and the [ImageFile],
/// the loaded image file contents, as the value. And prepare a circular queue
/// that maintains the most recently requested [FileName]s.
///
/// The algorithm is thus simple:
/// * User provide the file name.
/// * Wrap the file name to a [FileName] object and check if it is already
///   cached by retrieving [ImageFile] from the [WeakHashMap] (by calling
///   [WeakHashMap.[]]).
/// * If cached, i.e., not null, return the cached [ImageFile].
/// * If not cached
///   + Load the image file contents per the file name from the server as an
///     [ImageFile].
///   + Put it into the [WeakHashMap] by calling [WeakHashMap.[]=].
///   + Add the associated [FileName] into the circular queue.
///   + Return the loaded [ImageFile].
///
/// Note that whenever the circular queue is full and an [FileName] must be
/// removed (to give space for the new [FileName]), the strong reference to
/// the key, i.e. the [FileName] instance, of the [WeakHashMap] is gone and
/// the associated [ImageFile] in the [WeakHashMap] will be garbage collected
/// automatically and avoid memory leakage.
class ImageFileCache {
  final int _capacity;
  final WeakHashMap<FileName, ImageFile> _weakMap;
  final List<FileName> _queue;

  ImageFileCache(this._capacity)
      : _weakMap = WeakHashMap<FileName, ImageFile>(),
        _queue = <FileName>[];

  /// API to load the image file
  FutureOr<ImageFile> loadFile(String name) async {
    final fileName = FileName(name);
    ImageFile? imageFile = _weakMap[fileName];
    if (imageFile != null) return imageFile; // cached

    // not cached
    // 1. Load image file from the server
    imageFile = await loadFileFromServer(name);

    // 2. Put into the WeakHashMap
    _weakMap[fileName] = imageFile;

    // 3. Add FileName into circular queue; use FIFO replacement policy
    if (_queue.length >= _capacity) _queue.removeAt(0);
    _queue.add(fileName);

    // 4. Return the loaded image file
    return imageFile;
  }

  /// load file from server.
  FutureOr<ImageFile> loadFileFromServer(String name) async {
    // ... Imaging that this function do the real file loading from server
    return Future<ImageFile>.value(ImageFile([]));
  }
}

/// To workaround the constraint that string type is not allowed to be used
/// as the target of the [WeakReference].
class FileName {
  final String name;
  FileName(this.name);

  @override
  int get hashCode => name.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FileName && name == other.name);
}

/// Image file
class ImageFile {
  final List bytes;
  ImageFile(this.bytes);

  // ...
}
