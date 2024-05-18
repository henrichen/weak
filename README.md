# Weak Referenced Collection Classes
WeakHashMap, WeakHashSet, WeakList, and WeakReferenceQueue implemented with [WeakReference] and [Finalizer] 

## Features

* [WeakHashMap]: A hash-table based implementation of [Map] with weak referenced keys.
  An entry in this weak hash map will be automatically removed when its key
  is garbage collected.

* [WeakHashSet]: A hash-table based implementation of [Set] with weak referenced elements.
  An element in this weak hash set will be automatically removed when the element is
  garbage collected.

* [WeakList]: An ordered [List] implementation with weak referenced elements. An element
  in this weak list will be automatically nullified when the element is garbage collected. 

* [WeakReferenceQueue]: A queue that maintains payload of its associated weak referenced 
  target. The payload registered in this class will be appended into the queue when its
  associated target is garbage collected. Then you can call [WeakReferenceQueue.poll] method
  to retrieve back the payloads from the queue and do some after-garbage-collected process.
  
## Getting started

Add this `weak` package to your [pubspec.yaml dependencies](https://pub.dev/packages/weak/install)

## Usage

```dart
import 'package:weak/weak.dart';

// ...
        
final weakMap = WeakHashMap();
final weakSet = WeakHashSet();
final weakList = WeakList();
final weakReferenceQueue = WeakReferenceQueue();

// ...
```
