import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

/// Get list of all `*.arb` files in the project
List<FileSystemEntity> translationFiles() {
  final path = Directory.current.path;

  final arbFile = Glob("$path/**.arb");
  return arbFile.listSync(followLinks: false);
}
