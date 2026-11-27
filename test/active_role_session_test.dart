import 'package:ev_yemen/core/services/active_role_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('starts with no active role when preferences contain no session',
      () async {
    expect(await ActiveRoleSessionStore.instance.load(), isNull);
  });

  test('restores each active role from local preferences', () async {
    final store = ActiveRoleSessionStore.instance;

    for (final role in ActiveUserRole.values) {
      await store.save(role, authenticated: true);

      final restored = await store.load();
      expect(restored?.role, role);
      expect(restored?.isAuthenticated, isTrue);
      expect(restored?.isGuest, isFalse);
    }
  });

  test('restores guest state and clears only on explicit logout', () async {
    final store = ActiveRoleSessionStore.instance;
    await store.save(
      ActiveUserRole.customer,
      guest: true,
    );

    final restoredGuest = await store.load();
    expect(restoredGuest?.role, ActiveUserRole.customer);
    expect(restoredGuest?.isGuest, isTrue);
    expect(restoredGuest?.isAuthenticated, isFalse);

    await store.clear();
    expect(await store.load(), isNull);
  });

  test('role selection alone does not create an authenticated session',
      () async {
    final store = ActiveRoleSessionStore.instance;
    await store.save(ActiveUserRole.stationOwner);

    final selectedRole = await store.load();
    expect(selectedRole?.role, ActiveUserRole.stationOwner);
    expect(selectedRole?.isAuthenticated, isFalse);
  });
}
