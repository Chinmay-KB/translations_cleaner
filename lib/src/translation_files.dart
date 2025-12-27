import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:translations_cleaner/src/subpackage_detection.dart';

/// Get list of all `*.arb` files in the project, excluding subpackages
/// unless [includeSubpackages] is set to true.
List<FileSystemEntity> translationFiles() {
  final path = Directory.current.path;
  final subpackageDirs = getSubpackageDirectories();

  final arbFile = Glob("$path/**.arb");
  final allArbFiles = arbFile.listSync(followLinks: false);

  // Filter out files from subpackages
  return allArbFiles
      .where((file) => !isInSubpackage(file.path, subpackageDirs))
      .toList();
}
