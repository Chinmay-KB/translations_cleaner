class BuildContext {}

extension BuildContextL10n on BuildContext {
  AppStrings get l10n => AppStrings();
}

class AppStrings {
  String get welcomeTitle => 'Welcome';
}

void main(BuildContext context) {
  final title = context.l10n.welcomeTitle;
}
