import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:translations_cleaner/src/export_unused_terms.dart';
import 'package:translations_cleaner/src/models/term.dart';
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

/// Detects the indentation used in a JSON file by looking at the first
/// indented line after the opening brace.
String _detectIndentation(String content) {
  final lines = content.split('\n');
  for (var i = 1; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isNotEmpty) {
      final match = RegExp(r'^(\s+)').firstMatch(line);
      if (match != null) {
        return match.group(1)!;
      }
      break;
    }
  }
  // Default to 4 spaces if no indentation detected
  return '    ';
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
  final indent = _detectIndentation(fileString);
  await File(arbFile.path)
      .writeAsString(JsonEncoder.withIndent(indent).convert(fileJson));
}
