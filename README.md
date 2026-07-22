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

### Custom localization roots

The AST scan recognises the common localization roots (`AppLocalizations`, `S`, `L10n`, `I18n`) and accessors (`l10n`, `loc`, `strings`, `translations`, …) out of the box. If your project wraps localizations in its own class — say `R` — add a `translations_cleaner:` section to your project's `pubspec.yaml`:

```yaml
translations_cleaner:
  localization_roots:
    - R
  localization_accessors:
    - copy
```

- `localization_roots` — class names that hold translations, e.g. `R.instance.welcomeTitle` or `R.of(context).welcomeTitle`.
- `localization_accessors` — property/getter names that resolve to a localization object, e.g. `context.copy.welcomeTitle`.

Both lists **extend** the built-in defaults rather than replacing them, and both are optional. Declaring a root also picks up values typed with it, so keys stay detected when the object is passed around:

```dart
final S s = R.instance;      // local variable typed as a root
String title(S s) => s.welcomeTitle;   // parameter typed as a root
login.S.of(context).welcomeTitle;      // root reached through a prefixed import
```

Without this config a custom root is **not** guessed at — its keys would be reported as unused and then deleted by `clean-translations`.

### Scanned paths and ignored keys

The same `translations_cleaner:` section accepts two more optional settings:

```yaml
translations_cleaner:
  source_paths:
    - lib
    - test
  ignore_keys:
    - dynamicKey
```

- `source_paths` — directories scanned for key usage, relative to the project root. Defaults to `[lib]`; add `test` to keep keys that are used only in tests.
- `ignore_keys` — keys that are always kept, for usages the syntax scan cannot see (generated code, dynamic lookups, or keys referenced outside `source_paths`).

### Performance

- **Regex (old):** Single pass over file contents with precompiled patterns; very fast but prone to false positives.
- **AST (current):** Each Dart file is parsed once; more work per file but only `lib/**/*.dart` is scanned. On large projects you may notice a few extra seconds; `list-unused-terms` prints timing so you can compare.

### Known limitations

The AST scan is syntax-only — it does not resolve types — so a few patterns are out of reach:

- Local alias names are tracked for the whole file. An earlier `S s = ...` alias and a later, unrelated `Other s` sharing the same variable name can produce a false positive.
- Untyped locals and casts are not detected, e.g. `final s = S.of(ctx); s.key`. This is expected for a syntax-only scan; typed aliases (`final S s = S.of(ctx)`) cover the common case.

## Limitations 😔

- This package currently works only for l10n achieved via `flutter_localizations`, which uses `.arb` files.
- There are other l10n packages which use `.json` and `.yaml` for saving translations. These are not supported currently

## Bugs / issues

If you run into bugs or unexpected behavior, please open an issue: [github.com/Chinmay-KB/translations_cleaner/issues](https://github.com/Chinmay-KB/translations_cleaner/issues)
