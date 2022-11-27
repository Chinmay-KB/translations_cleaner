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

### Options Available

Available only for `list-unused-terms`

- `-a, --[no-]abort-on-unused` - Abort execution if unused translations are found. This can be helpful in CI, if you don't want to proceed if a build should fail.

Available for both commands

- `-h, --help` - Print this usage information.
- `-o, --output-path` - Path for saving exported file, defaults to root path of the folder
- `-e, --[no-]export ` - Save unused keys as a .txt file in the path provided

## Why 🤔

Translations can be a very time taking process when the app starts to scale and there are a lot many translations.
Hence it is a good practice to clean the translations if it is not being used.
Checking for unused translations is tedious, hence this package.

## How 🤖

- `translations_cleaner` looks for all the `.arb` files located in the directory, and fetches all the translations, from all the languages.
- Then it looks for all the `.dart` files.
- All the translation terms are looked for in these dart files
- The translations not found in the dart files are removed from the corresponding `.arb` files, including any attributes as well

## Limitations 😔

- This package currently works only for l10n achieved via `flutter_localizations`, which uses `.arb` files.
- There are other l10n packages which use `.json` and `.yaml` for saving translations. These are not supported currently
