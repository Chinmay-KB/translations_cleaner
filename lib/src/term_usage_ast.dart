import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';

/// Returns used translation keys from Dart files using a syntax-only scan.
///
/// [extraRoots] and [extraAccessors] extend the built-in localization roots and
/// accessor names for projects with a custom localization wrapper.
///
/// Returns `null` when parsing fails for any file so callers can decide how to
/// handle the failure.
Set<String>? findUsedTermsWithAst(
  List<FileSystemEntity> dartFiles,
  Set<String> candidateKeys, {
  Set<String> extraRoots = const <String>{},
  Set<String> extraAccessors = const <String>{},
}) {
  final usedKeys = <String>{};

  for (final file in dartFiles) {
    final source = File(file.path).readAsStringSync();
    final parseResult = parseString(
      content: source,
      path: file.path,
      throwIfDiagnostics: false,
    );

    final hasSyntacticError = parseResult.errors.any(
      (diagnostic) =>
          diagnostic.diagnosticCode.type == DiagnosticType.SYNTACTIC_ERROR,
    );
    if (hasSyntacticError) {
      return null;
    }

    parseResult.unit.visitChildren(
      _TranslationUsageVisitor(
        candidateKeys: candidateKeys,
        usedKeys: usedKeys,
        extraRoots: extraRoots,
        extraAccessors: extraAccessors,
      ),
    );
  }

  return usedKeys;
}

/// Exposed for unit tests and for future in-memory callers.
Set<String> findUsedTermsInSourceWithAst(
  String source, {
  required Set<String> candidateKeys,
  Set<String> extraRoots = const <String>{},
  Set<String> extraAccessors = const <String>{},
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
      extraRoots: extraRoots,
      extraAccessors: extraAccessors,
    ),
  );

  return usedKeys;
}

class _TranslationUsageVisitor extends RecursiveAstVisitor<void> {
  _TranslationUsageVisitor({
    required this.candidateKeys,
    required this.usedKeys,
    Set<String> extraRoots = const <String>{},
    Set<String> extraAccessors = const <String>{},
  })  : _rootNames = {..._defaultRootNames, ...extraRoots},
        _accessorNames = {..._defaultAccessorNames, ...extraAccessors};

  final Set<String> candidateKeys;
  final Set<String> usedKeys;

  final Set<String> _rootNames;
  final Set<String> _accessorNames;

  // Local variable names declared with a root type (`final S s = R.instance;`).
  final Set<String> _localAliasNames = <String>{};

  static const Set<String> _defaultAccessorNames = {
    'l10n',
    'loc',
    'locale',
    'strings',
    'translations',
    'localizations',
    'intl',
    'current',
  };

  static const Set<String> _defaultRootNames = {
    'AppLocalizations',
    'S',
    'L10n',
    'I18n',
  };

  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    final type = node.type;
    if (type is NamedType && _rootNames.contains(type.name.lexeme)) {
      for (final variable in node.variables) {
        _localAliasNames.add(variable.name.lexeme);
      }
    }
    super.visitVariableDeclarationList(node);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    final type = node.type;
    final name = node.name;
    if (name != null &&
        type is NamedType &&
        _rootNames.contains(type.name.lexeme)) {
      _localAliasNames.add(name.lexeme);
    }
    super.visitSimpleFormalParameter(node);
  }

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
      return _accessorNames.contains(expression.name) ||
          _localAliasNames.contains(expression.name);
    }

    if (expression is PrefixedIdentifier) {
      return _rootNames.contains(expression.prefix.name) ||
          _accessorNames.contains(expression.identifier.name) ||
          _accessorNames.contains(expression.prefix.name) ||
          _isLikelyLocalizationTarget(expression.prefix);
    }

    if (expression is PropertyAccess) {
      return _accessorNames.contains(expression.propertyName.name) ||
          _isLikelyLocalizationTarget(expression.target);
    }

    if (expression is MethodInvocation) {
      final target = expression.target;
      final isOfFactory =
          expression.methodName.name == 'of' && _isRootReference(target);
      return isOfFactory ||
          _accessorNames.contains(expression.methodName.name) ||
          _isLikelyLocalizationTarget(target);
    }

    return false;
  }

  bool _isRootReference(Expression? expression) {
    if (expression is SimpleIdentifier) {
      return _rootNames.contains(expression.name);
    }
    if (expression is PrefixedIdentifier) {
      return _rootNames.contains(expression.identifier.name);
    }
    return false;
  }
}
