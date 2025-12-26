## 0.1.0

### Breaking Changes
- **Dart 3.x required**: Updated SDK constraint from `>=2.17.6 <3.0.0` to `>=3.0.0 <4.0.0`
- **Subpackages excluded by default**: Arb files in subpackages (directories with their own pubspec.yaml) are now excluded by default. Use `--include-subpackages` or `-s` flag to include them.

### Bug Fixes
- **Fix #10**: Preserve original indentation when writing arb files instead of forcing 4-space indent
- **Fix #9**: Handle malformed JSON in arb files gracefully with helpful error messages instead of crashing
- **Fix #5**: Use word boundary matching to prevent false negatives (e.g., `restorePurchases` no longer matches `restorePurchasesAsync`)
- **Fix #6, #7, #11**: Exclude subpackages by default to prevent false positives in monorepo setups

## 0.0.5

- Added 2 commands, for showing list of unused translations and for deleting them
- Unused translations can be exported to a `.txt` file to the desired path
- `abort` flag exits process with failure if there are any unused translations. This feature is useful for being used in CI, if the build should fail if there exists any unused translations

## 0.0.1

- Initial version.
