import 'package:flutter/material.dart';

import '../service_provider/provider_app.dart';

class SparePartsProviderApp extends StatelessWidget {
  const SparePartsProviderApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const ProviderApp(subtype: 'صاحب قطع غيار');
}
