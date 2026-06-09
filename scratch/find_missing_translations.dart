import 'dart:io';
import 'dart:convert';

void main() async {
  final libDir = Directory('lib');
  final arbFile = File('lib/l10n/app_en.arb');
  final extFile = File('lib/core/localization/app_localizations.dart');

  if (!await libDir.exists() || !await arbFile.exists() || !await extFile.exists()) {
    print('Error: Missing files/directories');
    return;
  }

  // Extract all used keys in Dart files
  final RegExp trRegex = RegExp(r"(?:\.tr\(|tr\()\s*['" + '"' + r"]([^'" + '"' + r"]+)['" + '"' + r"]");
  final Set<String> usedKeys = {};

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart') && !entity.path.contains('app_localizations.dart')) {
      final content = await entity.readAsString();
      final matches = trRegex.allMatches(content);
      for (final match in matches) {
        if (match.groupCount >= 1) {
          usedKeys.add(match.group(1)!);
        }
      }
    }
  }

  // Extract all keys from ARB file
  final arbContent = await arbFile.readAsString();
  final Map<String, dynamic> arbJson = jsonDecode(arbContent);
  final Set<String> arbKeys = arbJson.keys.where((k) => !k.startsWith('@')).toSet();

  // Extract all case keys from extension file
  final extContent = await extFile.readAsString();
  final RegExp caseRegex = RegExp(r"case\s+['" + '"' + r"]([^'" + '"' + r"]+)['" + '"' + r"]:");
  final Set<String> switchKeys = {};
  final matches = caseRegex.allMatches(extContent);
  for (final match in matches) {
    if (match.groupCount >= 1) {
      switchKeys.add(match.group(1)!);
    }
  }

  // Find missing in ARB
  final missingInArb = usedKeys.difference(arbKeys);
  print('--- Missing in ARB (${missingInArb.length}) ---');
  for (final k in missingInArb) {
    print(k);
  }

  // Find missing in switch statement
  final missingInSwitch = usedKeys.difference(switchKeys);
  print('\n--- Missing in Switch (${missingInSwitch.length}) ---');
  for (final k in missingInSwitch) {
    print(k);
  }
}
