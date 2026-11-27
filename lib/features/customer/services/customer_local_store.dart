import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerProfile {
  const CustomerProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.vehicle = '',
  });

  final String name;
  final String email;
  final String phone;
  final String vehicle;

  CustomerProfile copyWith(
          {String? name, String? email, String? phone, String? vehicle}) =>
      CustomerProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        vehicle: vehicle ?? this.vehicle,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'email': email, 'phone': phone, 'vehicle': vehicle};
  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      CustomerProfile(
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        vehicle: json['vehicle'] as String? ?? '',
      );
}

class CustomerConversation {
  const CustomerConversation(
      {required this.id,
      required this.dealerName,
      required this.carName,
      required this.lastMessage,
      required this.updatedAt,
      this.customerName = '',
      this.customerEmail = '',
      this.unread = false});
  final String id, dealerName, carName, lastMessage, updatedAt;
  final String customerEmail;
  final String customerName;
  final bool unread;
  Map<String, dynamic> toJson() => {
        'id': id,
        'dealerName': dealerName,
        'carName': carName,
        'lastMessage': lastMessage,
        'updatedAt': updatedAt,
        'customerEmail': customerEmail,
        'customerName': customerName,
        'unread': unread
      };
  factory CustomerConversation.fromJson(Map<String, dynamic> value) =>
      CustomerConversation(
          id: value['id'] as String? ?? '',
          dealerName: value['dealerName'] as String? ?? '',
          carName: value['carName'] as String? ?? '',
          lastMessage: value['lastMessage'] as String? ?? '',
          updatedAt: value['updatedAt'] as String? ?? '',
          customerEmail: value['customerEmail'] as String? ?? '',
          customerName: value['customerName'] as String? ?? '',
          unread: value['unread'] as bool? ?? false);
}

class CustomerMessage {
  const CustomerMessage(
      {required this.text, required this.sentAt, required this.fromCustomer});
  final String text, sentAt;
  final bool fromCustomer;
  Map<String, dynamic> toJson() =>
      {'text': text, 'sentAt': sentAt, 'fromCustomer': fromCustomer};
  factory CustomerMessage.fromJson(Map<String, dynamic> value) =>
      CustomerMessage(
          text: value['text'] as String? ?? '',
          sentAt: value['sentAt'] as String? ?? '',
          fromCustomer: value['fromCustomer'] as bool? ?? true);
}

class CustomerBooking {
  const CustomerBooking(
      {required this.id,
      required this.carName,
      required this.dealerName,
      required this.deposit,
      required this.createdAt,
      this.paymentMethod = 'محفظة كريمي',
      this.status = 'نشط'});
  final String id, carName, dealerName, deposit, createdAt, status;
  final String paymentMethod;
  CustomerBooking copyWith({String? status}) => CustomerBooking(
      id: id,
      carName: carName,
      dealerName: dealerName,
      deposit: deposit,
      createdAt: createdAt,
      paymentMethod: paymentMethod,
      status: status ?? this.status);
  Map<String, dynamic> toJson() => {
        'id': id,
        'carName': carName,
        'dealerName': dealerName,
        'deposit': deposit,
        'createdAt': createdAt,
        'paymentMethod': paymentMethod,
        'status': status
      };
  factory CustomerBooking.fromJson(Map<String, dynamic> value) =>
      CustomerBooking(
          id: value['id'] as String? ?? '',
          carName: value['carName'] as String? ?? '',
          dealerName: value['dealerName'] as String? ?? '',
          deposit: value['deposit'] as String? ?? '',
          createdAt: value['createdAt'] as String? ?? '',
          paymentMethod: value['paymentMethod'] as String? ?? 'محفظة كريمي',
          status: value['status'] as String? ?? 'نشط');
}

class CustomerReview {
  const CustomerReview(
      {required this.id,
      required this.targetName,
      required this.score,
      required this.comment,
      this.reply = ''});
  final String id, targetName, score, comment, reply;
  Map<String, dynamic> toJson() => {
        'id': id,
        'targetName': targetName,
        'score': score,
        'comment': comment,
        'reply': reply
      };
  factory CustomerReview.fromJson(Map<String, dynamic> value) => CustomerReview(
      id: value['id'] as String? ?? '',
      targetName: value['targetName'] as String? ?? '',
      score: value['score'] as String? ?? '0',
      comment: value['comment'] as String? ?? '',
      reply: value['reply'] as String? ?? '');
}

