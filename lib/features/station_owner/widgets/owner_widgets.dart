import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'station_image_widget.dart';

class CustomLabeledTextField extends StatefulWidget {
  const CustomLabeledTextField(
      {super.key,
      required this.label,
      this.hint,
      this.helperText,
      this.controller,
      this.keyboardType,
      this.errorText,
      this.enabled = true,
      this.obscureText = false,
      this.prefix,
      this.suffix,
      this.maxLines = 1,
      this.onChanged});
  final String label;
  final String? hint, helperText, errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled, obscureText;
  final Widget? prefix, suffix;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  @override
  State<CustomLabeledTextField> createState() => _CustomLabeledTextFieldState();
}

class _CustomLabeledTextFieldState extends State<CustomLabeledTextField> {
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    final borderColor = widget.errorText != null
        ? AppColors.error
        : focused
            ? AppColors.brand
            : AppColors.border;
    final message = widget.errorText ?? widget.helperText;
    final messageColor =
        widget.errorText != null ? AppColors.error : AppColors.secondary;

    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
            color:
                widget.errorText == null ? AppColors.border : AppColors.error),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            textAlign: TextAlign.right,
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w600,
              fontVariations: const [FontVariation('wght', 600)],
              height: 24 / 14,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                if (widget.prefix != null) widget.prefix!,
                Expanded(
                  child: Focus(
                    onFocusChange: (value) => setState(() => focused = value),
                    child: TextField(
                      controller: widget.controller,
                      onChanged: widget.onChanged,
                      keyboardType: widget.keyboardType,
                      enabled: widget.enabled,
                      obscureText: widget.obscureText,
                      maxLines: widget.obscureText ? 1 : widget.maxLines,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.center,
                      style: AppTextStyles.body.copyWith(
                        height: 24 / 16,
                        color:
                            widget.enabled ? AppColors.ink : AppColors.disabled,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        isDense: true,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                if (widget.suffix != null) widget.suffix!,
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (message != null)
            SizedBox(
              height: 24,
              child: Text(
                message,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  height: 20 / 12,
                  color: messageColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DocumentUploadTile extends StatelessWidget {
  const DocumentUploadTile(
      {super.key,
      required this.title,
      required this.onTap,
      this.fileName,
      this.error = false,
      this.onRemove});
  final String title;
  final String? fileName;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final bool error;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, textAlign: TextAlign.right, style: AppTextStyles.label),
        const SizedBox(height: 8),
        InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Container(
                height: 122,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                        color: error ? AppColors.error : AppColors.border)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('الوثائق الرسمية',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption),
                      const Spacer(),
                      Row(children: [
                        if (fileName != null)
                          IconButton(
                              onPressed: onRemove,
                              icon: const Icon(Icons.close_rounded,
                                  size: 18, color: AppColors.secondary)),
                        Expanded(
                            child: Text(fileName ?? '＋ اختر ملفاً',
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontFamily: AppTextStyles.family,
                                    fontSize: 14,
                                    color: fileName == null
                                        ? AppColors.ink
                                        : AppColors.brand)))
                      ]),
                      Text(
                          fileName == null
                              ? 'صيغ الامتداد PDF, PNG, JPG • 5 MB'
                              : 'تم إرفاق الملف',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption)
                    ]))),
        if (error)
          const Padding(
              padding: EdgeInsets.only(top: 5, right: 2),
              child: Text('يرجى إرفاق هذه الوثيقة',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: AppColors.error, fontSize: 11)))
      ]);
}

class CustomLabeledDropdown extends StatelessWidget {
  const CustomLabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.helperText,
    this.errorText,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? helperText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final message = errorText ?? helperText;
    final fieldColor = errorText == null ? AppColors.border : AppColors.error;
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: fieldColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label,
              textAlign: TextAlign.right,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w600,
                fontVariations: const [FontVariation('wght', 600)],
                height: 24 / 14,
              )),
          const SizedBox(height: 8),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: fieldColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: items.contains(value) ? value : null,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                onChanged: onChanged,
                items: items
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(item, style: AppTextStyles.body),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (message != null)
            Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.caption.copyWith(
                height: 20 / 12,
                color:
                    errorText == null ? AppColors.secondary : AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}

