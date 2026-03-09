class welcomeTitle {}

enum Labels { greetingWithName }

extension BodyTextExtension on String {
  String bodyText() => this;
}

void main() {
  // welcomeTitle
  const greeting = 'greetingWithName';
  final service = TranslationService();
  service.bodyText();
  final label = Labels.greetingWithName;
}

class TranslationService {
  void bodyText() {}
}
