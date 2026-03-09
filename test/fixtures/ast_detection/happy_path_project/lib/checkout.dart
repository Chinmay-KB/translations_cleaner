class AppStrings {
  String get bodyText => 'Body';

  String get checkoutLabel => 'Checkout';
}

class S {
  static AppStrings get current => AppStrings();
}

class FeatureController {
  AppStrings get localizations => AppStrings();
}

class CheckoutController {
  final controller = FeatureController();

  void render() {
    final body = S.current.bodyText;
    final label = controller.localizations.checkoutLabel;
  }
}