class OwnerButton extends StatelessWidget {
  const OwnerButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.outlined = false,
      this.danger = false,
      this.icon});
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
              icon:
                  icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
              label: Text(label),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brand,
                  side: const BorderSide(color: AppColors.brand),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  textStyle:
                      AppTextStyles.button.copyWith(color: AppColors.brand)))
          : FilledButton.icon(
              onPressed: onPressed,
              icon:
                  icon == null ? const SizedBox.shrink() : Icon(icon, size: 19),
              label: Text(label, style: AppTextStyles.button),
              style: FilledButton.styleFrom(
                  backgroundColor: danger ? AppColors.error : AppColors.brand,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd)))));
}

class OwnerStickyAction extends StatelessWidget {
  const OwnerStickyAction({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        height: 76,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 14),
        decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.border))),
        child: child,
      );
}

class OwnerCard extends StatelessWidget {
  const OwnerCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.border)),
      child: child);
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(children: [
        if (action != null)
          TextButton(
              onPressed: onAction,
              child: Text(action!,
                  style: const TextStyle(
                      color: AppColors.brand,
                      fontSize: 12,
                      fontWeight: FontWeight.w700))),
        const Spacer(),
        Text(title, style: AppTextStyles.heading)
      ]);
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.tone = AppColors.success});
  final String label;
  final Color tone;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: tone.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: tone, fontWeight: FontWeight.w700)));
}

class UnifiedBottomNavBar extends StatelessWidget {
  const UnifiedBottomNavBar(
      {super.key, required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;
  static const _items = [
    ('لوحة التحكم', Icons.home_outlined),
    ('محطاتي', Icons.bolt_outlined),
    ('التقييمات', Icons.chat_bubble_outline_rounded),
    ('حسابي', Icons.person_outline_rounded),
  ];
  @override
  Widget build(BuildContext context) => Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(children: [
        for (var i = 0; i < _items.length; i++)
          Expanded(
              child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Container(
                      alignment: Alignment.center,
                      height: 80,
                      decoration: BoxDecoration(
                          color:
                              index == i ? AppColors.mint : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd)),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_items[i].$2,
                                size: 22,
                                color: index == i
                                    ? AppColors.brand
                                    : AppColors.secondary),
                            const SizedBox(height: 3),
                            Text(_items[i].$1,
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 11,
                                    height: 1.25,
                                    fontWeight: index == i
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: index == i
                                        ? AppColors.brand
                                        : AppColors.secondary))
                          ]))))
      ]));
}

class OwnerBackAction extends StatelessWidget {
  const OwnerBackAction({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: 'رجوع',
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_back_rounded),
      );
}

Widget stationImage({double height = 132, String? imagePath}) => ClipRRect(
    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    child: SizedBox(
        height: height,
        width: double.infinity,
        child: buildStationImage(imagePath)));

class OwnerReviewCard extends StatelessWidget {
  const OwnerReviewCard({
    super.key,
    required this.name,
    required this.text,
    required this.stars,
    required this.date,
  });

  final String name;
  final String text;
  final String date;
  final int stars;

  @override
  Widget build(BuildContext context) => OwnerCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(date, style: AppTextStyles.caption),
                const Spacer(),
                Text(name, style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                for (var i = 0; i < 5; i++)
                  Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 15,
                    color: AppColors.accent,
                  ),
                const Spacer(),
                const Text(
                  'جديد',
                  style: TextStyle(color: AppColors.primary, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(text, textAlign: TextAlign.right, style: AppTextStyles.body),
          ],
        ),
      );
}

class OwnerDetailRow extends StatelessWidget {
  const OwnerDetailRow(this.label, this.value, {super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Text(value, style: AppTextStyles.bodyMedium),
            const Spacer(),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      );
}

class OwnerStationCard extends StatelessWidget {
  const OwnerStationCard({
    super.key,
    required this.name,
    required this.address,
    required this.status,
    required this.chargerCount,
    required this.ratingSummary,
    required this.onTap,
    this.imagePath,
    this.onEdit,
  });

  final String name;
  final String address;
  final String status;
  final String chargerCount;
  final String ratingSummary;
  final VoidCallback onTap;
  final String? imagePath;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: OwnerCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                stationImage(height: 174, imagePath: imagePath),
                const SizedBox(height: 10),
                Row(
                  children: [
                    StatusPill(
                      status,
                      tone: status == 'نشطة'
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.h3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(address,
                    textAlign: TextAlign.right, style: AppTextStyles.caption),
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        tooltip: 'تعديل المحطة',
                        visualDensity: VisualDensity.compact,
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.brand, size: 20),
                      ),
                    const Spacer(),
                    Flexible(
                      child: Text(chargerCount,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.label),
                    ),
                  ],
                ),
                Text(ratingSummary,
                    textAlign: TextAlign.right, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      );
}
