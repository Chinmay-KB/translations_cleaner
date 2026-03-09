import 'dart:math';

const _defaultIndent = '    ';
const _maxLinesToCheck = 10;
final _indentRegExp = RegExp(r'^(\s+)');

/// Detects the indentation used in a JSON file by looking for the first
/// indented line after the opening brace, limited to 10 lines.
String detectIndentation(String content) {
  final lines = content.split('\n');
  final linesToCheck = min(lines.length, _maxLinesToCheck);
  for (var i = 1; i < linesToCheck; i++) {
    final line = lines[i];
    if (line.trim().isNotEmpty) {
      final match = _indentRegExp.firstMatch(line);
      if (match != null) {
        return match.group(1)!;
      }
      break;
    }
  }
  // Default to 4 spaces if no indentation detected
  return _defaultIndent;
}
