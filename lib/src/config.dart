import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Config read from the `translations_cleaner:` section of the project's
/// `pubspec.yaml`.
class TranslationsCleanerConfig {
  const TranslationsCleanerConfig({
    this.localizationRoots = const <String>{},
    this.localizationAccessors = const <String>{},
    this.sourcePaths = const <String>['lib'],
    this.ignoreKeys = const <String>{},
  });

  /// Extra localization root class names, added to the built-in defaults
  final Set<String> localizationRoots;

  /// Extra accessor names that resolve to a localization object
  final Set<String> localizationAccessors;

  /// Project directories scanned for key usage, relative to the project root.
  /// Defaults to `lib` only; add `test` to keep keys used exclusively in tests.
  final List<String> sourcePaths;

  /// Keys that are always kept, for usages the syntax scan cannot see
  /// (generated code, dynamic lookups, keys referenced outside [sourcePaths]).
  final Set<String> ignoreKeys;

  /// Reads the config from `<projectRoot>/pubspec.yaml`, defaulting to empty
  /// when the file or section is absent.
  static TranslationsCleanerConfig load({String? projectRoot}) {
    final root = projectRoot ?? Directory.current.path;
    final file = File(p.join(root, 'pubspec.yaml'));
    if (!file.existsSync()) {
      return const TranslationsCleanerConfig();
    }

    Object? parsed;
    try {
      parsed = loadYaml(file.readAsStringSync());
    } catch (_) {
      // Malformed YAML or a read failure falls back to the empty default
      // rather than crashing the command.
      return const TranslationsCleanerConfig();
    }
    if (parsed is! YamlMap) {
      return const TranslationsCleanerConfig();
    }

    final Object? section = parsed['translations_cleaner'];
    if (section is! YamlMap) {
      return const TranslationsCleanerConfig();
    }

    return TranslationsCleanerConfig(
      localizationRoots: _stringSet(section['localization_roots']),
      localizationAccessors: _stringSet(section['localization_accessors']),
      sourcePaths: _stringList(section['source_paths'], const <String>['lib']),
      ignoreKeys: _stringSet(section['ignore_keys']),
    );
  }

  static Set<String> _stringSet(Object? value) {
    if (value is String) {
      return {value};
    }
    if (value is YamlList) {
      return value.whereType<String>().toSet();
    }
    return const <String>{};
  }

  static List<String> _stringList(Object? value, List<String> fallback) {
    if (value is String) {
      return [value];
    }
    if (value is YamlList) {
      final values = value.whereType<String>().toList();
      if (values.isNotEmpty) {
        return values;
      }
    }
    return fallback;
  }
}
