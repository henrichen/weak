// https://github.com/henrichen/weak
// weak_reference_queue.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2022-2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.

/// A queue that maintains the payload of its associated weak referenced target.
///
/// Call [attach] method to register a weak referenced target and an
/// associated payload into this queue.
///
/// Whenever the registered weak referenced target is garbage collected, its
/// associated payload will be append into this queue and can be retrieved back
/// by [poll] method.
///
/// Call [detach] method to unregister the attached weak referenced target and
/// the associated payload from this queue.
///
/// ```
/// T payload = ...;
/// E target = ...;
/// final weakRef = WeakReference(target);
/// // register the target and its associated payload
/// weakReferenceQueue.attach(weakRef, payload);
/// ...
/// // unregister the target and its associated payload
/// weakReferenceQueue.detach(weakRef);
/// ...
/// ```
///
/// Use [poll] method to retrieve payload whose associated target was garbage
/// collected.
/// ```
/// T? payload;
/// while ((payload = this.poll()) != null) {
///   // handle payload whose associated target is garbage collected
/// }
/// ```
///
/// Note you must call [poll] method or [clear] method from time to time to
/// depose associated payloads from this queue; or there might be memory
/// leakage.
class WeakReferenceQueue<E extends Object, T extends Object> {
  static final Finalizer _finalizer = Finalizer((token) {
    token._list.add(token._weakReference);
  });

  final Expando<T> _weakReferences;

  // List of WeakReferences whose target was GCed.
  List<WeakReference<E>> _list;

  /// The optional [name] is for debugging purpose only. Same name of two
  /// WeakReferenceQueue instances are two different instances.
  WeakReferenceQueue([String? name])
      : _list = <WeakReference<E>>[],
        _weakReferences = Expando<T>(name);

  /// Register the [weakReference] along with its target and an associated
  /// [payload]. Attach twice the same [weakReference], the previous attachment
  /// will be automatically detached.
  ///
  /// The associated [payload] can be retrieved via [poll] method later after
  /// the target is garbage collected.
  void attach(WeakReference<E> weakReference, T payload) {
    if (_weakReferences[weakReference] != null) {
      _finalizer.detach(weakReference);
    }
    final target = weakReference.target;
    if (target != null) {
      _weakReferences[weakReference] = payload;
      _finalizer.attach(target, _Token(_list, weakReference),
          detach: weakReference);
    }
  }

  /// Unregister the [attach]ed [weakReference] from this queue.
  void detach(WeakReference<E> weakReference) {
    _weakReferences[weakReference] = null;
    _finalizer.detach(weakReference);
  }

  /// Poll this queue to see if the payload of a garbage collected
  /// target is available; return null if no more.
  ///
  /// Note that whenever a payload is retrieved, it is removed from this queue
  /// and no longer exists.
  ///
  /// ```
  /// T? payload;
  /// while ((payload = this.poll()) != null) {
  ///   // do what ever like to do
  /// }
  /// ```
  T? poll() {
    while (_list.isNotEmpty) {
      final weakRef = _list.removeLast();
      final payload = _weakReferences[weakRef];
      if (payload != null) {
        return payload;
      }
      // continue for next possible payload
    }
    return null;
  }

  /// Returns the associated payload of the attached [weakReference].
  T? getPayload(WeakReference<E> weakReference) =>
      _weakReferences[weakReference];

  /// Returns the length of this queue. That is, the count of payloads whose
  /// targets were already garbage collected but not yet [poll]ed out of this
  /// queue.
  int get length => _list.length;

  /// Clear this queue.
  void clear() => _list = <WeakReference<E>>[];

  /// Whether this queue is empty
  bool get isEmpty => _list.isEmpty;

  /// Whether this queue is not empty
  bool get isNotEmpty => _list.isNotEmpty;
}

class _Token<E extends Object, T extends Object> {
  final List<WeakReference<E>> _list;
  final WeakReference<E> _weakReference;
  _Token(this._list, this._weakReference);
}
