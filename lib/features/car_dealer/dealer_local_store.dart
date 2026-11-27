import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/business_document.dart';
import '../../core/services/auth_validators.dart';

enum DealerRegistrationResult {
  created,
  invalidDetails,
  missingDocuments,
  accountAlreadyExists,
  storageFailure,
}

class DealerVehicle {
  const DealerVehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.batteryKwh,
    required this.rangeKm,
    required this.connector,
    required this.priceYer,
    required this.imageAsset,
    this.photoPaths = const [],
    this.available = true,
    this.draft = false,
    this.inquiries = 0,
  });

  final String id,
      make,
      model,
      year,
      batteryKwh,
      rangeKm,
      connector,
      imageAsset;
  final int priceYer, inquiries;
  final List<String> photoPaths;
  final bool available, draft;

  String get displayName => '$make $model · $year';
  String get primaryImagePath =>
      photoPaths.isNotEmpty ? photoPaths.first : imageAsset;

  DealerVehicle copyWith({
    String? make,
    String? model,
    String? year,
    String? batteryKwh,
    String? rangeKm,
    String? connector,
    int? priceYer,
    String? imageAsset,
    List<String>? photoPaths,
    bool? available,
    bool? draft,
    int? inquiries,
  }) =>
      DealerVehicle(
        id: id,
        make: make ?? this.make,
        model: model ?? this.model,
        year: year ?? this.year,
        batteryKwh: batteryKwh ?? this.batteryKwh,
        rangeKm: rangeKm ?? this.rangeKm,
        connector: connector ?? this.connector,
        priceYer: priceYer ?? this.priceYer,
        imageAsset: imageAsset ?? this.imageAsset,
        photoPaths: photoPaths ?? this.photoPaths,
        available: available ?? this.available,
        draft: draft ?? this.draft,
        inquiries: inquiries ?? this.inquiries,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'make': make,
        'model': model,
        'year': year,
        'batteryKwh': batteryKwh,
        'rangeKm': rangeKm,
        'connector': connector,
        'priceYer': priceYer,
        'imageAsset': imageAsset,
        'photoPaths': photoPaths,
        'available': available,
        'draft': draft,
        'inquiries': inquiries,
      };

  factory DealerVehicle.fromJson(Map<String, dynamic> json) => DealerVehicle(
        id: json['id'] as String? ?? '',
        make: json['make'] as String? ?? '',
        model: json['model'] as String? ?? '',
        year: json['year'] as String? ?? '',
        batteryKwh: json['batteryKwh'] as String? ?? '',
        rangeKm: json['rangeKm'] as String? ?? '',
        connector: json['connector'] as String? ?? '',
        priceYer: json['priceYer'] as int? ?? 0,
        imageAsset: json['imageAsset'] as String? ?? '',
        photoPaths: (json['photoPaths'] as List<dynamic>? ?? []).cast<String>(),
        available: json['available'] as bool? ?? true,
        draft: json['draft'] as bool? ?? false,
        inquiries: json['inquiries'] as int? ?? 0,
      );
}

class DealerOrder {
  const DealerOrder({
    required this.id,
    required this.customer,
    required this.phone,
    required this.city,
    required this.requestType,
    required this.vehicleName,
    required this.connector,
    required this.priceYer,
    required this.date,
    required this.status,
    required this.payment,
  });

  final String id, customer, phone, city, requestType, vehicleName;
  final String connector, date, status, payment;
  final int priceYer;

  DealerOrder copyWith({String? status, int? priceYer}) => DealerOrder(
        id: id,
        customer: customer,
        phone: phone,
        city: city,
        requestType: requestType,
        vehicleName: vehicleName,
        connector: connector,
        priceYer: priceYer ?? this.priceYer,
        date: date,
        status: status ?? this.status,
        payment: payment,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
        'phone': phone,
        'city': city,
        'requestType': requestType,
        'vehicleName': vehicleName,
        'connector': connector,
        'priceYer': priceYer,
        'date': date,
        'status': status,
        'payment': payment,
      };

