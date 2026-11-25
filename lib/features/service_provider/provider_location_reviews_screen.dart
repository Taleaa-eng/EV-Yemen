import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_shared_components.dart';
import '../station_owner/widgets/owner_widgets.dart';
import 'provider_account_screens.dart';

enum ProviderViewTab { location, reviews, profile }

enum ProviderContentState { loading, empty, error, populated }

class ProviderLocationReviewsScreen extends StatefulWidget {
  const ProviderLocationReviewsScreen({
    super.key,
    required this.subtype,
    required this.latitude,
    required this.longitude,
    this.address,
    this.locationState = ProviderContentState.populated,
    this.reviewsState = ProviderContentState.populated,
  });

  final String subtype;
  final double latitude;
  final double longitude;
  final String? address;
  final ProviderContentState locationState;
  final ProviderContentState reviewsState;

  @override
  State<ProviderLocationReviewsScreen> createState() =>
      _ProviderLocationReviewsScreenState();
}

class _ProviderLocationReviewsScreenState
    extends State<ProviderLocationReviewsScreen> {
  ProviderViewTab tab = ProviderViewTab.location;
  int zoom = 1;
  ProviderContentState? locationOverride;
  ProviderContentState? reviewsOverride;

  bool get isWorkshop => widget.subtype.contains('ورشة');
  String get placeName => isWorkshop ? 'موقع الورشة' : 'موقع المتجر';
  String get placeAddress => widget.address?.isNotEmpty == true
      ? widget.address!
      : (isWorkshop ? 'شارع الستين، صنعاء' : 'شارع حدة، صنعاء');
  ProviderContentState get locationState =>
      locationOverride ?? widget.locationState;
  ProviderContentState get reviewsState =>
      reviewsOverride ?? widget.reviewsState;

  Future<void> _retryLocation() async {
    setState(() => locationOverride = ProviderContentState.loading);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted)
      setState(() => locationOverride = ProviderContentState.populated);
  }

  Future<void> _retryReviews() async {
    setState(() => reviewsOverride = ProviderContentState.loading);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (mounted)
      setState(() => reviewsOverride = ProviderContentState.populated);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(switch (tab) {
            ProviderViewTab.location => 'الموقع',
            ProviderViewTab.reviews => 'التقييمات',
            ProviderViewTab.profile => 'الملف الشخصي',
          }),
          actions: [
            if (Navigator.of(context).canPop())
              OwnerBackAction(onPressed: () => Navigator.pop(context)),
          ],
        ),
        body: IndexedStack(
          index: tab.index,
          children: [
            _LocationView(
              title: placeName,
              address: placeAddress,
              coordinates:
                  '${widget.latitude.toStringAsFixed(5)}, ${widget.longitude.toStringAsFixed(5)}',
              zoom: zoom,
              onZoomIn: () =>
                  setState(() => zoom = (zoom + 1).clamp(1, 3).toInt()),
              onZoomOut: () =>
                  setState(() => zoom = (zoom - 1).clamp(1, 3).toInt()),
              onRecenter: () => setState(() => zoom = 1),
              state: locationState,
              onRetry: _retryLocation,
            ),
            _RatingsView(
              isWorkshop: isWorkshop,
              state: reviewsState,
              onRetry: _retryReviews,
            ),
            ProviderProfileTab(subtype: widget.subtype),
          ],
        ),
        bottomNavigationBar: UnifiedBottomNavBar(
          index: tab.index,
          items: const [
            UnifiedNavItem('الموقع', Icons.location_on_outlined),
            UnifiedNavItem('التقييمات', Icons.chat_bubble_outline_rounded),
            UnifiedNavItem('الملف الشخصي', Icons.account_circle_outlined),
          ],
          onTap: (index) => setState(() => tab = ProviderViewTab.values[index]),
        ),
      );
}

class _LocationView extends StatelessWidget {
  const _LocationView({
    required this.title,
    required this.address,
    required this.coordinates,
    required this.zoom,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
    required this.state,
    required this.onRetry,
  });

