import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:path/path.dart' as p;

/// Global flag to include subpackages in scanning
bool includeSubpackages = false;

/// Returns a set of directories that contain their own pubspec.yaml,
/// indicating they are subpackages and should be excluded from scanning.
Set<String> getSubpackageDirectories() {
  if (includeSubpackages) {
    return {};
  }

  final path = Directory.current.path;
  final pubspecGlob = Glob("$path/**/pubspec.yaml");
  final pubspecFiles = pubspecGlob.listSync(followLinks: false);

  final subpackageDirs = <String>{};
  for (final file in pubspecFiles) {
    final dir = p.dirname(file.path);
    // Don't include the root directory itself
    if (dir != path) {
      subpackageDirs.add(dir);
    }
  }
  return subpackageDirs;
}

/// Checks if a file path is inside any of the subpackage directories.
bool isInSubpackage(String filePath, Set<String> subpackageDirs) {
  for (final subDir in subpackageDirs) {
    if (filePath.startsWith(subDir + Platform.pathSeparator)) {
      return true;
    }
  }
  return false;
}
