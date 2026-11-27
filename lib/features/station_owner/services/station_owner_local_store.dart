import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/business_document.dart';
import '../../../core/services/auth_validators.dart';
import '../models/owner_account.dart';
import '../models/owner_notification_settings.dart';
import '../models/owner_profile.dart';
import '../models/owner_review.dart';
import '../models/owner_station.dart';

class StationOwnerLocalStore extends ChangeNotifier {
  StationOwnerLocalStore._();
  static final StationOwnerLocalStore instance = StationOwnerLocalStore._();

  static const _accountsKey = 'ev_yemen.owner.accounts.v1';
  static const _sessionKey = 'ev_yemen.owner.active_account.v1';
  late SharedPreferences _preferences;
  List<OwnerAccount> _accounts = [];
  OwnerAccount? currentAccount;
  List<OwnerStation> stations = [];
  List<OwnerReview> reviews = [];
  OwnerNotificationSettings notificationSettings =
      const OwnerNotificationSettings();
  String language = 'العربية';

  bool get isAuthenticated => currentAccount != null;

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    try {
      final rawAccounts = _preferences.getString(_accountsKey);
      if (rawAccounts != null) {
        _accounts = (jsonDecode(rawAccounts) as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(OwnerAccount.fromJson)
            .toList();
      }
    } catch (_) {
      _accounts = [];
    }
    final activeId = _preferences.getString(_sessionKey);
    currentAccount = null;
    if (activeId != null) {
      for (final account in _accounts) {
        if (account.id == activeId) {
          currentAccount = account;
          break;
        }
      }
    }
    if (currentAccount != null) {
      await _loadOwnerData();
    } else {
      stations = [];
      reviews = [];
    }
    notifyListeners();
  }

  Future<bool> register({
    required OwnerProfile profile,
    required String password,
    required Map<String, BusinessDocument> documents,
  }) async {
    final email = profile.email.trim().toLowerCase();
    final phone = profile.phone.trim();
    if (!isValidYemenPhone(phone) || !isValidPassword(password)) return false;
    final duplicate = _accounts.any((account) =>
        (email.isNotEmpty && account.email.toLowerCase() == email) ||
        normalizeYemenPhone(account.phone) == normalizeYemenPhone(phone));
    if (duplicate) return false;

    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256))
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final account = OwnerAccount(
      id: id,
      email: email,
      phone: phone,
      passwordSalt: salt,
      passwordHash: _hashPassword(password, salt),
      profile: profile.copyWith(email: email),
      documents: Map.of(documents),
      approved: false,
    );
    _accounts = [..._accounts, account];
    currentAccount = account;
    stations = [];
    reviews = [];
    notificationSettings = const OwnerNotificationSettings();
    language = 'العربية';
    await _saveAccounts();
    await _preferences.setString(_sessionKey, id);
    await _saveOwnerData();
    notifyListeners();
    return true;
  }

  Future<bool> login(String identifier, String password) async {
    final normalized = identifier.trim().toLowerCase();
    if ((!isValidEmail(normalized) && !isValidYemenPhone(identifier)) ||
        !isValidPassword(password)) {
      return false;
    }
    OwnerAccount? match;
    for (final account in _accounts) {
      if (account.email.toLowerCase() == normalized ||
          normalizeYemenPhone(account.phone) ==
              normalizeYemenPhone(identifier)) {
        match = account;
        break;
      }
    }
    if (match == null ||
        match.passwordHash != _hashPassword(password, match.passwordSalt)) {
      return false;
    }
    currentAccount = match;
    await _preferences.setString(_sessionKey, match.id);
    await _loadOwnerData();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await _preferences.remove(_sessionKey);
    currentAccount = null;
    stations = [];
    reviews = [];
    notifyListeners();
  }

  Future<void> saveStation(OwnerStation station) async {
    final index = stations.indexWhere((item) => item.id == station.id);
    if (index < 0) {
      stations = [...stations, station];
    } else {
      stations = [
        for (var i = 0; i < stations.length; i++)
          if (i == index) station else stations[i],
      ];
    }
    await _saveOwnerData();
    notifyListeners();
  }

  Future<void> deleteStation(String stationId) async {
    stations = stations.where((item) => item.id != stationId).toList();
    reviews = reviews.where((review) => review.stationId != stationId).toList();
    await _saveOwnerData();
    notifyListeners();
  }

  Future<void> saveReviews(List<OwnerReview> newReviews) async {
    reviews = [...newReviews];
    await _saveOwnerData();
    notifyListeners();
  }

  Future<void> saveReview(OwnerReview review) async {
    final index = reviews.indexWhere((item) => item.id == review.id);
    reviews = [
      for (var i = 0; i < reviews.length; i++)
        if (i == index) review else reviews[i],
      if (index < 0) review,
    ];
    await _saveOwnerData();
    notifyListeners();
  }

  Future<void> deleteReview(String reviewId) async {
    reviews = reviews.where((review) => review.id != reviewId).toList();
    await _saveOwnerData();
    notifyListeners();
  }

  Future<void> updateProfile(OwnerProfile profile) async {
    final account = currentAccount;
    if (account == null) return;
    currentAccount = account.copyWith(profile: profile);
    _accounts = [
      for (final item in _accounts)
        if (item.id == account.id) currentAccount! else item,
    ];
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> setAccountApproval(String accountId, bool approved) async {
    OwnerAccount? account;
    for (final item in _accounts) {
      if (item.id == accountId) {
        account = item;
        break;
      }
    }
    if (account == null) return;
    final updated = account.copyWith(approved: approved);
    _accounts = [
      for (final item in _accounts)
        if (item.id == accountId) updated else item,
    ];
    if (currentAccount?.id == accountId) currentAccount = updated;
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> saveNotificationSettings(
      OwnerNotificationSettings settings) async {
    notificationSettings = settings;
    await _preferences.setString(
        _key('notifications'), jsonEncode(settings.toJson()));
    notifyListeners();
  }

  Future<void> saveLanguage(String value) async {
    language = value;
    await _preferences.setString(_key('language'), value);
    notifyListeners();
  }

  String _key(String suffix) =>
      'ev_yemen.owner.${currentAccount?.id ?? 'none'}.$suffix.v1';

  String _hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  Future<void> _saveAccounts() async => _preferences.setString(
        _accountsKey,
        jsonEncode(_accounts.map((account) => account.toJson()).toList()),
      );

  Future<void> _loadOwnerData() async {
    final rawStations = _preferences.getString(_key('stations'));
    final rawReviews = _preferences.getString(_key('reviews'));
    final rawNotifications = _preferences.getString(_key('notifications'));
    stations = _decodeList(rawStations, OwnerStation.fromJson);
    reviews = _decodeList(rawReviews, OwnerReview.fromJson);
    if (rawNotifications != null) {
      try {
        notificationSettings = OwnerNotificationSettings.fromJson(
            jsonDecode(rawNotifications) as Map<String, dynamic>);
      } catch (_) {
        notificationSettings = const OwnerNotificationSettings();
      }
    } else {
      notificationSettings = const OwnerNotificationSettings();
    }
    language = _preferences.getString(_key('language')) ?? 'العربية';
  }

  List<T> _decodeList<T>(String? raw, T Function(Map<String, dynamic>) parse) {
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(parse)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveOwnerData() async {
    if (currentAccount == null) return;
    await _preferences.setString(
      _key('stations'),
      jsonEncode(stations.map((station) => station.toJson()).toList()),
    );
    await _preferences.setString(
      _key('reviews'),
      jsonEncode(reviews.map((review) => review.toJson()).toList()),
    );
  }
}
