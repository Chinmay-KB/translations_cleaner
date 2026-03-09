import 'package:args/command_runner.dart';
import 'package:translations_cleaner/src/sort_terms.dart';

/// Command for sorting the translation files
class SortTranslations extends Command {
  @override
  String get description =>
      'Sorts all the translations listed in arb files';

  @override
  String get name => 'sort-translations';

  @override
  void run() => sortTerms(argResults);
}
