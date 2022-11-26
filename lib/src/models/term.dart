/// Model used to store data related to the unused terms present in the `.arb`
/// files in the project.
class Term {
  Term({required this.additionalAttributes, required this.key});

  /// Name of the translation
  final String key;

  /// Whether the translation has any attributes, which starts with a "@"
  final bool additionalAttributes;

  int? _hashcode;

  /// Necessary override for [Set] to compare [Term] objects and determine
  /// equality
  @override
  bool operator ==(other) {
    if (other is! Term) {
      return false;
    }
    final otherTerm = other;
    return otherTerm.key == key &&
        otherTerm.additionalAttributes == additionalAttributes;
  }

  @override
  int get hashCode {
    _hashcode ??= key.hashCode;
    return _hashcode!;
  }
}
