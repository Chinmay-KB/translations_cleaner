import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:translations_cleaner/src/models/term.dart';
import 'package:translations_cleaner/src/unused_terms.dart';

final Directory _fixturesRoot = Directory(
  p.join(Directory.current.path, 'test', 'fixtures', 'ast_detection'),
);

void main() {
  group('findUnusedTerms', () {
    test('supports happy-path aliases and chaining', () {
      final unused = _runInFixtureProject(
        'happy_path_project',
        () => findUnusedTerms(),
      );

      expect(_unusedKeys(unused), equals({'unusedKey'}));
    });

    test('rejects comment and symbol false positives', () {
      final unused = _runInFixtureProject(
        'false_positive_project',
        () => findUnusedTerms(),
      );

      expect(
        _unusedKeys(unused),
        equals({'welcomeTitle', 'greetingWithName', 'bodyText'}),
      );
    });

    test('fails loudly when parsing fails', () {
      expect(
        () => _runInFixtureProject(
          'parse_error_project',
          () => findUnusedTerms(),
        ),
        throwsStateError,
      );
    });

    test('unsupported patterns stay unused', () {
      final unused = _runInFixtureProject(
        'unsupported_pattern_project',
        () => findUnusedTerms(),
      );

      expect(
        _unusedKeys(unused),
        equals({'shortcutKey', 'dynamicKey', 'reallyUnused'}),
      );
    });
  });
}

Set<String> _unusedKeys(Set<Term> terms) => terms.map((term) => term.key).toSet();

T _runInFixtureProject<T>(String fixtureName, T Function() action) {
  final tempDir = Directory.systemTemp.createTempSync(
    'translations_cleaner_fixture_',
  );
  addTearDown(() => tempDir.deleteSync(recursive: true));

  final fixtureDir = Directory(p.join(_fixturesRoot.path, fixtureName));
  _copyDirectoryContents(fixtureDir, tempDir);

  final previousDirectory = Directory.current;
  Directory.current = tempDir.path;
  try {
    return action();
  } finally {
    Directory.current = previousDirectory.path;
  }
}

void _copyDirectoryContents(Directory source, Directory destination) {
  for (final entity in source.listSync(recursive: true)) {
    final relativePath = p.relative(entity.path, from: source.path);
    final targetPath = p.join(destination.path, relativePath);

    if (entity is Directory) {
      Directory(targetPath).createSync(recursive: true);
      continue;
    }

    if (entity is File) {
      File(targetPath).parent.createSync(recursive: true);
      entity.copySync(targetPath);
    }
  }
}
