import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

/// Get a list of all `.dart` files under the given [sourcePaths].
List<FileSystemEntity> getDartFiles({
  List<String> sourcePaths = const <String>['lib'],
}) {
  final root = Directory.current.path;
  final dartFiles = <FileSystemEntity>[];
  final seen = <String>{};
  for (final sourcePath in sourcePaths) {
    final glob = Glob("$root/$sourcePath/**.dart");
    for (final entity in glob.listSync(followLinks: false)) {
      if (seen.add(entity.path)) {
        dartFiles.add(entity);
      }
    }
  }

  return dartFiles;
}
