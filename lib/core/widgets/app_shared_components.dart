import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.danger = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool danger;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 48,
        child: outlined
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: icon == null
                    ? const SizedBox.shrink()
                    : Icon(icon, size: 19),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: danger ? AppColors.error : AppColors.brand,
                  side: BorderSide(
                      color: danger ? AppColors.error : AppColors.brand),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  textStyle:
                      AppTextStyles.button.copyWith(color: AppColors.brand),
                ),
              )
            : FilledButton.icon(
                onPressed: onPressed,
                icon: icon == null
                    ? const SizedBox.shrink()
                    : Icon(icon, size: 19),
                label: Text(label, style: AppTextStyles.button),
                style: FilledButton.styleFrom(
                  backgroundColor: danger ? AppColors.error : AppColors.brand,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                ),
              ),
      );
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: child,
      );
}

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge(this.label, {super.key, this.tone = AppColors.success});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: tone, fontWeight: FontWeight.w700)),
      );
}

class UnifiedNavItem {
  const UnifiedNavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class UnifiedBottomNavBar extends StatelessWidget {
  const UnifiedBottomNavBar({
    super.key,
    required this.index,
    required this.onTap,
    this.items,
  });

  final int index;
  final ValueChanged<int> onTap;
  final List<UnifiedNavItem>? items;

  static const defaultItems = [
    UnifiedNavItem('لوحة التحكم', Icons.home_outlined),
    UnifiedNavItem('محطاتي', Icons.bolt_outlined),
    UnifiedNavItem('التقييمات', Icons.chat_bubble_outline_rounded),
    UnifiedNavItem('حسابي', Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = items ?? defaultItems;
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < entries.length; i++)
            Expanded(
              child: InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  alignment: Alignment.center,
                  height: 80,
                  decoration: BoxDecoration(
                    color: index == i ? AppColors.mint : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(entries[i].icon,
                          size: 22,
                          color: index == i
                              ? AppColors.brand
                              : AppColors.secondary),
                      const SizedBox(height: 3),
                      Text(entries[i].label,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.25,
                            fontWeight:
                                index == i ? FontWeight.w600 : FontWeight.w400,
                            color: index == i
                                ? AppColors.brand
                                : AppColors.secondary,
                          )),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
