import 'package:translations_cleaner/src/delete_terms.dart';
import 'package:translations_cleaner/src/project_files.dart';
import 'package:translations_cleaner/src/translation_files.dart';
import 'package:translations_cleaner/src/translation_terms.dart';
import 'package:translations_cleaner/src/unused_terms.dart';

void main(List<String> arguments) {
  print('FETCHING ALL THE TRANSLATION TERMS 🌏');
  final terms = getTranslationTerms();
  print('FETCHING ALL THE DART FILES TO LOOK THROUGH 🏗');
  final dartFiles = getDartFiles();
  print('LOOKING THROUGH FILES TO FIND UNUSED TERMS 👀');
  final notUsed = findUnusedTerms(terms, dartFiles);
  print('DELETING ALL THE UNUSED TERMS 🗑');
  deleteTerms(translationFiles(), notUsed);
}