class CustomerLocalStore extends ChangeNotifier {
  CustomerLocalStore._();
  static final CustomerLocalStore instance = CustomerLocalStore._();

  static const _profilesKey = 'ev_yemen.customer.profiles.v2';
  static const _legacyProfileKey = 'ev_yemen.customer.profile.v1';
  static const _activeEmailKey = 'ev_yemen.customer.active_email.v1';
  static const _sharedConversationsKey =
      'ev_yemen.dealer.shared_conversations.v1';
  static const _sharedMessagesKey = 'ev_yemen.dealer.shared_messages.v1';
  CustomerProfile profile = const CustomerProfile();
  bool notificationsEnabled = true;
  bool offersEnabled = false;
  String language = 'العربية';
  Set<String> favorites = {};
  List<CustomerConversation> conversations = [];
  Map<String, List<CustomerMessage>> messages = {};
  List<CustomerBooking> bookings = [];
  List<CustomerReview> reviews = [];
  bool initialized = false;

  String get _userTag =>
      Uri.encodeComponent(profile.email.trim().toLowerCase().isEmpty
          ? 'guest'
          : profile.email.trim().toLowerCase());
  String get _notificationsKey =>
      'ev_yemen.customer.$_userTag.notifications.v1';
  String get _languageKey => 'ev_yemen.customer.$_userTag.language.v1';
  String get _favoritesKey => 'ev_yemen.customer.$_userTag.favorites.v1';
  String get _conversationsKey => _sharedConversationsKey;
  String get _messagesKey => _sharedMessagesKey;
  String get _bookingsKey => 'ev_yemen.customer.$_userTag.bookings.v1';
  String get _reviewsKey => 'ev_yemen.customer.$_userTag.reviews.v1';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString(_activeEmailKey) ?? '';
    try {
      final rawProfiles = prefs.getString(_profilesKey);
      if (rawProfiles != null) {
        final decoded = jsonDecode(rawProfiles) as Map<String, dynamic>;
        final raw = decoded[userEmail.toLowerCase()];
        if (raw is Map<String, dynamic>) {
          profile = CustomerProfile.fromJson(raw);
        }
      } else {
        final legacy = prefs.getString(_legacyProfileKey);
        if (legacy != null) {
          profile = CustomerProfile.fromJson(
              jsonDecode(legacy) as Map<String, dynamic>);
        }
        if (profile.name == 'أحمد محمد') {
          profile = profile.copyWith(
            name: '',
            vehicle: profile.vehicle == 'Tesla Model 3' ? '' : null,
          );
        }
      }
    } catch (_) {
      profile = CustomerProfile(email: userEmail);
    }
    profile =
        profile.copyWith(email: userEmail.isEmpty ? profile.email : userEmail);
    _loadUserData(prefs);
    initialized = true;
    notifyListeners();
  }

  void _loadUserData(SharedPreferences prefs) {
    try {
      final raw = prefs.getString(_notificationsKey);
      if (raw != null) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        notificationsEnabled = data['notifications'] as bool? ?? true;
        offersEnabled = data['offers'] as bool? ?? false;
      }
    } catch (_) {
      notificationsEnabled = true;
      offersEnabled = false;
    }
    language = prefs.getString(_languageKey) ?? 'العربية';
    favorites = prefs.getStringList(_favoritesKey)?.toSet() ?? {};
    conversations = _decodeList(
        prefs.getString(_conversationsKey), CustomerConversation.fromJson);
    bookings =
        _decodeList(prefs.getString(_bookingsKey), CustomerBooking.fromJson);
    reviews =
        _decodeList(prefs.getString(_reviewsKey), CustomerReview.fromJson);
    try {
      final rawMessages = prefs.getString(_messagesKey);
      if (rawMessages != null) {
        final decoded = jsonDecode(rawMessages) as Map<String, dynamic>;
        messages = decoded.map((id, values) => MapEntry(
            id,
            (values as List<dynamic>)
                .whereType<Map<String, dynamic>>()
                .map(CustomerMessage.fromJson)
                .toList()));
      }
    } catch (_) {
      messages = {};
    }
  }

  Future<void> activateLogin(String email) async {
    final normalized = email.trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();
    try {
      final all = jsonDecode(prefs.getString(_profilesKey) ?? '{}')
          as Map<String, dynamic>;
      final found = all[normalized];
      profile = found is Map<String, dynamic>
          ? CustomerProfile.fromJson(found)
          : CustomerProfile(email: normalized);
    } catch (_) {
      profile = CustomerProfile(email: normalized);
    }
    await prefs.setString(_activeEmailKey, normalized);
    _loadUserData(prefs);
    notifyListeners();
  }

  Future<void> saveProfile(CustomerProfile value) async {
    profile = value.copyWith(email: value.email.trim().toLowerCase());
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> all = {};
    try {
      all = Map<String, dynamic>.from(
          jsonDecode(prefs.getString(_profilesKey) ?? '{}') as Map);
    } catch (_) {}
    if (profile.email.isNotEmpty) all[profile.email] = profile.toJson();
    await prefs.setString(_profilesKey, jsonEncode(all));
    await prefs.setString(_activeEmailKey, profile.email);
    await prefs.remove(_legacyProfileKey);
    notifyListeners();
  }

  Future<void> saveNotifications(
      {required bool enabled, required bool offers}) async {
    notificationsEnabled = enabled;
    offersEnabled = offers;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notificationsKey,
        jsonEncode({'notifications': enabled, 'offers': offers}));
    notifyListeners();
  }

  Future<void> saveLanguage(String value) async {
    language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
    notifyListeners();
  }

  Future<void> saveFavorites(Set<String> value) async {
    favorites = {...value};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites.toList());
    notifyListeners();
  }

  Future<CustomerConversation> startConversation(
      {required String dealerName,
      required String carName,
      required String firstMessage}) async {
    final existing = conversations
        .where((c) =>
            c.customerEmail == profile.email &&
            c.dealerName == dealerName &&
            c.carName == carName)
        .toList();
    if (existing.isNotEmpty) {
      await sendMessage(existing.first.id, firstMessage);
      return existing.first;
    }
    final id = '${DateTime.now().microsecondsSinceEpoch}';
    final conversation = CustomerConversation(
        id: id,
        dealerName: dealerName,
        carName: carName,
        lastMessage: firstMessage,
        updatedAt: _timeNow(),
        customerEmail: profile.email,
        customerName: profile.name);
    conversations = [conversation, ...conversations];
    messages[id] = [
      CustomerMessage(
          text: firstMessage, sentAt: _timeNow(), fromCustomer: true)
    ];
    await _saveChats();
    notifyListeners();
    return conversation;
  }

  Future<void> sendMessage(String id, String text,
      {bool fromCustomer = true}) async {
    if (text.trim().isEmpty) return;
    final List<CustomerMessage> updated = [
      ...(messages[id] ?? const <CustomerMessage>[]),
      CustomerMessage(
          text: text.trim(), sentAt: _timeNow(), fromCustomer: fromCustomer)
    ];
    messages[id] = updated;
    conversations = [
      for (final c in conversations)
        if (c.id == id)
          CustomerConversation(
              id: c.id,
              dealerName: c.dealerName,
              carName: c.carName,
              lastMessage: text.trim(),
              updatedAt: _timeNow(),
              customerEmail: c.customerEmail,
              customerName: c.customerName,
              unread: !fromCustomer)
        else
          c
    ];
    await _saveChats();
    notifyListeners();
  }

  Future<void> _saveChats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_conversationsKey,
        jsonEncode(conversations.map((e) => e.toJson()).toList()));
    await prefs.setString(
        _messagesKey,
        jsonEncode(messages
            .map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()))));
  }

  Future<void> addBooking(CustomerBooking booking) async {
    bookings = [booking, ...bookings];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _bookingsKey, jsonEncode(bookings.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> cancelBooking(String id) async {
    bookings = [
      for (final b in bookings)
        if (b.id == id) b.copyWith(status: 'ملغي') else b
    ];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _bookingsKey, jsonEncode(bookings.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> addReview(CustomerReview review) async {
    reviews = [review, ...reviews];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _reviewsKey, jsonEncode(reviews.map((e) => e.toJson()).toList()));
    notifyListeners();
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

  String _timeNow() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    return '$hour:${now.minute.toString().padLeft(2, '0')} ${now.hour < 12 ? 'ص' : 'م'}';
  }
}
