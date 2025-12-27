import 'package:args/command_runner.dart';
import 'package:translations_cleaner/src/delete_terms.dart';
import 'package:translations_cleaner/src/subpackage_detection.dart';

/// Command for cleaning the translation files from all the unused translations
class CleanTranslation extends Command {
  CleanTranslation() {
    argParser.addOption('output-path',
        abbr: 'o',
        help: 'Path for saving exported '
            'file, defaults to root path of the folder');
    argParser.addFlag('export',
        help: 'Save unused keys as a .txt file'
            'in the path provided',
        abbr: 'e');
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
      'delete the unused translations';

  @override
  String get name => 'clean-translations';

  @override
  void run() {
    includeSubpackages = argResults?['include-subpackages'] ?? false;
    deleteTerms(argResults);
  }
}
