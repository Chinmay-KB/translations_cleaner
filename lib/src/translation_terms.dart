import 'dart:convert';
import 'dart:io';

import 'package:arb_cleaner/src/models/term.dart';
import 'package:console_bars/console_bars.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

Set<Term> getTranslationTerms() {
  final path = Directory.current.path;
  final arbFile = Glob("$path/**.arb");
  final arbFiles = <FileSystemEntity>[];
  final keys = arbFile.listSync(followLinks: false);

  for (var entity in keys) {
    arbFiles.add(entity);
  }

  final arbTerms = <Term>{};
  final p = FillingBar(
      width: 50,
      desc: "Reading arb files",
      total: arbFiles.length,
      percentage: true);
  for (final file in arbFiles) {
    p.increment();
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
