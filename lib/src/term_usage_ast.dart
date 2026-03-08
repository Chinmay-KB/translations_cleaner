import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Returns used translation keys from Dart files using a syntax-only scan.
///
/// Returns `null` when parsing fails for any file so callers can fall back
/// to another detection strategy.
Set<String>? findUsedTermsWithAst(
  List<FileSystemEntity> dartFiles,
  Set<String> candidateKeys,
) {
  final usedKeys = <String>{};

  for (final file in dartFiles) {
    final source = File(file.path).readAsStringSync();
    final parseResult = parseString(
      content: source,
      path: file.path,
      throwIfDiagnostics: false,
    );

    final hasSyntacticError = parseResult.errors.any(
      (error) => error.errorCode.type == ErrorType.SYNTACTIC_ERROR,
    );
    if (hasSyntacticError) {
      return null;
    }

    parseResult.unit.visitChildren(
      _TranslationUsageVisitor(
        candidateKeys: candidateKeys,
        usedKeys: usedKeys,
      ),
    );
  }

  return usedKeys;
}

/// Exposed for unit tests and for future in-memory callers.
Set<String> findUsedTermsInSourceWithAst(
  String source, {
  required Set<String> candidateKeys,
}) {
  final parseResult = parseString(
    content: source,
    throwIfDiagnostics: false,
  );
  final usedKeys = <String>{};

  parseResult.unit.visitChildren(
    _TranslationUsageVisitor(
      candidateKeys: candidateKeys,
      usedKeys: usedKeys,
    ),
  );

  return usedKeys;
}

class _TranslationUsageVisitor extends RecursiveAstVisitor<void> {
  _TranslationUsageVisitor({
    required this.candidateKeys,
    required this.usedKeys,
  });

  final Set<String> candidateKeys;
  final Set<String> usedKeys;

  static const Set<String> _localizationAccessorNames = {
    'l10n',
    'loc',
    'locale',
    'strings',
    'translations',
    'localizations',
    'intl',
    'current',
  };

  static const Set<String> _localizationRootNames = {
    'AppLocalizations',
    'S',
    'L10n',
    'I18n',
  };

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final key = node.propertyName.name;
    if (_isCandidate(key) && _isLikelyLocalizationTarget(node.target)) {
      usedKeys.add(key);
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final key = node.identifier.name;
    if (_isCandidate(key) && _isLikelyLocalizationTarget(node.prefix)) {
      usedKeys.add(key);
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final key = node.methodName.name;
    final target = node.target;
    final isBareFunctionCall = target == null;

    if (_isCandidate(key) &&
        (_isLikelyLocalizationTarget(target) || isBareFunctionCall)) {
      usedKeys.add(key);
    }
    super.visitMethodInvocation(node);
  }

  bool _isCandidate(String value) => candidateKeys.contains(value);

  bool _isLikelyLocalizationTarget(Expression? expression) {
    if (expression == null) {
      return false;
    }

    if (expression is ParenthesizedExpression) {
      return _isLikelyLocalizationTarget(expression.expression);
    }

    if (expression is SimpleIdentifier) {
      return _localizationAccessorNames.contains(expression.name);
    }

    if (expression is PrefixedIdentifier) {
      return _localizationAccessorNames.contains(expression.identifier.name) ||
          _localizationAccessorNames.contains(expression.prefix.name) ||
          _isLikelyLocalizationTarget(expression.prefix);
    }

    if (expression is PropertyAccess) {
      return _localizationAccessorNames.contains(expression.propertyName.name) ||
          _isLikelyLocalizationTarget(expression.target);
    }

    if (expression is MethodInvocation) {
      final target = expression.target;
      final isOfFactory = expression.methodName.name == 'of' &&
          target is SimpleIdentifier &&
          _localizationRootNames.contains(target.name);
      return isOfFactory ||
          _localizationAccessorNames.contains(expression.methodName.name) ||
          _isLikelyLocalizationTarget(target);
    }

    return false;
  }
}
