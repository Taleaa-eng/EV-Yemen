import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/business_document.dart';
import '../../core/services/auth_validators.dart';

class ProviderLocalStore extends ChangeNotifier {
  ProviderLocalStore._();
  static final ProviderLocalStore instance = ProviderLocalStore._();

  String subtype = 'صاحب ورشة';
  Map<String, String> profile = {};
  Map<String, bool> notifications = {
    'reviews': true,
    'account': true,
    'offers': false,
  };
  bool available = true;
  double latitude = 15.3694;
  double longitude = 44.1910;
  Map<String, BusinessDocument> documents = {};

  String get _prefix =>
      'ev_yemen.provider.${subtype == 'صاحب ورشة' ? 'workshop' : 'parts'}';

  Future<void> load(String value) async {
    subtype = value;
    final prefs = await SharedPreferences.getInstance();
    try {
      profile = Map<String, String>.from(
        (jsonDecode(prefs.getString('$_prefix.profile') ?? '{}') as Map)
            .map((key, value) => MapEntry('$key', '$value')),
      );
      notifications = Map<String, bool>.from(
        (jsonDecode(prefs.getString('$_prefix.notifications') ??
                '{"reviews":true,"account":true,"offers":false}') as Map)
            .map((key, value) => MapEntry('$key', value == true)),
      );
      final rawDocuments = prefs.getString('$_prefix.documents');
      documents = rawDocuments == null
          ? {}
          : (jsonDecode(rawDocuments) as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                BusinessDocument.fromJson(
                    Map<String, dynamic>.from(value as Map)),
              ),
            );
    } catch (_) {
      profile = {};
      documents = {};
      notifications = {
        'reviews': true,
        'account': true,
        'offers': false,
      };
    }
    available = prefs.getBool('$_prefix.available') ?? true;
    latitude = prefs.getDouble('$_prefix.latitude') ?? 15.3694;
    longitude = prefs.getDouble('$_prefix.longitude') ?? 44.1910;
    notifyListeners();
  }

  Future<void> saveProfile(Map<String, String> value) async {
    profile = Map.of(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.profile', jsonEncode(profile));
    notifyListeners();
  }

  Future<void> saveDocuments(Map<String, BusinessDocument> value) async {
    documents = Map.of(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix.documents',
      jsonEncode(
          documents.map((key, document) => MapEntry(key, document.toJson()))),
    );
    notifyListeners();
  }

  Future<void> saveCredentials({
    required String phone,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256))
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    final verifier = sha256.convert(utf8.encode('$salt:$password')).toString();
    await prefs.setString(
        '$_prefix.auth',
        jsonEncode({
          'phone': normalizeYemenPhone(phone),
          'salt': salt,
          'verifier': verifier,
        }));
  }

  Future<bool> authenticate({
    required String phone,
    required String password,
  }) async {
    if (!isValidYemenPhone(phone) || !isValidPassword(password)) return false;
    final prefs = await SharedPreferences.getInstance();
    try {
      final record = jsonDecode(prefs.getString('$_prefix.auth') ?? '{}')
          as Map<String, dynamic>;
      final salt = record['salt'] as String? ?? '';
      final storedPhone = record['phone'] as String? ?? '';
      final verifier = record['verifier'] as String? ?? '';
      if (salt.isEmpty || verifier.isEmpty || storedPhone.isEmpty) return false;
      final candidate =
          sha256.convert(utf8.encode('$salt:$password')).toString();
      return storedPhone == normalizeYemenPhone(phone) && verifier == candidate;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get hasCredentials async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final record = jsonDecode(prefs.getString('$_prefix.auth') ?? '{}')
          as Map<String, dynamic>;
      return (record['phone'] as String? ?? '').isNotEmpty &&
          (record['salt'] as String? ?? '').isNotEmpty &&
          (record['verifier'] as String? ?? '').isNotEmpty &&
          profile.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveNotifications(Map<String, bool> value) async {
    notifications = Map.of(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.notifications', jsonEncode(notifications));
    notifyListeners();
  }

  Future<void> setAvailable(bool value) async {
    available = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix.available', value);
    notifyListeners();
  }

  Future<void> setLocation(double lat, double lng) async {
    latitude = lat;
    longitude = lng;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_prefix.latitude', lat);
    await prefs.setDouble('$_prefix.longitude', lng);
    notifyListeners();
  }
}
