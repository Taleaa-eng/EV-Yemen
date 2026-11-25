import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/owner_review.dart';
import '../../models/owner_station.dart';
import '../../services/station_owner_local_store.dart';
import '../../widgets/owner_widgets.dart';
import 'station_reviews_screen.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key, required this.store});
  final StationOwnerLocalStore store;

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String selectedStation = 'كل المحطات';

  @override
  Widget build(BuildContext context) {
    final stations = widget.store.stations;
    final reviews = widget.store.reviews
        .where((review) =>
            selectedStation == 'كل المحطات' ||
            stations.any((station) =>
                station.id == review.stationId &&
                station.name == selectedStation))
        .toList();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const Text('التقييمات الجديدة',
                  textAlign: TextAlign.right, style: AppTextStyles.h1),
              const SizedBox(height: 8),
              const Text('تابع آراء العملاء واختر محطة لعرض تقييماتها.',
                  textAlign: TextAlign.right, style: AppTextStyles.body),
              const SizedBox(height: 12),
              if (stations.isNotEmpty) _buildFilter(stations),
              const SizedBox(height: 14),
              if (reviews.isEmpty)
                const OwnerCard(
                  child: Text('لا توجد تقييمات جديدة حتى الآن.',
                      textAlign: TextAlign.right, style: AppTextStyles.body),
                ),
              for (final review in reviews) ...[
                _ReviewCard(review: review),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 4),
              const Directionality(
                textDirection: TextDirection.rtl,
                child: SectionTitle('التقييمات حسب المحطة'),
              ),
              const SizedBox(height: 8),
              if (stations.isEmpty)
                const OwnerCard(
                  child: Text('أضف محطة لتظهر تقييماتها هنا.',
                      textAlign: TextAlign.right, style: AppTextStyles.body),
                ),
              for (final station in stations) ...[
                _StationReviewLink(
                  station: station,
                  reviews: widget.store.reviews
                      .where((review) => review.stationId == station.id)
                      .toList(),
                ),
                const SizedBox(height: 10),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildFilter(List<OwnerStation> stations) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedStation == 'كل المحطات' ||
                    stations.any((station) => station.name == selectedStation)
                ? selectedStation
                : 'كل المحطات',
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            alignment: AlignmentDirectional.center,
            onChanged: (value) {
              if (value != null) setState(() => selectedStation = value);
            },
            items: [
              'كل المحطات',
              ...stations.map((station) => station.name),
            ]
                .map((station) => DropdownMenuItem(
                      value: station,
                      child: Center(
                        child: Text(station,
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.brand)),
                      ),
                    ))
                .toList(),
          ),
        ),
      );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});
  final OwnerReview review;
  @override
  Widget build(BuildContext context) => OwnerCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${review.customerName} · ${review.rating} / ٥',
                textAlign: TextAlign.right, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 5),
            Text(review.title,
                textAlign: TextAlign.right, style: AppTextStyles.label),
            const SizedBox(height: 5),
            Text(review.comment,
                textAlign: TextAlign.right, style: AppTextStyles.body),
          ],
        ),
      );
}

class _StationReviewLink extends StatelessWidget {
  const _StationReviewLink({required this.station, required this.reviews});
  final OwnerStation station;
  final List<OwnerReview> reviews;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => StationReviewsScreen(
                station: station,
                reviews: reviews,
              ),
            ),
          ),
          child: OwnerCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(station.name,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 3),
                      Text('${reviews.length} تقييماً · ${station.address}',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_left_rounded,
                    color: AppColors.secondary),
              ],
            ),
          ),
        ),
      );
}
