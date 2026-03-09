import 'dart:io';

import 'package:test/test.dart';
import 'package:translations_cleaner/src/term_usage_ast.dart';

void main() {
  group('findUsedTermsInSourceWithAst', () {
    test('detects supported getter and method localization usages', () {
      const source = '''
class Widget {
  void build(BuildContext context) {
    final title = AppLocalizations.of(context).welcomeTitle;
    final subtitle = context.l10n.greetingWithName('Sam');
    final body = S.current.bodyText;
    final heading = (context.l10n).pageTitle;
    final chained = controller.localizations.checkoutLabel;
  }
}
''';

      final used = findUsedTermsInSourceWithAst(
        source,
        candidateKeys: {
          'welcomeTitle',
          'greetingWithName',
          'bodyText',
          'pageTitle',
          'checkoutLabel',
          'missingKey',
        },
      );

      expect(
        used,
        containsAll(<String>[
          'welcomeTitle',
          'greetingWithName',
          'bodyText',
          'pageTitle',
          'checkoutLabel',
        ]),
      );
      expect(used, isNot(contains('missingKey')));
    });

    test('deduplicates repeated usages of the same key', () {
      const source = '''
void main(BuildContext context) {
  final first = context.l10n.welcomeTitle;
  final second = context.l10n.welcomeTitle;
  final third = AppLocalizations.of(context).welcomeTitle;
}
''';

      final used = findUsedTermsInSourceWithAst(
        source,
        candidateKeys: {'welcomeTitle'},
      );

      expect(used, equals({'welcomeTitle'}));
    });

    test('ignores comment and string literal mentions', () {
      const source = '''
void main() {
  // welcomeTitle
  const fallback = 'welcomeTitle';
  const rawText = r'greetingWithName';
}
''';

      final used = findUsedTermsInSourceWithAst(
        source,
        candidateKeys: {'welcomeTitle', 'greetingWithName'},
      );

      expect(used, isEmpty);
    });

    test('ignores unrelated identifiers and type members', () {
      const source = '''
class welcomeTitle {}

enum Labels { welcomeTitle }

extension WelcomeTitleExt on String {
  String greetingWithName() => this;
}

void main() {
  const welcomeTitle = 'copy';
  final service = TranslationService();
  service.welcomeTitle();
  final label = Labels.welcomeTitle;
}
''';

      final used = findUsedTermsInSourceWithAst(
        source,
        candidateKeys: {'welcomeTitle', 'greetingWithName'},
      );

      expect(used, isEmpty);
    });

    test('detects bare top-level function invocations for matching keys', () {
      const source = '''
String move_reflection_hint(String a, String b, String c) => '';

List<InlineSpan> moveReflectionHintText(text, upIcon, downIcon) =>
    InlineItem.createInlineSpans(
      move_reflection_hint(text.tagName, upIcon.tagName, downIcon.tagName),
      [text, upIcon, downIcon],
    );
''';

      final used = findUsedTermsInSourceWithAst(
        source,
        candidateKeys: {'move_reflection_hint'},
      );

      expect(used, equals({'move_reflection_hint'}));
    });

    test('ignores near-miss names on localization targets', () {
      const source = '''
void main(BuildContext context) {
  final title = context.l10n.welcomeTitle2;
  final subtitle = AppLocalizations.of(context).greetingWithNameBuilder();
}
''';

      final used = findUsedTermsInSourceWithAst(
        source,
        candidateKeys: {'welcomeTitle', 'greetingWithName'},
      );

      expect(used, isEmpty);
    });

    test('unsupported access patterns are ignored', () {
      const source = '''
void main(BuildContext context) {
  final title = context.t.welcomeTitle;
  final subtitle = Strings.instance.greetingWithName;
  final body = getL10n().bodyText;
  final dynamicValue = translations['checkoutLabel'];
}
''';

      final used = findUsedTermsInSourceWithAst(
        source,
        candidateKeys: {
          'welcomeTitle',
          'greetingWithName',
          'bodyText',
          'checkoutLabel',
        },
      );
      expect(used, isEmpty);
    });
  });

  group('findUsedTermsWithAst', () {
    test('returns null on parser failure for any file', () {
      final tempDir = Directory.systemTemp.createTempSync('ast_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final goodFile = File('${tempDir.path}/good.dart')
        ..writeAsStringSync('''
void main(BuildContext context) {
  final value = context.l10n.greeting;
}
''');

      final badFile = File('${tempDir.path}/bad.dart')
        ..writeAsStringSync('''
void broken(
''');

      final used = findUsedTermsWithAst(
        <FileSystemEntity>[goodFile, badFile],
        {'greeting'},
      );

      expect(used, isNull);
    });
  });
}
