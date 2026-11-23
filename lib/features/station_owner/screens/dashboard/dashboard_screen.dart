import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../models/owner_station.dart';
import '../../services/station_owner_local_store.dart';
import '../../widgets/owner_widgets.dart';
import '../stations/station_details_screen.dart';
import '../stations/station_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.store,
    required this.onAdd,
  });

  final StationOwnerLocalStore store;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final stations = store.stations;
    final activeCount = stations.where((station) => station.active).length;
    final chargerCount = stations.fold<int>(
      0,
      (count, station) => count + station.chargers.length,
    );
    final profile = store.currentAccount?.profile;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Text('صباح الخير، ${profile?.fullName ?? ''}',
            textAlign: TextAlign.right, style: AppTextStyles.h1),
        const SizedBox(height: 12),
        Text(
          stations.isEmpty
              ? 'ابدأ بإضافة محطتك الأولى لإدارة نقاط الشحن.'
              : 'ملخص محطاتك ونشاط العملاء في ${profile?.city ?? ''}.',
          textAlign: TextAlign.right,
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 12),
        OwnerCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('محطات نشطة: $activeCount',
                  textAlign: TextAlign.right, style: AppTextStyles.h2),
              const SizedBox(height: 6),
              Text(
                  'وحدات شحن: $chargerCount · التقييمات: ${store.reviews.length}',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body),
              const SizedBox(height: 6),
              Text(
                store.reviews.isEmpty
                    ? 'لا توجد تقييمات بعد'
                    : 'متوسط التقييم: ${_averageRating.toStringAsFixed(1)} من ٥',
                textAlign: TextAlign.right,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('إجراءات سريعة',
            textAlign: TextAlign.right, style: AppTextStyles.h2),
        const SizedBox(height: 12),
        OwnerButton(label: 'إضافة محطة جديدة', onPressed: onAdd),
        const SizedBox(height: 12),
        const Text('محطاتي',
            textAlign: TextAlign.right, style: AppTextStyles.h2),
        const SizedBox(height: 12),
        if (stations.isEmpty)
          const OwnerCard(
            child: Text('لم تضف أي محطة بعد. أضف محطتك الأولى للبدء.',
                textAlign: TextAlign.right, style: AppTextStyles.body),
          ),
        for (final station in stations.take(2)) ...[
          OwnerStationCard(
            name: station.name,
            address: station.address,
            imagePath: station.imagePath,
            status: station.active ? 'نشطة' : 'غير متاحة',
            chargerCount: '${station.chargers.length} شواحن',
            ratingSummary: '${_stationReviews(station.id)} تقييماً',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StationDetailsScreen(station: station),
              ),
            ),
            onEdit: () => _editStation(context, station),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  double get _averageRating {
    if (store.reviews.isEmpty) return 0;
    return store.reviews.fold<int>(0, (sum, review) => sum + review.rating) /
        store.reviews.length;
  }

  int _stationReviews(String stationId) =>
      store.reviews.where((review) => review.stationId == stationId).length;

  Future<void> _editStation(BuildContext context, OwnerStation station) async {
    final updated = await Navigator.push<OwnerStation>(
      context,
      MaterialPageRoute(
        builder: (_) => StationFormScreen(edit: true, station: station),
      ),
    );
    if (updated != null) await store.saveStation(updated);
  }
}
