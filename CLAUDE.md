# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Dart CLI package to find and remove unused translation keys from `.arb` files in Flutter projects using `flutter_localizations`.

## Common Commands

```sh
# Get dependencies
dart pub get

# Run the package locally (from a Flutter project directory)
dart run translations_cleaner clean-translations
dart run translations_cleaner list-unused-terms

# Run with options
dart run translations_cleaner list-unused-terms --export --output-path=/path
dart run translations_cleaner list-unused-terms --abort-on-unused  # For CI
dart run translations_cleaner list-unused-terms --include-subpackages  # Include monorepo subpackages

# Run static analysis
dart analyze
```

## Architecture

The package is a CLI tool built with `package:args` for command parsing and `package:glob` for file discovery.

### Entry Point & Commands
- `bin/translations_cleaner.dart` - Main entry point, registers commands via `CommandRunner`
- `bin/commands/` - Command implementations:
  - `clean_translation.dart` - Deletes unused translations from arb files
  - `list_unused_translations.dart` - Lists/exports unused translations (supports `--abort-on-unused` for CI)

### Core Logic (lib/src/)
- `unused_terms.dart` - Core algorithm: finds unused terms by scanning `.arb` files for translation keys, then checking if each key appears in any `.dart` file under `lib/` using word boundary regex matching
- `translation_files.dart` - Glob-based discovery of `.arb` files in project (excludes subpackages by default)
- `project_files.dart` - Glob-based discovery of all `.dart` files under `lib/`
- `translation_terms.dart` - Parses `.arb` JSON files, extracts translation keys (ignoring `@`-prefixed metadata keys)
- `delete_terms.dart` - Removes unused keys (and their `@key` attributes) from all arb files, preserving original indentation
- `export_unused_terms.dart` - Writes unused keys to `unused-translations.txt`
- `subpackage_detection.dart` - Detects subpackages (directories with pubspec.yaml) to exclude from scanning
- `models/term.dart` - `Term` class with key name and whether it has `@` attributes

### How Detection Works
1. Scan `.arb` files (excluding subpackages by default), extract non-`@` keys as translation terms
2. Scan all `lib/**.dart` files
3. For each term, check if `term.key` matches as a whole word (using `\b` word boundaries) in any dart file
4. Terms not found in any dart file are considered unused
