import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_shared_components.dart';
import 'dealer_local_store.dart';

class DealerSectionTitle extends StatelessWidget {
  const DealerSectionTitle(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(children: [
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
        const Spacer(),
        Text(title, textAlign: TextAlign.right, style: AppTextStyles.h2),
      ]);
}

class DealerVehiclePhoto extends StatelessWidget {
  const DealerVehiclePhoto({super.key, required this.path, this.height = 216});
  final String path;
  final double height;

  @override
  Widget build(BuildContext context) {
    final image = path.startsWith('assets/')
        ? Image.asset(path, fit: BoxFit.cover)
        : File(path).existsSync()
            ? Image.file(File(path), fit: BoxFit.cover)
            : const Icon(Icons.directions_car_outlined,
                size: 56, color: AppColors.brand);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: image,
      ),
    );
  }
}

class DealerVehicleCard extends StatelessWidget {
  const DealerVehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    this.compact = false,
  });
  final DealerVehicle vehicle;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(vehicle.displayName,
                  textAlign: TextAlign.left,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${formatYemeniRial(vehicle.priceYer)} ر.ي',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.h3,
                ),
              ),
              const SizedBox(height: 4),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '${vehicle.connector} • ${vehicle.rangeKm} كم • ${vehicle.available ? 'متوفرة للحجز' : 'متوقفة'}',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
}

class DealerOrderCard extends StatelessWidget {
  const DealerOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });
  final DealerOrder order;
  final VoidCallback onTap;

  Color get _statusTone => switch (order.status) {
        'جديد' => AppColors.brand,
        'قيد التنفيذ' => AppColors.info,
        'مكتمل' => AppColors.success,
        _ => AppColors.error,
      };

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: AppStatusBadge(order.status, tone: _statusTone),
              ),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${order.customer} • ${order.requestType}',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 8),
                    Text(order.vehicleName,
                        textAlign: TextAlign.right, style: AppTextStyles.body),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('${order.id} • ${order.city} • ${order.date}',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class DealerEmptyCard extends StatelessWidget {
  const DealerEmptyCard({
    super.key,
    required this.title,
    required this.description,
  });
  final String title, description;

  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, textAlign: TextAlign.right, style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(description,
                textAlign: TextAlign.right, style: AppTextStyles.caption),
          ],
        ),
      );
}

Widget dealerSearchField({
  required String hint,
  required ValueChanged<String> onChanged,
}) =>
    TextField(
      onChanged: onChanged,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      ),
    );
