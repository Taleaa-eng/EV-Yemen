import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../station_owner/widgets/owner_widgets.dart';

class ProviderMapPoint {
  const ProviderMapPoint(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class ProviderMapPicker extends StatefulWidget {
  const ProviderMapPicker({super.key, this.initial});
  final ProviderMapPoint? initial;

  @override
  State<ProviderMapPicker> createState() => _ProviderMapPickerState();
}

class _ProviderMapPickerState extends State<ProviderMapPicker> {
  late double lat = widget.initial?.latitude ?? 15.3694;
  late double lng = widget.initial?.longitude ?? 44.1910;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('تحديد الموقع على الخريطة'),
          centerTitle: true,
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) => GestureDetector(
                    onTapDown: (event) {
                      final pos = event.localPosition;
                      setState(() {
                        lat =
                            15.30 + (1 - pos.dy / constraints.maxHeight) * .14;
                        lng = 44.10 + pos.dx / constraints.maxWidth * .18;
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          const Positioned.fill(
                              child: ColoredBox(color: Color(0xffe8f0e9))),
                          CustomPaint(size: Size.infinite, painter: _Roads()),
                          Center(
                              child: Icon(Icons.location_pin,
                                  size: 52, color: AppColors.brand)),
                          const Positioned(
                            top: 16,
                            right: 16,
                            child: Text('اضغط على الخريطة لتحديد الموقع',
                                style: AppTextStyles.bodyMedium),
                          ),
                          Positioned(
                            bottom: 14,
                            left: 14,
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text('حرّك المؤشر إلى موقع منشأتك بدقة.',
                  textAlign: TextAlign.right, style: AppTextStyles.body),
            ),
          ],
        ),
        bottomNavigationBar: OwnerStickyAction(
          child: OwnerButton(
            label: 'تأكيد الموقع',
            onPressed: () => Navigator.pop(context, ProviderMapPoint(lat, lng)),
          ),
        ),
      );
}

class _Roads extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final roads = [
      Path()
        ..moveTo(0, size.height * .25)
        ..cubicTo(size.width * .25, size.height * .4, size.width * .6,
            size.height * .1, size.width, size.height * .35),
      Path()
        ..moveTo(size.width * .15, size.height)
        ..cubicTo(size.width * .35, size.height * .6, size.width * .7,
            size.height * .8, size.width * .8, 0),
      Path()
        ..moveTo(0, size.height * .8)
        ..cubicTo(size.width * .3, size.height * .55, size.width * .7,
            size.height * .95, size.width, size.height * .7),
    ];
    for (final road in roads) {
      canvas.drawPath(road, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
