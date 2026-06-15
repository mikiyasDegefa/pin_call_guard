import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles secure-ish storage and verification of the user's PIN.
/// The PIN is stored as a SHA-256 hash, never in plain text.
class PinService {
  static const _pinHashKey = 'pin_hash';

  static String _hash(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();
  }

  /// Returns true if a PIN has been set up already.
  static Future<bool> hasPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pinHashKey);
  }

  /// Sets (or overwrites) the PIN.
  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinHashKey, _hash(pin));
  }

  /// Verifies the entered PIN against the stored hash.
  static Future<bool> verifyPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString(_pinHashKey);
    if (storedHash == null) return false;
    return storedHash == _hash(pin);
  }

  /// Removes the stored PIN (used when resetting).
  static Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinHashKey);
  }
}
