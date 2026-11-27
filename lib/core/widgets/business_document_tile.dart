import 'package:flutter/material.dart';

import '../models/business_document.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_shared_components.dart';

class BusinessDocumentTile extends StatelessWidget {
  const BusinessDocumentTile({
    super.key,
    required this.title,
    required this.instruction,
    required this.document,
    required this.onPick,
    required this.onRemove,
    this.error = false,
  });

  final String title;
  final String instruction;
  final BusinessDocument? document;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final bool error;

  String _formatSize(int bytes) => bytes < 1024 * 1024
      ? '${(bytes / 1024).ceil()} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'مطلوب',
                    style: TextStyle(
                      color: AppColors.brand,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.label),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(instruction,
                textAlign: TextAlign.right, style: AppTextStyles.caption),
            const SizedBox(height: 10),
            if (document != null) ...[
              Row(
                children: [
                  IconButton(
                    tooltip: 'إزالة الملف',
                    onPressed: onRemove,
                    icon:
                        const Icon(Icons.close_rounded, color: AppColors.error),
                  ),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${_formatSize(document!.size)} • ${document!.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.success),
                ],
              ),
              TextButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('استبدال الملف'),
              ),
            ] else
              OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('إرفاق ملف (PDF أو صورة، حتى 5 MB)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(
                      color: error ? AppColors.error : AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            if (error)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('هذا المستند مطلوب',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: AppColors.error)),
              ),
          ],
        ),
      );
}
