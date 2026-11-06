import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Writes store screenshots taken by integration_test/screenshots_test.dart.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final file = File('build/store_shots/$name.png');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes);
    return true;
  },
);
