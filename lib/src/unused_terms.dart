import 'dart:io';

import 'package:translations_cleaner/src/models/term.dart';
import 'package:translations_cleaner/src/project_files.dart';
import 'package:translations_cleaner/src/translation_terms.dart';

/// Searches through all `*.arb` files to check which translation terms
/// have not been used.
Set<Term> findUnusedTerms() {
  print('FETCHING ALL THE TRANSLATION TERMS 🌏');
  final terms = getTranslationTerms();
  print('FETCHING ALL THE DART FILES TO LOOK THROUGH 🏗');
  final dartFiles = getDartFiles();
  print('LOOKING THROUGH FILES TO FIND UNUSED TERMS 👀');
  final unusedTerms = Set<Term>.from(terms);

  // Pre-compile regex patterns for each term using word boundaries
  // This prevents false positives like "restorePurchases" matching "restorePurchasesAsync"
  final termPatterns = <Term, RegExp>{};
  for (final term in terms) {
    termPatterns[term] = RegExp(r'\b' + RegExp.escape(term.key) + r'\b');
  }

  for (final file in dartFiles) {
    final content = File(file.path).readAsStringSync();
    for (final arb in terms) {
      if (termPatterns[arb]!.hasMatch(content)) {
        unusedTerms.remove(arb);
      }
    }
  }
  return unusedTerms;
}
