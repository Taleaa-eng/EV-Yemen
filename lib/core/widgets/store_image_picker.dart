import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class StoreImagePicker extends StatefulWidget {
  const StoreImagePicker({
    super.key,
    this.initialPath,
    this.onChanged,
    this.error = false,
  });

  final String? initialPath;
  final ValueChanged<String?>? onChanged;
  final bool error;

  @override
  State<StoreImagePicker> createState() => _StoreImagePickerState();
}

class _StoreImagePickerState extends State<StoreImagePicker> {
  late String? _path = widget.initialPath;
  bool _busy = false;

  @override
  void didUpdateWidget(covariant StoreImagePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPath != widget.initialPath) {
      _path = widget.initialPath;
    }
  }

  Future<void> _pick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (!mounted || result == null || result.files.isEmpty) return;
      final source = result.files.single.path;
      if (source == null) return;
      setState(() => _busy = true);
      final docs = await getApplicationDocumentsDirectory();
      final folder =
          Directory('${docs.path}${Platform.pathSeparator}store_images');
      await folder.create(recursive: true);
      final extension = result.files.single.name.contains('.')
          ? result.files.single.name.split('.').last.toLowerCase()
          : 'jpg';
      final target = File(
          '${folder.path}${Platform.pathSeparator}store_${DateTime.now().microsecondsSinceEpoch}.$extension');
      await File(source).copy(target.path);
      if (!mounted) return;
      setState(() {
        _path = target.path;
        _busy = false;
      });
      widget.onChanged?.call(_path);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر اختيار صورة المحل.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _path != null && File(_path!).existsSync();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('إضافة صورة للمحل',
            textAlign: TextAlign.right, style: AppTextStyles.label),
        const SizedBox(height: 8),
        InkWell(
          onTap: _busy ? null : _pick,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: widget.error ? AppColors.error : AppColors.border,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  Image.file(File(_path!), fit: BoxFit.cover)
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 34, color: AppColors.brand),
                      SizedBox(height: 8),
                      Text('＋ اختر صورة للمحل',
                          style: AppTextStyles.bodyMedium),
                      Text('JPG، PNG • صورة واحدة',
                          style: AppTextStyles.caption),
                    ],
                  ),
                if (_busy)
                  const ColoredBox(
                    color: Color(0x66000000),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (hasImage && !_busy)
                  PositionedDirectional(
                    top: 6,
                    end: 6,
                    child: IconButton.filled(
                      tooltip: 'إزالة الصورة',
                      onPressed: () {
                        setState(() => _path = null);
                        widget.onChanged?.call(null);
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_path != null)
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              _path!.split(Platform.pathSeparator).last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption,
            ),
          )
        else if (widget.error)
          const Text('صورة المحل مطلوبة',
              textAlign: TextAlign.right,
              style: TextStyle(color: AppColors.error)),
      ],
    );
  }
}
