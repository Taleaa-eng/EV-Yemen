import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'services/station_owner_local_store.dart';
import 'screens/dashboard/owner_home_screen.dart';
import 'screens/auth/login_screen.dart';

class StationOwnerApp extends StatefulWidget {
  const StationOwnerApp({super.key});

  @override
  State<StationOwnerApp> createState() => _StationOwnerAppState();
}

class _StationOwnerAppState extends State<StationOwnerApp> {
  final store = StationOwnerLocalStore.instance;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    store.initialize().then((_) {
      if (mounted) setState(() => ready = true);
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EV Yemen - صاحب المحطة',
        theme: AppTheme.light,
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        ),
        home: !ready
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : store.isAuthenticated
                ? OwnerHome(store: store)
                : LoginScreen(store: store),
      );
}
