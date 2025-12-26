import 'dart:convert';
import 'dart:io';

import 'package:translations_cleaner/src/models/term.dart';
import 'package:translations_cleaner/src/subpackage_detection.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

/// Iterate through all files ending in `*.arb` and extract all the translation
/// terms being used. Excludes subpackages unless [includeSubpackages] is set.
///
Set<Term> getTranslationTerms() {
  final path = Directory.current.path;
  final subpackageDirs = getSubpackageDirectories();
  final arbFile = Glob("$path/**.arb");
  final arbFiles = arbFile
      .listSync(followLinks: false)
      .where((file) => !isInSubpackage(file.path, subpackageDirs))
      .toList();

  final arbTerms = <Term>{};

  for (final file in arbFiles) {
    final content = File(file.path).readAsStringSync();
    Map<String, dynamic> map;
    try {
      map = jsonDecode(content) as Map<String, dynamic>;
    } on FormatException catch (e) {
      print('Error parsing ${file.path}: ${e.message}');
      print('Skipping this file. Please fix the JSON syntax and try again.');
      continue;
    }
    for (final entry in map.entries) {
      if (!entry.key.startsWith('@')) {
        final hasAttribute = map.containsKey('@${entry.key}');
        arbTerms.add(Term(additionalAttributes: hasAttribute, key: entry.key));
      }
    }
  }
  return arbTerms;
}
