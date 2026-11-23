import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../services/station_owner_local_store.dart';
import '../../widgets/owner_widgets.dart';
import 'station_details_screen.dart';

class AllStationsScreen extends StatelessWidget {
  const AllStationsScreen({super.key, required this.store});
  final StationOwnerLocalStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text('جميع المحطات'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          if (store.stations.isEmpty)
            const OwnerCard(
                child: Text('لا توجد محطات مسجلة حتى الآن.',
                    textAlign: TextAlign.right, style: AppTextStyles.body)),
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
                        builder: (_) =>
                            StationDetailsScreen(station: station)))),
            const SizedBox(height: 14),
          ],
        ]),
      );
}
