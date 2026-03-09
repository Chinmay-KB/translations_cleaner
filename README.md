# translations_cleaner

Dart package to search and delete unused translations from `.arb` files, for all languages, all in one go.

> NOTE : This package has been developed keeping `flutter_localizations` package in mind, which uses `.arb` files for all translations.

![Package in action](https://github.com/Chinmay-KB/translations_cleaner/blob/main/images/terminal.png?raw=true)

## Usage

```sh
# Add translations_cleaner as a dev dependency
dart pub add --dev translations_cleaner

dart run translations_cleaner <command> [arguments]
# OR
flutter pub run translations_cleaner <command> [arguments]

```

### Commands Available

- `clean-translations` - Search all the translations listed in arb files and delete the unused translations
- `list-unused-terms` - Search all the translations listed in arb files and print/save a list of unused translations.
- `sort-translations` - Sorts all the translations in arb files alphabetically.

### Options Available

Available only for `list-unused-terms`

- `-a, --[no-]abort-on-unused` - Abort execution if unused translations are found. This can be helpful in CI, if you don't want to proceed if a build should fail.

Available for `clean-translations` and `list-unused-terms`

- `-h, --help` - Print this usage information.
- `-o, --output-path` - Path for saving exported file, defaults to root path of the folder
- `-e, --[no-]export` - Save unused keys as a .txt file in the path provided
- `-s, --include-subpackages` - Include arb files from subpackages (directories with their own pubspec.yaml). By default, subpackages are excluded to avoid false positives in monorepo setups.

## Why 🤔

Translations can be a very time consuming process when the app starts to scale and there are lots of translations.
It is a good practice to clean out translations that are not being used.
Checking for unused translations is tedious, hence this package.

## How 🤖

- `translations_cleaner` looks for all the `.arb` files located in the directory, and fetches all the translations, from all the languages.
- Then it looks for all the `.dart` files.
- It parses Dart files with AST and detects key usage from localization-style member access and matching top-level functions.
- The translations not found in the dart files are removed from the corresponding `.arb` files, including any attributes as well

### Detection: regex → AST

Unused keys used to be detected by scanning Dart files as raw text with word-boundary regex. That often marked keys as "used" when they only appeared in comments, string literals, or generated code (e.g. `AppLocalizations` getters). Detection is now **AST-based**: we parse each Dart file and only count a key as used when it appears as a member on a localization-like target (e.g. `context.l10n.someKey`, `AppLocalizations.of(context).someKey`) or as a top-level function call with the same name. That reduces false positives and aligns results with actual usage.

### Performance

- **Regex (old):** Single pass over file contents with precompiled patterns; very fast but prone to false positives.
- **AST (current):** Each Dart file is parsed once; more work per file but only `lib/**/*.dart` is scanned. On large projects you may notice a few extra seconds; `list-unused-terms` prints timing so you can compare.

## Limitations 😔

- This package currently works only for l10n achieved via `flutter_localizations`, which uses `.arb` files.
- There are other l10n packages which use `.json` and `.yaml` for saving translations. These are not supported currently

## Bugs / issues

If you run into bugs or unexpected behavior, please open an issue: [github.com/Chinmay-KB/translations_cleaner/issues](https://github.com/Chinmay-KB/translations_cleaner/issues)
