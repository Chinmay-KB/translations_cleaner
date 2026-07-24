import 'dart:io';

import 'package:translations_cleaner/src/config.dart';
import 'package:translations_cleaner/src/models/term.dart';
import 'package:translations_cleaner/src/project_files.dart';
import 'package:translations_cleaner/src/term_usage_ast.dart';
import 'package:translations_cleaner/src/translation_terms.dart';

/// Searches through all `*.arb` files to check which translation terms
/// have not been used.
Set<Term> findUnusedTerms() {
  print('FETCHING ALL THE TRANSLATION TERMS 🌏');
  final terms = getTranslationTerms();
  final config = TranslationsCleanerConfig.load();
  print('FETCHING ALL THE DART FILES TO LOOK THROUGH 🏗');
  final dartFiles = getDartFiles(sourcePaths: config.sourcePaths);
  print('LOOKING THROUGH FILES TO FIND UNUSED TERMS 👀');
  final termKeys = terms.map((term) => term.key).toSet();

  final usedTerms = _findUsedTermsByAst(dartFiles, termKeys, config);

  return terms
      .where((term) =>
          !usedTerms.contains(term.key) &&
          !config.ignoreKeys.contains(term.key))
      .toSet();
}

Set<String> _findUsedTermsByAst(
  List<FileSystemEntity> dartFiles,
  Set<String> termKeys,
  TranslationsCleanerConfig config,
) {
  final usedKeys = findUsedTermsWithAst(
    dartFiles,
    termKeys,
    extraRoots: config.localizationRoots,
    extraAccessors: config.localizationAccessors,
  );
  if (usedKeys == null) {
    throw StateError('AST parsing failed in at least one file.');
  }
  return usedKeys;
}
