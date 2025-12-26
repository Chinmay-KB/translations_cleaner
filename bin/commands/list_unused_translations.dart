import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:translations_cleaner/src/export_unused_terms.dart';
import 'package:translations_cleaner/src/subpackage_detection.dart';
import 'package:translations_cleaner/src/unused_terms.dart';

/// Command for listing and exporting unused translations
class ListUnusedTranslations extends Command {
  ListUnusedTranslations() {
    argParser.addOption('output-path',
        abbr: 'o',
        help: 'Path for saving exported '
            'file, defaults to root path of the folder');
    argParser.addFlag('export',
        help: 'Save unused keys as a .txt file'
            'in the path provided',
        abbr: 'e');
    argParser.addFlag('abort-on-unused',
        abbr: 'a',
        help: 'Abort execution if '
            'unused translations are found. This can be helpful in CI, if you '
            'don\'t want to proceed if a build should fail');
    argParser.addFlag('include-subpackages',
        help: 'Include arb files from subpackages (directories with their own '
            'pubspec.yaml). By default, subpackages are excluded to avoid '
            'false positives in monorepo setups.',
        abbr: 's',
        negatable: false);
  }

  @override
  String get description =>
      'Search all the translations listed in arb files and '
      'print/save a list of unused translations';

  @override
  String get name => 'list-unused-terms';

  @override
  void run() async {
    includeSubpackages = argResults?['include-subpackages'] ?? false;
    final bool abort = argResults?['abort-on-unused'];
    final bool exportTerms = argResults?['export'];
    final String? outputPath = argResults?['output-path'];
    final notUsed = findUnusedTerms();
    if (notUsed.isNotEmpty && abort) {
      print('❌ ${notUsed.length} unused translations found, aborting ❌');
      exitCode = 1;
      exit(exitCode);
    }
    if (exportTerms) {
      exportUnusedTerms(notUsed, outputPath);
    } else {
      for (var term in notUsed) {
        print(term.key);
      }
      print('Total ${notUsed.length} unused keys ✅');
    }
  }
}
