import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/services/active_role_session.dart';
import '../../core/services/business_approval_store.dart';
import '../account_selection/account_type_selection_screen.dart';
import '../customer/customer_screens.dart';
import '../spare_parts_provider/spare_parts_provider_app.dart';
import '../service_provider/provider_local_store.dart';
import '../car_dealer/dealer_app.dart';
import '../car_dealer/dealer_local_store.dart';
import '../workshop_owner/workshop_owner_app.dart';
import 'screens/dashboard/owner_home_screen.dart';
import 'services/station_owner_local_store.dart';

class StationOwnerApp extends StatefulWidget {
  const StationOwnerApp({super.key});

  @override
  State<StationOwnerApp> createState() => _StationOwnerAppState();
}

class _StationOwnerAppState extends State<StationOwnerApp> {
  final store = StationOwnerLocalStore.instance;
  late final Future<Widget> _initialScreen = _restoreInitialScreen();

  Future<Widget> _restoreInitialScreen() async {
    await store.initialize();
    final session = await ActiveRoleSessionStore.instance.load();
    if (session == null || !session.isAuthenticated || session.isGuest) {
      return const AccountTypeSelectionScreen();
    }

    if (session.role == ActiveUserRole.stationOwner) {
      if (store.isAuthenticated && store.currentAccount?.approved == true) {
        return OwnerHome(store: store);
      }
      await ActiveRoleSessionStore.instance.clear();
      return const AccountTypeSelectionScreen();
    }

    if (session.role == ActiveUserRole.customer) {
      return const CustomerAppScreen();
    }

    if (session.role == ActiveUserRole.carDealer) {
      final dealerStore = DealerLocalStore.instance;
      await dealerStore.initialize();
      if (await dealerStore.hasAccount) {
        final approval =
            await BusinessApprovalStore.instance.statusFor('car_dealer');
        if (approval == BusinessApprovalStatus.approved) {
          return const DealerApp();
        }
        await ActiveRoleSessionStore.instance.clear();
        return const AccountTypeSelectionScreen();
      }
      await ActiveRoleSessionStore.instance.clear();
      return const AccountTypeSelectionScreen();
    }

    final subtype = session.providerSubtype ?? 'صاحب ورشة';
    final providerStore = ProviderLocalStore.instance;
    await providerStore.load(subtype);
    if (!await providerStore.hasCredentials) {
      await ActiveRoleSessionStore.instance.clear();
      return const AccountTypeSelectionScreen();
    }
    final approvalKey =
        subtype == 'صاحب قطع غيار' ? 'parts_provider' : 'workshop_owner';
    final approval =
        await BusinessApprovalStore.instance.statusFor(approvalKey);
    if (approval != BusinessApprovalStatus.approved) {
      await ActiveRoleSessionStore.instance.clear();
      return const AccountTypeSelectionScreen();
    }
    return subtype == 'صاحب قطع غيار'
        ? const SparePartsProviderApp()
        : const WorkshopOwnerApp();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EV Yemen',
        theme: AppTheme.light,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
        home: FutureBuilder<Widget>(
          future: _initialScreen,
          builder: (context, snapshot) {
            if (snapshot.hasData) return snapshot.data!;
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      );
}
