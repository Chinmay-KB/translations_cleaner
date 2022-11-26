import 'dart:convert';
import 'dart:io';

import 'package:translations_cleaner/src/models/term.dart';

/// Delete unused terms from the dart files
Future<void> deleteTerms(List<FileSystemEntity> files, Set<Term> terms) async {
  await Future.wait(files.map((file) => _deleteTermsForFile(file, terms)));
  print('${terms.length} terms removed from ${files.length} files each 💪🚀');
}

Future<void> _deleteTermsForFile(
    FileSystemEntity arbFile, Set<Term> terms) async {
  final fileString = await File(arbFile.path).readAsString();
  final Map<String, dynamic> fileJson = jsonDecode(fileString);
  for (var term in terms) {
    fileJson.remove(term.key);
    if (term.additionalAttributes) {
      fileJson.remove('@${term.key}');
    }
  }
  // Indent is being used for proper formatting
  await File(arbFile.path)
      .writeAsString(JsonEncoder.withIndent(' ' * 4).convert(fileJson));
}
