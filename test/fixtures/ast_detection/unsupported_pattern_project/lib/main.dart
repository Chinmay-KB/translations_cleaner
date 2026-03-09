class BuildContext {}

class AppStrings {
  String get shortcutKey => 'Shortcut';

  String get dynamicKey => 'Dynamic';
}

extension UnsupportedL10n on BuildContext {
  AppStrings get t => AppStrings();
}

AppStrings getL10n() => AppStrings();

void main(BuildContext context, Map<String, String> translations) {
  final shortcut = context.t.shortcutKey;
  final dynamicValue = getL10n().dynamicKey;
  final fromMap = translations['dynamicKey'];
}
