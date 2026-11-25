import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../account_selection/account_type_selection_screen.dart';
import 'services/station_owner_local_store.dart';

class StationOwnerApp extends StatefulWidget {
  const StationOwnerApp({super.key});

  @override
  State<StationOwnerApp> createState() => _StationOwnerAppState();
}

class _StationOwnerAppState extends State<StationOwnerApp> {
  final store = StationOwnerLocalStore.instance;

  @override
  void initState() {
    super.initState();
    store.initialize();
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
        home: const AccountTypeSelectionScreen(),
      );
}
