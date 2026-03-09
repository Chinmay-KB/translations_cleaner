class BuildContext {}

class AppLocalizations {
  static AppLocalizations of(BuildContext context) => AppLocalizations();

  String get welcomeTitle => 'Welcome';
}

extension BuildContextL10n on BuildContext {
  AppStrings get l10n => AppStrings();
}

class AppStrings {
  String greetingWithName(String name) => 'Hello $name';

  String get pageTitle => 'Page title';
}

class Widget {
  void build(BuildContext context) {
    final title = AppLocalizations.of(context).welcomeTitle;
    final subtitle = context.l10n.greetingWithName('Sam');
    final heading = (context.l10n).pageTitle;
  }
}
