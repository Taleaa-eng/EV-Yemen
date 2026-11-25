import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    } catch (_) {
      profile = {};
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
