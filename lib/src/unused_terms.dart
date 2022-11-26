import 'dart:io';

import 'package:translations_cleaner/src/models/term.dart';

/// Searches through all `*.arb` files to check which translation terms
/// have not been used.
Set<Term> findUnusedTerms(
  Set<Term> terms,
  List<FileSystemEntity> files,
) {
  final unusedTerms = Set<Term>.from(terms);

  for (final file in files) {
    final content = File(file.path).readAsStringSync();
    for (final arb in terms) {
      if (content.contains(arb.key)) {
        unusedTerms.remove(arb);
      }
    }
  }
  return unusedTerms;
}