  final String title;
  final String address;
  final String coordinates;
  final int zoom;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;
  final ProviderContentState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (state) {
        ProviderContentState.loading => const _StateView(
            icon: Icons.map_outlined,
            title: 'جارٍ تحميل الموقع',
            message: 'يرجى الانتظار حتى تظهر خريطة الموقع.',
            loading: true,
          ),
        ProviderContentState.empty => const _StateView(
            icon: Icons.location_off_outlined,
            title: 'لم تتم إضافة موقع بعد',
            message: 'سيظهر موقع مزود الخدمة هنا عند توفره.',
          ),
        ProviderContentState.error => _StateView(
            icon: Icons.wifi_off_rounded,
            title: 'تعذّر تحميل الموقع',
            message: 'تحقق من الاتصال وحاول تحديث الصفحة.',
            showRetry: true,
            onRetry: onRetry,
          ),
        ProviderContentState.populated => _populated(context),
      };

  Widget _populated(BuildContext context) => RefreshIndicator(
        onRefresh: () async =>
            await Future<void>.delayed(const Duration(milliseconds: 450)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
          children: [
            Text(title, textAlign: TextAlign.right, style: AppTextStyles.h2),
            const SizedBox(height: 10),
            _MapPreview(
              zoom: zoom,
              onZoomIn: onZoomIn,
              onZoomOut: onZoomOut,
              onRecenter: onRecenter,
            ),
            const SizedBox(height: 14),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('العنوان التفصيلي',
                      textAlign: TextAlign.right, style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(address,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 8),
                  const Text('الإحداثيات',
                      textAlign: TextAlign.right, style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(coordinates,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const AppStatusBadge('الموقع متاح'),
          ],
        ),
      );
}

class _MapPreview extends StatelessWidget {
  const _MapPreview({
    required this.zoom,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onRecenter,
  });

  final int zoom;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: SizedBox(
          height: 205,
          child: Stack(
            children: [
              Positioned.fill(
                child: ColoredBox(
                  color: const Color(0xFFEAF1EC),
                  child: CustomPaint(painter: _MapRoadPainter()),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: AnimatedScale(
                    scale: 1 + (zoom - 1) * .12,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x3320412F),
                              blurRadius: 10,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Icon(Icons.location_on_rounded,
                          color: AppColors.white, size: 25),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Column(
                  children: [
                    _MapButton(icon: Icons.add, onPressed: onZoomIn),
                    const SizedBox(height: 4),
                    _MapButton(icon: Icons.remove, onPressed: onZoomOut),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: _MapButton(
                    icon: Icons.my_location_outlined, onPressed: onRecenter),
              ),
              const Positioned(
                bottom: 12,
                right: 12,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text('Sana’a • Yemen',
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      );
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: AppColors.brand, size: 21),
          ),
        ),
      );
}

class _MapRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final park = Paint()..color = const Color(0xFFD7E9DC);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(size.width * .18, size.height * .66),
            width: size.width * .25,
            height: size.height * .30),
        park);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(size.width * .67, size.height * .50, size.width * .24,
                size.height * .22),
            const Radius.circular(14)),
        park);

    final minor = Paint()
      ..color = AppColors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final major = Paint()
      ..color = const Color(0xFFD5E0D9)
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roadCenter = Paint()
      ..color = AppColors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roads = <Path>[
      Path()
        ..moveTo(-10, size.height * .18)
        ..cubicTo(size.width * .25, size.height * .25, size.width * .55,
            size.height * .02, size.width + 10, size.height * .22),
      Path()
        ..moveTo(size.width * .08, size.height + 8)
        ..cubicTo(size.width * .28, size.height * .54, size.width * .48,
            size.height * .72, size.width * .62, -8),
      Path()
        ..moveTo(size.width * .78, size.height + 8)
        ..cubicTo(size.width * .55, size.height * .65, size.width * .80,
            size.height * .33, size.width * .95, -8),
      Path()
        ..moveTo(-10, size.height * .80)
        ..cubicTo(size.width * .30, size.height * .63, size.width * .70,
            size.height * .92, size.width + 10, size.height * .70),
    ];
    canvas.drawPath(roads[3], major);
    canvas.drawPath(roads[3], roadCenter);
    for (final road in roads.take(3)) {
      canvas.drawPath(road, minor);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RatingsView extends StatelessWidget {
  const _RatingsView(
      {required this.isWorkshop, required this.state, required this.onRetry});

  final bool isWorkshop;
  final ProviderContentState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (state) {
        ProviderContentState.loading => const _StateView(
            icon: Icons.star_outline_rounded,
            title: 'جارٍ تحميل التقييمات',
            message: 'يرجى الانتظار حتى تظهر تقييمات العملاء.',
            loading: true,
          ),
        ProviderContentState.empty => const _StateView(
            icon: Icons.rate_review_outlined,
            title: 'لا توجد تقييمات بعد',
            message: 'ستظهر تقييمات العملاء هنا بعد استلام أول تقييم.',
          ),
        ProviderContentState.error => _StateView(
            icon: Icons.wifi_off_rounded,
            title: 'تعذّر تحميل التقييمات',
            message: 'تحقق من الاتصال وحاول تحديث الصفحة.',
            showRetry: true,
            onRetry: onRetry,
          ),
        ProviderContentState.populated => _populated(),
      };

  Widget _populated() => RefreshIndicator(
        onRefresh: () async =>
            await Future<void>.delayed(const Duration(milliseconds: 450)),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 22),
          children: [
            const Text('تقييمات العملاء',
                textAlign: TextAlign.right, style: AppTextStyles.h2),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('التقييم العام',
                      textAlign: TextAlign.right, style: AppTextStyles.body),
                  const SizedBox(height: 2),
                  const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('4.9 / 5',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink)),
                  ),
                  const SizedBox(height: 1),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('تقييم', style: AppTextStyles.caption),
                      SizedBox(width: 4),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text('126', style: AppTextStyles.caption),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const _RatingDistribution(),
            const SizedBox(height: 14),
            _ReviewCard(
              name: 'أحمد محمد',
              score: '5 / 5',
              comment: isWorkshop
                  ? 'خدمة واضحة وسهلة'
                  : 'توفر القطعة المطلوبة بسرعة.',
              age: 'منذ يومين',
            ),
            const SizedBox(height: 12),
            _ReviewCard(
              name: 'سناء أحمد',
              score: '4 / 5',
              comment: isWorkshop
                  ? 'فحص دقيق وخدمة جيدة'
                  : 'قطع أصلية وتعامل ممتاز.',
              age: 'منذ أسبوع',
            ),
            const SizedBox(height: 12),
            _ReviewCard(
              name: 'عبدالعزيز الوصابي',
              score: '5 / 5',
              comment: isWorkshop
                  ? 'التزام بالموعد وسرعة في العمل'
                  : 'وصلت القطعة في الموعد المحدد.',
              age: 'منذ أسبوعين',
            ),
          ],
        ),
      );
}