  factory DealerOrder.fromJson(Map<String, dynamic> json) => DealerOrder(
        id: json['id'] as String? ?? '',
        customer: json['customer'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        city: json['city'] as String? ?? '',
        requestType: json['requestType'] as String? ?? '',
        vehicleName: json['vehicleName'] as String? ?? '',
        connector: json['connector'] as String? ?? '',
        priceYer: json['priceYer'] as int? ?? 0,
        date: json['date'] as String? ?? '',
        status: json['status'] as String? ?? 'جديد',
        payment: json['payment'] as String? ?? '',
      );
}

class DealerLocalStore extends ChangeNotifier {
  DealerLocalStore._();
  static final DealerLocalStore instance = DealerLocalStore._();

  static const _authKey = 'ev_yemen.dealer.auth.v1';
  static const _profileKey = 'ev_yemen.dealer.profile.v1';
  static const _vehiclesKey = 'ev_yemen.dealer.vehicles.v1';
  static const _ordersKey = 'ev_yemen.dealer.orders.v1';
  static const _notificationsKey = 'ev_yemen.dealer.notification_settings.v1';
  static const _documentsKey = 'ev_yemen.dealer.documents.v1';
  static const requiredDocumentKeys = <String>{
    'identity',
    'commercial_register',
    'agency_license',
    'premises_proof',
  };

  Map<String, String> profile = {};
  List<DealerVehicle> vehicles = [];
  List<DealerOrder> orders = [];
  Map<String, BusinessDocument> documents = {};
  Map<String, bool> notificationSettings = {
    'orders': true,
    'messages': true,
    'account': true,
    'offers': false,
    'push': true,
    'email': false,
  };
  bool initialized = false;

  Future<bool> get hasAccount async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final auth =
          jsonDecode(prefs.getString(_authKey) ?? '{}') as Map<String, dynamic>;
      return (auth['phone'] as String? ?? '').isNotEmpty &&
          (auth['salt'] as String? ?? '').isNotEmpty &&
          (auth['verifier'] as String? ?? '').isNotEmpty &&
          profile.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    profile =
        _decodeStringMap(prefs.getString(_profileKey)) ?? _defaultProfile();
    vehicles = _decodeList<DealerVehicle>(
          prefs.getString(_vehiclesKey),
          DealerVehicle.fromJson,
        ) ??
        _defaultVehicles;
    orders = _decodeList<DealerOrder>(
          prefs.getString(_ordersKey),
          DealerOrder.fromJson,
        ) ??
        _defaultOrders;
    final notifications = _decodeBoolMap(prefs.getString(_notificationsKey));
    if (notifications != null) notificationSettings = notifications;
    documents = _decodeDocuments(prefs.getString(_documentsKey));
    initialized = true;
    notifyListeners();
  }

