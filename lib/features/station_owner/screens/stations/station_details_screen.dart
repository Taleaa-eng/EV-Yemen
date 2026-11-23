import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/owner_station.dart';
import '../../services/station_owner_local_store.dart';
import '../../widgets/owner_widgets.dart';
import '../dashboard/owner_home_screen.dart';
import '../reviews/station_reviews_screen.dart';
import 'station_form_screen.dart';

class StationDetailsScreen extends StatefulWidget {
  const StationDetailsScreen({super.key, required this.station, this.store});
  final OwnerStation station;
  final StationOwnerLocalStore? store;

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  late OwnerStation station = widget.station;
  StationOwnerLocalStore get store =>
      widget.store ?? StationOwnerLocalStore.instance;

  Future<void> _edit() async {
    final result = await Navigator.push<OwnerStation>(
      context,
      MaterialPageRoute(
        builder: (_) => StationFormScreen(edit: true, station: station),
      ),
    );
    if (result == null) return;
    await store.saveStation(result);
    if (mounted) setState(() => station = result);
  }

  Future<void> _delete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف المحطة؟', textAlign: TextAlign.right),
        content: const Text('سيتم حذف المحطة وشواحنها وتقييماتها المحفوظة.',
            textAlign: TextAlign.right),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (shouldDelete != true) return;
    await store.deleteStation(station.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final reviews = store.reviews
        .where((review) => review.stationId == station.id)
        .toList();
    final totalPower = station.chargers.fold<int>(
      0,
      (total, item) => total + (int.tryParse(item.powerKw) ?? 0),
    );
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('تفاصيل المحطة'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: SafeArea(
          child: ListView(padding: const EdgeInsets.all(20), children: [
        stationImage(height: 216, imagePath: station.imagePath),
        const SizedBox(height: 18),
        Text(station.name, textAlign: TextAlign.right, style: AppTextStyles.h1),
        const SizedBox(height: 6),
        Text(station.address,
            textAlign: TextAlign.right, style: AppTextStyles.caption),
        const SizedBox(height: 17),
        OwnerCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              OwnerDetailRow('وحدات الشحن', '${station.chargers.length}'),
              OwnerDetailRow('القدرة الإجمالية', '$totalPower كيلوواط'),
              OwnerDetailRow('رقم التواصل', station.phone),
              OwnerDetailRow('الحالة', station.active ? 'نشطة' : 'غير متاحة'),
              OwnerDetailRow('التقييمات المسجلة', '${reviews.length}'),
            ])),
        const SizedBox(height: 18),
        const SectionTitle('الشواحن'),
        const SizedBox(height: 10),
        if (station.chargers.isEmpty)
          const OwnerCard(
              child: Text('لا توجد نقاط شحن مضافة لهذه المحطة.',
                  textAlign: TextAlign.right, style: AppTextStyles.body)),
        for (final charger in station.chargers)
          Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: OwnerCard(
                  child: Row(children: [
                StatusPill(charger.available ? 'متاح' : 'غير متاح'),
                const Spacer(),
                Flexible(
                    child: Text(
                        '${charger.id} · ${charger.connector} · ${charger.powerKw} kW',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium)),
                const SizedBox(width: 8),
                const Icon(Icons.ev_station_rounded, color: AppColors.primary)
              ]))),
        const SizedBox(height: 10),
        OwnerButton(label: 'تعديل بيانات المحطة', onPressed: _edit),
        const SizedBox(height: 12),
        OwnerButton(
            label: 'عرض تقييمات هذه المحطة',
            outlined: true,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => StationReviewsScreen(
                          station: station,
                          reviews: reviews,
                        )))),
        const SizedBox(height: 12),
        OwnerButton(label: 'حذف المحطة', danger: true, onPressed: _delete),
      ])),
      bottomNavigationBar: UnifiedBottomNavBar(
          index: 1,
          onTap: (value) => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => OwnerHome(initialTab: value)),
              (route) => false)),
    );
  }
}