class _RatingDistribution extends StatelessWidget {
  const _RatingDistribution();

  final values = const [0.82, 0.14, 0.05, 0.03, 0.02];

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
        child: Column(
          children: [
            for (var i = 0; i < values.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('${5 - i} ★',
                          style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusPill),
                        child: LinearProgressIndicator(
                          value: values[i],
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE4E9EC),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF269A63)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.name,
    required this.score,
    required this.comment,
    required this.age,
  });

  final String name;
  final String score;
  final String comment;
  final String age;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(name,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star_rounded,
                    size: 16, color: Color(0xFFE2A226)),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(score,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.ink, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment,
                textAlign: TextAlign.right,
                style: AppTextStyles.body.copyWith(fontSize: 15)),
            const SizedBox(height: 6),
            Text(age, textAlign: TextAlign.right, style: AppTextStyles.caption),
          ],
        ),
      );
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    required this.message,
    this.loading = false,
    this.onRetry,
    this.showRetry = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final bool loading;
  final bool showRetry;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 46, 24, 24),
        children: [
          Center(
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (loading)
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  else
                    Icon(icon, size: 36, color: AppColors.brand),
                  const SizedBox(height: 14),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading),
                  const SizedBox(height: 6),
                  Text(message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption),
                  if (showRetry) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
}