  Future<DealerRegistrationResult> register({
    required String phone,
    required String password,
    required Map<String, String> profile,
    required Map<String, BusinessDocument> documents,
  }) async {
    if (!isValidYemenPhone(phone) || !isValidPassword(password)) {
      return DealerRegistrationResult.invalidDetails;
    }
    if (!requiredDocumentKeys.every((key) {
      final document = documents[key];
      return document != null &&
          document.name.trim().isNotEmpty &&
          document.path.trim().isNotEmpty;
    })) {
      return DealerRegistrationResult.missingDocuments;
    }

    var isRecoveringIncompleteRegistration = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingAuth = _decodeAuth(prefs.getString(_authKey));
      if (existingAuth != null) {
        final existingProfile =
            _decodeStringMap(prefs.getString(_profileKey)) ?? {};
        final existingDocuments =
            _decodeDocuments(prefs.getString(_documentsKey));
        final existingProfilePhone = existingProfile['phone'] ?? '';
        final hasCompleteAccount =
            (existingProfile['name']?.trim().isNotEmpty ?? false) &&
            (existingProfile['registration']?.trim().isNotEmpty ?? false) &&
            isValidYemenPhone(existingProfilePhone) &&
            normalizeYemenPhone(existingProfilePhone) ==
                existingAuth['phone'] &&
            (existingProfile['address']?.trim().isNotEmpty ?? false) &&
            requiredDocumentKeys.every((key) {
              final document = existingDocuments[key];
              return document != null &&
                  document.name.trim().isNotEmpty &&
                  document.path.trim().isNotEmpty;
            });
        if (hasCompleteAccount) {
          return DealerRegistrationResult.accountAlreadyExists;
        }
      }

      // Older interrupted saves wrote credentials before profile/documents.
      // Clear only that incomplete registration so a retry can finish cleanly.
      isRecoveringIncompleteRegistration = true;
      await prefs.remove(_authKey);
      await prefs.remove(_profileKey);
      await prefs.remove(_documentsKey);

      final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256))
          .map((value) => value.toRadixString(16).padLeft(2, '0'))
          .join();
      final nextProfile = {...profile, 'phone': phone.trim()};
      final encodedDocuments = jsonEncode(
          documents.map((key, value) => MapEntry(key, value.toJson())));
      final authSaved = await prefs.setString(
        _authKey,
        jsonEncode({
          'phone': normalizeYemenPhone(phone),
          'salt': salt,
          'verifier': _hash(password, salt),
        }),
      );
      final profileSaved = authSaved &&
          await prefs.setString(_profileKey, jsonEncode(nextProfile));
      final documentsSaved = profileSaved &&
          await prefs.setString(_documentsKey, encodedDocuments);
      if (!authSaved || !profileSaved || !documentsSaved) {
        await _removeRegistration(prefs);
        return DealerRegistrationResult.storageFailure;
      }

      this.profile = nextProfile;
      this.documents = Map.of(documents);
      initialized = true;
      notifyListeners();
      return DealerRegistrationResult.created;
    } catch (_) {
      if (isRecoveringIncompleteRegistration) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await _removeRegistration(prefs);
        } catch (_) {
          // The caller receives the storage failure either way.
        }
      }
      return DealerRegistrationResult.storageFailure;
    }
  }

  Map<String, dynamic>? _decodeAuth(String? raw) {
    if (raw == null) return null;
    try {
      final auth = jsonDecode(raw) as Map<String, dynamic>;
      final authPhone = auth['phone'] as String? ?? '';
      final salt = auth['salt'] as String? ?? '';
      final verifier = auth['verifier'] as String? ?? '';
      if (!RegExp(r'^7\d{8}$').hasMatch(authPhone) ||
          salt.isEmpty ||
          verifier.isEmpty) {
        return null;
      }
      return auth;
    } catch (_) {
      return null;
    }
  }

  Future<void> _removeRegistration(SharedPreferences prefs) async {
    await prefs.remove(_authKey);
    await prefs.remove(_profileKey);
    await prefs.remove(_documentsKey);
  }

  Future<bool> authenticate(
      {required String phone, required String password}) async {
    if (!isValidYemenPhone(phone) || !isValidPassword(password)) return false;
    final prefs = await SharedPreferences.getInstance();
    try {
      final credentials =
          jsonDecode(prefs.getString(_authKey) ?? '{}') as Map<String, dynamic>;
      final salt = credentials['salt'] as String? ?? '';
      final verifier = credentials['verifier'] as String? ?? '';
      return salt.isNotEmpty &&
          verifier.isNotEmpty &&
          profile.isNotEmpty &&
          credentials['phone'] == normalizeYemenPhone(phone) &&
          verifier == _hash(password, salt);
    } catch (_) {
      return false;
    }
  }

  Future<void> saveProfile(Map<String, String> value) async {
    profile = Map.of(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile));
    notifyListeners();
  }

  Future<void> saveDocuments(Map<String, BusinessDocument> value) async {
    documents = Map.of(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _documentsKey,
      jsonEncode(
          documents.map((key, document) => MapEntry(key, document.toJson()))),
    );
    notifyListeners();
  }

  Future<void> saveNotificationSettings(Map<String, bool> value) async {
    notificationSettings = Map.of(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsKey, jsonEncode(notificationSettings));
    notifyListeners();
  }

  Future<void> saveVehicle(DealerVehicle value) async {
    final exists = vehicles.any((item) => item.id == value.id);
    vehicles = [
      for (final item in vehicles)
        if (item.id == value.id) value else item,
      if (!exists) value,
    ];
    await _saveVehicles();
  }

  Future<void> setVehicleAvailability(String id, bool available) async {
    vehicles = [
      for (final item in vehicles)
        if (item.id == id) item.copyWith(available: available) else item,
    ];
    await _saveVehicles();
  }

  Future<void> updateOrder(String id,
      {required String status, int? priceYer}) async {
    orders = [
      for (final order in orders)
        if (order.id == id)
          order.copyWith(status: status, priceYer: priceYer)
        else
          order,
    ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _ordersKey, jsonEncode(orders.map((item) => item.toJson()).toList()));
    notifyListeners();
  }

  Future<void> _saveVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vehiclesKey,
        jsonEncode(vehicles.map((item) => item.toJson()).toList()));
    notifyListeners();
  }

  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  Map<String, String>? _decodeStringMap(String? raw) {
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map).map(
        (key, value) => MapEntry('$key', '$value'),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, bool>? _decodeBoolMap(String? raw) {
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as Map)
          .map((key, value) => MapEntry('$key', value == true));
    } catch (_) {
      return null;
    }
  }

  Map<String, BusinessDocument> _decodeDocuments(String? raw) {
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(
            key,
            BusinessDocument.fromJson(Map<String, dynamic>.from(value as Map)),
          ));
    } catch (_) {
      return {};
    }
  }

  List<T>? _decodeList<T>(
      String? raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _defaultProfile() => {
        'name': 'معرض المستقبل للسيارات',
        'registration': 'CR-10482',
        'phone': '+967 771 234 567',
        'email': 'future@dealer.ye',
        'address': 'شارع تعز، صنعاء',
      };

  static final List<DealerVehicle> _defaultVehicles = [
    const DealerVehicle(
      id: 'vehicle-byd-song-plus',
      make: 'BYD',
      model: 'Song Plus EV',
      year: '2024',
      batteryKwh: '71.8',
      rangeKm: '520',
      connector: 'GB/T',
      priceYer: 22500000,
      imageAsset: 'assets/dealer_profile/figma_catalog_1.jpeg',
      available: true,
      inquiries: 8,
    ),
    const DealerVehicle(
      id: 'vehicle-tesla-model-3',
      make: 'Tesla',
      model: 'Model 3',
      year: '2023',
      batteryKwh: '60',
      rangeKm: '491',
      connector: 'CCS2',
      priceYer: 19000000,
      imageAsset: 'assets/dealer_profile/figma_catalog_2.jpeg',
      available: true,
    ),
  ];

  static final List<DealerOrder> _defaultOrders = [
    const DealerOrder(
      id: 'BK-8402',
      customer: 'سارة محمد',
      phone: '+967 777 234 891',
      city: 'صنعاء',
      requestType: 'تجربة قيادة',
      vehicleName: 'BYD Song Plus EV 2024',
      connector: 'CCS2 • 550 كم • متوفرة للحجز',
      priceYer: 28000000,
      date: '2026-11-28',
      status: 'جديد',
      payment: 'تمويل بنكي • التجربة الخميس 4:30 م',
    ),
    const DealerOrder(
      id: 'BK-8396',
      customer: 'أحمد صالح',
      phone: '+967 777 345 678',
      city: 'صنعاء',
      requestType: 'استفسار سعر',
      vehicleName: 'BYD Atto 3 2023',
      connector: 'CCS2',
      priceYer: 22000000,
      date: '2026-11-27',
      status: 'قيد التنفيذ',
      payment: 'تمويل نقدي',
    ),
    const DealerOrder(
      id: 'BK-8388',
      customer: 'سامي علي',
      phone: '+967 733 456 789',
      city: 'عدن',
      requestType: 'طلب شراء',
      vehicleName: 'Hyundai IONIQ 5 2024',
      connector: 'CCS2 • 480 كم',
      priceYer: 32000000,
      date: '2026-11-26',
      status: 'مكتمل',
      payment: 'تم الدفع نقداً',
    ),
    const DealerOrder(
      id: 'BK-8373',
      customer: 'علي هاشم',
      phone: '+967 711 567 890',
      city: 'تعز',
      requestType: 'طلب حجز',
      vehicleName: 'Kia EV6 2023',
      connector: 'CCS2 • 450 كم',
      priceYer: 27000000,
      date: '2026-11-25',
      status: 'ملغاة',
      payment: 'لم يتم الدفع',
    ),
  ];
}

String formatYemeniRial(int value) => value
    .toString()
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
