import 'package:flutter/material.dart';
import 'provider_location_reviews_screen.dart';
import 'provider_local_store.dart';

class ProviderApp extends StatefulWidget {
  const ProviderApp({super.key, required this.subtype});
  final String subtype;
  @override
  State<ProviderApp> createState() => _ProviderAppState();
}

class _ProviderAppState extends State<ProviderApp> {
  final store = ProviderLocalStore.instance;
  @override
  void initState() {
    super.initState();
    store.addListener(_changed);
    store.load(widget.subtype);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    store.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProviderLocationReviewsScreen(
      subtype: widget.subtype,
      latitude: store.latitude,
      longitude: store.longitude,
      address: store.profile['address']);
}
