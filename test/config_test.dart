import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:translations_cleaner/src/config.dart';

void main() {
  group('TranslationsCleanerConfig.load', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('config_test_');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    void writePubspec(String contents) {
      File(p.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync(contents);
    }

    test('reads list-form settings', () {
      writePubspec('''
name: example
translations_cleaner:
  localization_roots:
    - R
    - S
  localization_accessors:
    - copy
  source_paths:
    - lib
    - test
  ignore_keys:
    - dynamicKey
''');

      final config = TranslationsCleanerConfig.load(projectRoot: tempDir.path);

      expect(config.localizationRoots, equals({'R', 'S'}));
      expect(config.localizationAccessors, equals({'copy'}));
      expect(config.sourcePaths, equals(['lib', 'test']));
      expect(config.ignoreKeys, equals({'dynamicKey'}));
    });

    test('coerces bare scalar values into single-element collections', () {
      writePubspec('''
name: example
translations_cleaner:
  localization_roots: R
  ignore_keys: foo
  source_paths: test
''');

      final config = TranslationsCleanerConfig.load(projectRoot: tempDir.path);

      expect(config.localizationRoots, equals({'R'}));
      expect(config.ignoreKeys, equals({'foo'}));
      expect(config.sourcePaths, equals(['test']));
    });

    test('returns defaults when the section is absent', () {
      writePubspec('name: example\n');

      final config = TranslationsCleanerConfig.load(projectRoot: tempDir.path);

      expect(config.localizationRoots, isEmpty);
      expect(config.localizationAccessors, isEmpty);
      expect(config.ignoreKeys, isEmpty);
      expect(config.sourcePaths, equals(['lib']));
    });

    test('returns defaults without throwing on malformed YAML', () {
      writePubspec('name: example\n  : : broken\n:::not valid yaml');

      final config = TranslationsCleanerConfig.load(projectRoot: tempDir.path);

      expect(config.localizationRoots, isEmpty);
      expect(config.localizationAccessors, isEmpty);
      expect(config.ignoreKeys, isEmpty);
      expect(config.sourcePaths, equals(['lib']));
    });

    test('returns defaults when pubspec.yaml is missing', () {
      final config = TranslationsCleanerConfig.load(projectRoot: tempDir.path);

      expect(config.localizationRoots, isEmpty);
      expect(config.localizationAccessors, isEmpty);
      expect(config.ignoreKeys, isEmpty);
      expect(config.sourcePaths, equals(['lib']));
    });
  });
}
