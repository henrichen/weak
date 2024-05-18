// https://github.com/henrichen/weak
// weak.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2022-2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.

/// Support weak referenced collection classes - [WeakHashMap], [WeakHashSet],
/// [WeakList] and [WeakReferenceQueue].
/// Elements in such collections are weakly referenced and can be removed
/// from the collection whenever the element is no
/// longer referenced by other variables and garbage collected.
library weak;

export 'src/weak_list.dart' show WeakList;
export 'src/weak_hash_map.dart' show WeakHashMap;
export 'src/weak_hash_set.dart' show WeakHashSet;
export 'src/weak_reference_queue.dart' show WeakReferenceQueue;
