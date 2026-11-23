import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../models/owner_station.dart';
import '../../services/station_owner_local_store.dart';
import '../../widgets/owner_widgets.dart';
import 'all_stations_screen.dart';
import 'station_details_screen.dart';
import 'station_form_screen.dart';

class StationsScreen extends StatelessWidget {
  const StationsScreen({super.key, required this.store, required this.onAdd});
  final StationOwnerLocalStore store;
  final VoidCallback onAdd;

  Future<void> _edit(BuildContext context, OwnerStation station) async {
    final updated = await Navigator.push<OwnerStation>(
      context,
      MaterialPageRoute(
        builder: (_) => StationFormScreen(edit: true, station: station),
      ),
    );
    if (updated != null) await store.saveStation(updated);
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
        children: [
          const Text('محطاتك وفروعك',
              textAlign: TextAlign.right, style: AppTextStyles.h1),
          const SizedBox(height: 12),
          Text(
            store.stations.isEmpty
                ? 'لم تسجل أي محطة بعد.'
                : 'لديك ${store.stations.length} محطة مسجلة.',
            textAlign: TextAlign.right,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 12),
          OwnerButton(label: 'إضافة محطة جديدة', onPressed: onAdd),
          const SizedBox(height: 14),
          if (store.stations.isEmpty)
            const OwnerCard(
              child: Text(
                'ستظهر محطاتك هنا بعد إضافة أول محطة.',
                textAlign: TextAlign.right,
                style: AppTextStyles.body,
              ),
            ),
          for (final station in store.stations) ...[
            OwnerStationCard(
              name: station.name,
              address: station.address,
              imagePath: station.imagePath,
              status: station.active ? 'نشطة' : 'غير متاحة',
              chargerCount: '${station.chargers.length} شواحن',
              ratingSummary:
                  '${store.reviews.where((review) => review.stationId == station.id).length} تقييماً',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StationDetailsScreen(station: station),
                ),
              ),
              onEdit: () => _edit(context, station),
            ),
            const SizedBox(height: 13),
          ],
          OwnerButton(
            label: 'عرض جميع المحطات',
            outlined: true,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AllStationsScreen(store: store),
              ),
            ),
          ),
        ],
      );
}
