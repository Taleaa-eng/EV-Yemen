import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/owner_review.dart';
import '../../models/owner_station.dart';
import '../../widgets/owner_widgets.dart';
import '../dashboard/owner_home_screen.dart';

class StationReviewsScreen extends StatelessWidget {
  const StationReviewsScreen({
    super.key,
    required this.station,
    required this.reviews,
  });

  final OwnerStation station;
  final List<OwnerReview> reviews;

  double get _average => reviews.isEmpty
      ? 0
      : reviews.fold<int>(0, (sum, review) => sum + review.rating) /
          reviews.length;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('المحطة وتقييماتها'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text(station.name,
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text('${station.address} · ${station.chargers.length} وحدات شحن',
                textAlign: TextAlign.right, style: AppTextStyles.body),
            const SizedBox(height: 14),
            OwnerCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('${_average.toStringAsFixed(1)} من ٥',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.h2),
                        const SizedBox(height: 5),
                        Text('${reviews.length} تقييماً',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.body),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.star_rounded,
                      color: AppColors.accent, size: 32),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle('تقييمات العملاء'),
            const SizedBox(height: 10),
            if (reviews.isEmpty)
              const OwnerCard(
                  child: Text('لا توجد تقييمات لهذه المحطة حتى الآن.',
                      textAlign: TextAlign.right, style: AppTextStyles.body)),
            for (final review in reviews) ...[
              OwnerReviewCard(
                name: '${review.customerName} · ${review.rating} / ٥',
                text: review.title,
                stars: review.rating,
                date: review.createdAt.toLocal().toString().split(' ').first,
              ),
              const SizedBox(height: 8),
              Text(review.comment,
                  textAlign: TextAlign.right, style: AppTextStyles.body),
              const SizedBox(height: 14),
            ],
          ],
        ),
        bottomNavigationBar: UnifiedBottomNavBar(
          index: 2,
          onTap: (tab) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => OwnerHome(initialTab: tab)),
            (route) => false,
          ),
        ),
      );
}
