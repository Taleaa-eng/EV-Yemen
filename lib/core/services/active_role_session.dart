import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum ActiveUserRole {
  customer,
  carDealer,
  workshopOwner,
  sparePartsProvider,
  stationOwner,
}

class ActiveRoleSession {
  const ActiveRoleSession({
    required this.role,
    this.isAuthenticated = false,
    this.isGuest = false,
  });

  final ActiveUserRole role;
  final bool isAuthenticated;
  final bool isGuest;

  String? get providerSubtype => switch (role) {
        ActiveUserRole.workshopOwner => 'صاحب ورشة',
        ActiveUserRole.sparePartsProvider => 'صاحب قطع غيار',
        _ => null,
      };
}

class ActiveRoleSessionStore {
  ActiveRoleSessionStore._();

  static final ActiveRoleSessionStore instance = ActiveRoleSessionStore._();
  static const _sessionKey = 'ev_yemen.active_role_session.v1';

  Future<ActiveRoleSession?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_sessionKey);
    if (raw == null) return null;

    try {
      final values = jsonDecode(raw) as Map<String, dynamic>;
      final roleName =
          values['active_role'] as String? ?? values['role'] as String?;
      final matchingRoles =
          ActiveUserRole.values.where((item) => item.name == roleName);
      if (matchingRoles.isEmpty) {
        await preferences.remove(_sessionKey);
        return null;
      }
      return ActiveRoleSession(
        role: matchingRoles.first,
        isAuthenticated: values['is_authenticated'] as bool? ??
            values['authenticated'] as bool? ??
            false,
        isGuest:
            values['is_guest'] as bool? ?? values['guest'] as bool? ?? false,
      );
    } catch (_) {
      await preferences.remove(_sessionKey);
      return null;
    }
  }

  Future<void> save(
    ActiveUserRole role, {
    bool authenticated = false,
    bool guest = false,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _sessionKey,
      jsonEncode({
        'active_role': role.name,
        'is_authenticated': authenticated,
        'is_guest': guest,
      }),
    );
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
  }
}
