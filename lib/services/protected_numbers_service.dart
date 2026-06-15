import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/protected_number.dart';

/// Manages the list of phone numbers that require PIN entry before calling.
class ProtectedNumbersService {
  static const _key = 'protected_numbers';

  static Future<List<ProtectedNumber>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => ProtectedNumber.fromJson(jsonDecode(s)))
        .toList();
  }

  static Future<void> add(ProtectedNumber number) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();

    final normalizedNew = ProtectedNumber.normalize(number.number);
    final exists = current.any(
      (n) => ProtectedNumber.normalize(n.number) == normalizedNew,
    );
    if (exists) return;

    current.add(number);
    await prefs.setStringList(
      _key,
      current.map((n) => jsonEncode(n.toJson())).toList(),
    );
  }

  static Future<void> remove(ProtectedNumber number) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getAll();
    final normalizedTarget = ProtectedNumber.normalize(number.number);

    current.removeWhere(
      (n) => ProtectedNumber.normalize(n.number) == normalizedTarget,
    );

    await prefs.setStringList(
      _key,
      current.map((n) => jsonEncode(n.toJson())).toList(),
    );
  }

  static Future<bool> isProtected(String number) async {
    final current = await getAll();
    final normalizedTarget = ProtectedNumber.normalize(number);
    return current.any(
      (n) => ProtectedNumber.normalize(n.number) == normalizedTarget,
    );
  }
}
