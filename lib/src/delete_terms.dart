import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:translations_cleaner/src/export_unused_terms.dart';
import 'package:translations_cleaner/src/models/term.dart';
import 'package:translations_cleaner/src/indentation.dart';
import 'package:translations_cleaner/src/translation_files.dart';
import 'package:translations_cleaner/src/unused_terms.dart';

/// Delete unused terms from the dart files
Future<void> deleteTerms(ArgResults? argResults) async {
  final bool exportTerms = argResults?['export'];
  final String? outputPath = argResults?['output-path'];

  final files = translationFiles();
  final terms = findUnusedTerms();

  if (terms.isNotEmpty && exportTerms) {
    exportUnusedTerms(terms, outputPath);
  }
  await Future.wait(files.map((file) => _deleteTermsForFile(file, terms)));
  print('${terms.length} terms removed from ${files.length} files each 💪 🚀');
}

Future<void> _deleteTermsForFile(
    FileSystemEntity arbFile, Set<Term> terms) async {
  final fileString = await File(arbFile.path).readAsString();
  Map<String, dynamic> fileJson;
  try {
    fileJson = jsonDecode(fileString) as Map<String, dynamic>;
  } on FormatException catch (e) {
    print('Error parsing ${arbFile.path}: ${e.message}');
    print('Skipping this file. Please fix the JSON syntax and try again.');
    return;
  }
  for (var term in terms) {
    fileJson.remove(term.key);
    if (term.additionalAttributes) {
      fileJson.remove('@${term.key}');
    }
  }
  // Preserve the original indentation from the file
  final indent = detectIndentation(fileString);
  await File(arbFile.path)
      .writeAsString(JsonEncoder.withIndent(indent).convert(fileJson));
}
