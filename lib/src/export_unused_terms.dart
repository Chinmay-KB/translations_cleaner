import 'dart:io';

import 'package:translations_cleaner/src/models/term.dart';

void exportUnusedTerms(Set<Term> notUsed, String? outputPath) {
  if (outputPath == null) {
    print('⛔️ No outputPath provided, using default path');
  }

  outputPath ??= Directory.current.path;
  var file = File('$outputPath/unused-translations.txt');
  final buffer = StringBuffer();
  buffer.writeAll(notUsed.map((e) => '${e.key}\n'));
  file.writeAsString(buffer.toString());
  print('✅ Saved in $outputPath/unused-translations.txt');
}
