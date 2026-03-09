import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:translations_cleaner/src/indentation.dart';
import 'package:translations_cleaner/src/translation_files.dart';

Future<void> sortTerms(ArgResults? argResults) async {
  final files = translationFiles();

  await Future.wait(files.map((file) async {
    final contents = await File(file.path).readAsString();
    final sorted = sortContent(contents);
    await File(file.path).writeAsString(sorted);
  }));
}

String sortContent(String contents) {
  final indentation = detectIndentation(contents);
  final Map<String, dynamic> entries = json.decode(contents);

  final sorted = LinkedHashMap.fromEntries(
    entries.entries.toList()
      ..sort(
          (MapEntry<String, dynamic> entryA, MapEntry<String, dynamic> entryB) {
        final String keyA = entryA.key;
        final String keyB = entryB.key;
        if (keyA.startsWith('@@')) {
          return keyB.startsWith('@@') ? keyA.compareTo(keyB) : -1;
        }
        if (keyB.startsWith('@@')) {
          return 1;
        }

        final keyAStartsWithAt = keyA.startsWith('@');
        final keyBStartsWithAt = keyB.startsWith('@');
        if (keyAStartsWithAt || keyBStartsWithAt) {
          final aNoAt = keyAStartsWithAt ? keyA.substring(1) : keyA;
          final bNoAt = keyBStartsWithAt ? keyB.substring(1) : keyB;
          final int compared = aNoAt.compareTo(bNoAt);
          if (compared == 0) {
            return keyAStartsWithAt ? 1 : -1;
          }

          return compared;
        }

        return keyA.compareTo(keyB);
      }),
  );

  final JsonEncoder encoder = JsonEncoder.withIndent(indentation);

  return encoder.convert(sorted);
}
