import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:console_bars/console_bars.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';

const lineNumber = 'line-number';

void main(List<String> arguments) {
  exitCode = 0; // presume success

  final currentPath = Directory.current.path;

  // ArgResults argResults = parser.parse(arguments);
  // final paths = argResults.rest;
  final terms = getTranslationTerms(currentPath);
  final dartFiles = getDartFiles(currentPath);
  final notUsed = findNotUsedArbTerms(terms, dartFiles);
  for (final t in notUsed) {
    print(t);
  }
  print('Total ununsed keys : ${notUsed.length}');
}

Set<String> getTranslationTerms(String path) {
  final arbFile = Glob("$path/**.arb");
  final arbFiles = <FileSystemEntity>[];
  final keys = arbFile.listSync(followLinks: false);

  for (var entity in keys) {
    arbFiles.add(entity);
  }

  final arbTerms = <String>{};
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
        arbTerms.add(entry.key);
      }
    }
  }
  return arbTerms;
}

List<FileSystemEntity> getDartFiles(String path) {
  final dartFile = Glob("$path/lib/**.dart");
  final dartFiles = <FileSystemEntity>[];
  for (var entity in dartFile.listSync(followLinks: false)) {
    dartFiles.add(entity);
  }

  return dartFiles;
}

Set<String> findNotUsedArbTerms(
  Set<String> arbTerms,
  List<FileSystemEntity> files,
) {
  final unused = arbTerms.toSet();
  final p = FillingBar(
      desc: "Checking for ununsed keys",
      width: 50,
      total: arbTerms.length * files.length,
      percentage: true);
  for (final file in files) {
    final content = File(file.path).readAsStringSync();
    for (final arb in arbTerms) {
      p.increment();

      if (content.contains(arb)) {
        unused.remove(arb);
      }
    }
  }
  return unused;
}
