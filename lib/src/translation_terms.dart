import 'dart:convert';
import 'dart:io';

import 'package:translations_cleaner/src/models/term.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

/// Iterate through all files ending in `*.arb` and extract all the translation
/// terms being used.
///
Set<Term> getTranslationTerms() {
  final path = Directory.current.path;
  final arbFile = Glob("$path/**.arb");
  final arbFiles = arbFile.listSync(followLinks: false);

  final arbTerms = <Term>{};

  for (final file in arbFiles) {
    final content = File(file.path).readAsStringSync();
    final map = jsonDecode(content) as Map<String, dynamic>;
    for (final entry in map.entries) {
      if (!entry.key.startsWith('@')) {
        final hasAttribute = map.containsKey('@${entry.key}');
        arbTerms.add(Term(additionalAttributes: hasAttribute, key: entry.key));
      }
    }
  }
  return arbTerms;
}
