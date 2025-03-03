// https://github.com/henrichen/weak
// gc_util.dart - created by Henri Chen<chenhenri@gmail.com>
// Copyright (C) 2024 Henri Chen<chenhenri@gmail.com>. All Rights Reserved.
library;

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:test/test.dart';

import 'package:logging/logging.dart';
import 'package:vm_service/vm_service.dart' hide Isolate, Log;
import 'package:vm_service/vm_service.dart' as vm_service;
import 'package:vm_service/vm_service_io.dart';

const kTag = 'vm_services';

/// see https://stackoverflow.com/questions/63730179/can-we-force-the-dart-garbage-collector/72934204#72934204
/// This is for enforcing a garbage collection in Dart VM. How to use it?
/// ```dart
/// void main() {
///   runTestsInVmService(
///     _core,
///     selfFilePath: 'path/to/my/file.dart',
///   );
/// }
///
/// void _core(VmServiceUtil vmService) {
///   test('hello', () async {
///     do_something();
///     await vmService.gc();
///     do_another_thing();
///   });
/// }
/// ```
FutureOr<void> runTestsInVmService(
  FutureOr<void> Function(VmServiceUtil) body, {
  required String selfFilePath,
}) async {
  Log.d(kTag,
      'runInVmService selfFilePath=$selfFilePath Platform.script.path=${Platform.script.path}');

  if (Platform.script.path == selfFilePath) {
    final vmService = await VmServiceUtil.create();
    tearDownAll(vmService.dispose);
    await body(vmService);
  } else {
    test('run all tests in subprocess', () async {
      await executeProcess(
          'dart', ['run', '--enable-vm-service', selfFilePath]);
    });
  }
}

class VmServiceUtil {
  static const _kTag = 'VmServiceUtil';

  final VmService vmService;

  VmServiceUtil._(this.vmService);

  static Future<VmServiceUtil> create() async {
    final serverUri = (await Service.getInfo()).serverUri;
    if (serverUri == null) {
      throw Exception('Cannot find serverUri for VmService. '
          'Ensure you run like `dart run --enable-vm-service path/to/your/file.dart`');
    }

    final vmService =
        await vmServiceConnectUri(_toWebSocket(serverUri), log: _Log());
    return VmServiceUtil._(vmService);
  }

  void dispose() {
    vmService.dispose();
  }

  Future<int?> gc({doGc = true}) async {
    final isolateId = Service.getIsolateId(Isolate.current)!;
    final profile = await vmService.getAllocationProfile(isolateId, gc: doGc);
    Log.d(_kTag, 'gc triggered (heapUsage=${profile.memoryUsage?.heapUsage})');
    return Future.value(profile.memoryUsage?.heapUsage);
  }
}

String _toWebSocket(Uri uri) {
  final pathSegments = [...uri.pathSegments.where((s) => s.isNotEmpty), 'ws'];
  return uri.replace(scheme: 'ws', pathSegments: pathSegments).toString();
}

class _Log extends vm_service.Log {
  static const _kTag = 'vm_services';

  @override
  void warning(String message) => Log.w(_kTag, message);

  @override
  void severe(String message) => Log.e(_kTag, message);
}

Future<void> executeProcess(String executable, List<String> arguments) async {
  Log.d(kTag, 'executeProcess start `$executable ${arguments.join(" ")}`');

  final process = await Process.start(executable, arguments);

  process.stdout.listen((e) => Log.d(kTag, String.fromCharCodes(e)));
  process.stderr
      .listen((e) => Log.d(kTag, '[STDERR] ${String.fromCharCodes(e)}'));

//  stdout.addStream(process.stdout);
//  stderr.addStream(process.stderr);

  final exitCode = await process.exitCode;
  Log.d(kTag, 'executeProcess end exitCode=$exitCode');
  if (exitCode != 0) {
    throw Exception('Process execution failed (exitCode=$exitCode)');
  }
}

class Log {
  static d(String name, String message) => Logger(name).info(message);
  static w(String name, String message) => Logger(name).warning(message);
  static e(String name, String message) => Logger(name).severe(message);
  static printOn(String name) {
    final logger = Logger(name);
    logger.clearListeners();
    logger.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
      // if (record.error != null) print('error: ${record.error}');
      if (record.stackTrace != null) print('${record.stackTrace}');
    });
  }

  static printOff(String name) => Logger(name).clearListeners();
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

class Y {
  String value;
  Y(int value) : value = '$value';

  @override
  String toString() => 'Y$value';
}
