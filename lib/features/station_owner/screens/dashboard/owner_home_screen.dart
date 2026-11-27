import 'package:flutter/material.dart';

import '../../../../core/services/active_role_session.dart';
import '../../../../core/widgets/logout_confirmation_dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../account_selection/account_type_selection_screen.dart';
import '../../models/owner_notification_settings.dart';
import '../../models/owner_station.dart';
import '../../services/station_owner_local_store.dart';
import '../../widgets/owner_widgets.dart';
import '../notifications/notifications_screen.dart';
import '../profile/notification_settings_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/settings_screen.dart';
import '../reviews/reviews_screen.dart';
import '../stations/station_form_screen.dart';
import '../stations/stations_screen.dart';
import 'dashboard_screen.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key, this.initialTab = 0, this.store});

  final int initialTab;
  final StationOwnerLocalStore? store;

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  late final StationOwnerLocalStore store =
      widget.store ?? StationOwnerLocalStore.instance;
  late int tab;

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab;
    store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void selectTab(int value) => setState(() => tab = value);

  @override
  Widget build(BuildContext context) {
    const titles = ['لوحة التحكم', 'محطاتي', 'التقييمات', 'حسابي'];
    final pages = [
      DashboardScreen(store: store, onAdd: () => _openForm()),
      StationsScreen(store: store, onAdd: () => _openForm()),
      ReviewsScreen(store: store),
      ProfileScreen(
        profile: store.currentAccount?.profile,
        onOpenSettings: _openSettings,
        onLogout: _openLogout,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(titles[tab]),
        actions: [
          if (tab < 3)
            IconButton(
              tooltip: 'الإشعارات',
              onPressed: _openNotifications,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications_none_rounded),
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: IndexedStack(index: tab, children: pages),
      bottomNavigationBar: UnifiedBottomNavBar(index: tab, onTap: selectTab),
    );
  }

  Future<void> _openForm({OwnerStation? station}) async {
    final result = await Navigator.push<OwnerStation>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            StationFormScreen(edit: station != null, station: station),
      ),
    );
    if (result != null) await store.saveStation(result);
  }

  void _openNotifications() => Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationsScreen(
            preferences: _notificationPreferences,
            onPreferencesChanged: _savePreferences,
            onBackToDashboard: () {
              Navigator.pop(context);
              selectTab(0);
            },
          ),
        ),
      );

  NotificationPreferences get _notificationPreferences =>
      NotificationPreferences(
        reviews: store.notificationSettings.reviews,
        station: store.notificationSettings.station,
        account: store.notificationSettings.account,
      );

  void _savePreferences(NotificationPreferences value) =>
      store.saveNotificationSettings(OwnerNotificationSettings(
        reviews: value.reviews,
        station: value.station,
        account: value.account,
      ));

  void _openSettings() => Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) => SettingsScreen(
            preferences: _notificationPreferences,
            onPreferencesChanged: _savePreferences,
            language: store.language,
            onLanguageChanged: store.saveLanguage,
            onLogout: _openLogout,
          ),
        ),
      );

  void _openLogout() => _confirmLogout();

  Future<void> _confirmLogout() async {
    final confirm = await showLogoutConfirmationDialog(context);
    if (!confirm || !mounted) return;
    await store.logout();
    await ActiveRoleSessionStore.instance.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AccountTypeSelectionScreen()),
      (route) => false,
    );
  }
}
