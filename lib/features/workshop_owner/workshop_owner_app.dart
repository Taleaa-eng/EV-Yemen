import 'package:flutter/material.dart';

import '../service_provider/provider_app.dart';

class WorkshopOwnerApp extends StatelessWidget {
  const WorkshopOwnerApp({super.key});

  @override
  Widget build(BuildContext context) => const ProviderApp(subtype: 'صاحب ورشة');
}
