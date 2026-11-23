import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/station_charger.dart';
import '../../models/owner_station.dart';
import '../../utils/owner_feedback.dart';
import '../../widgets/owner_widgets.dart';
import 'charger_management_screen.dart';

class StationFormScreen extends StatefulWidget {
  const StationFormScreen(
      {super.key, this.edit = false, this.initialChargers, this.station});
  final bool edit;
  final List<StationCharger>? initialChargers;
  final OwnerStation? station;
  @override
  State<StationFormScreen> createState() => _StationFormScreenState();
}

class _StationFormScreenState extends State<StationFormScreen> {
  late final name = TextEditingController(text: widget.station?.name ?? '');
  late final address =
      TextEditingController(text: widget.station?.address ?? '');
  late final phone = TextEditingController(text: widget.station?.phone ?? '');
  late List<StationCharger> chargers = [
    ...(widget.initialChargers ??
        widget.station?.chargers ??
        <StationCharger>[])
  ];
  late bool active = widget.station?.active ?? true;
  late String? imagePath = widget.station?.imagePath;
  bool pickingImage = false;
  bool error = false;
  @override
  void dispose() {
    name.dispose();
    address.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> manageChargers() async {
    final result = await Navigator.push<List<StationCharger>>(
        context,
        MaterialPageRoute(
            builder: (_) => ChargerManagementScreen(chargers: chargers)));
    if (result != null) setState(() => chargers = result);
  }

  Future<void> _pickStationImage() async {
    try {
      final selection = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (selection == null || selection.files.isEmpty) return;
      final sourcePath = selection.files.single.path;
      if (sourcePath == null) {
        if (mounted) showOwnerMessage(context, 'تعذّر قراءة الصورة المختارة.');
        return;
      }
      setState(() => pickingImage = true);
      final documents = await getApplicationDocumentsDirectory();
      final imageDirectory =
          Directory('${documents.path}${Platform.pathSeparator}station_images');
      await imageDirectory.create(recursive: true);
      final name = selection.files.single.name;
      final rawExtension = name.contains('.') ? name.split('.').last : 'jpg';
      final extension =
          rawExtension.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
      final destination = File(
          '${imageDirectory.path}${Platform.pathSeparator}station_${DateTime.now().microsecondsSinceEpoch}.${extension.isEmpty ? 'jpg' : extension}');
      await File(sourcePath).copy(destination.path);
      if (!mounted) return;
      setState(() {
        imagePath = destination.path;
        pickingImage = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => pickingImage = false);
        showOwnerMessage(context, 'تعذّر اختيار الصورة. حاول مرة أخرى.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(widget.edit ? 'تعديل المحطة' : 'إضافة محطة جديدة'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                            widget.edit
                                ? 'تعديل بيانات المحطة'
                                : 'بيانات المحطة الجديدة',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.title),
                        const SizedBox(height: 20),
                        CustomLabeledTextField(
                            label: 'اسم المحطة',
                            hint: 'أدخل اسم المحطة',
                            controller: name,
                            errorText: error && name.text.trim().isEmpty
                                ? 'هذا الحقل مطلوب'
                                : null),
                        const SizedBox(height: 12),
                        CustomLabeledTextField(
                            label: 'العنوان التفصيلي',
                            hint: 'المدينة، الشارع، أقرب معلم',
                            controller: address,
                            errorText: error && address.text.trim().isEmpty
                                ? 'هذا الحقل مطلوب'
                                : null),
                        const SizedBox(height: 12),
                        CustomLabeledTextField(
                            label: 'رقم التواصل',
                            hint: '+967 7XX XXX XXX',
                            controller: phone,
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 12),
                        const Text('إضافة صورة للمحطة',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: pickingImage ? null : _pickStationImage,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          child: Stack(
                            children: [
                              stationImage(height: 145, imagePath: imagePath),
                              if (pickingImage)
                                const Positioned.fill(
                                  child: ColoredBox(
                                    color: Color(0x66000000),
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                ),
                              if (imagePath != null && !pickingImage)
                                PositionedDirectional(
                                  top: 8,
                                  end: 8,
                                  child: IconButton.filled(
                                    tooltip: 'إزالة الصورة',
                                    onPressed: () =>
                                        setState(() => imagePath = null),
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: pickingImage ? null : _pickStationImage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: Text(imagePath == null
                              ? 'اختيار صورة من الجهاز'
                              : 'استبدال الصورة'),
                        ),
                        const SizedBox(height: 14),
                        OwnerCard(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: active,
                                activeColor: AppColors.primary,
                                onChanged: (v) => setState(() => active = v),
                                title: const Text('المحطة متاحة للعمل',
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.bodyMedium))),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(
                              child: Text('إدارة الشواحن (${chargers.length})',
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.h3)),
                          TextButton.icon(
                              onPressed: manageChargers,
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('إدارة'))
                        ]),
                        OwnerCard(
                            child: Column(children: [
                          for (final charger in chargers)
                            ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                    '${charger.id} · ${charger.connector}',
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.bodyMedium),
                                subtitle: Text(
                                    '${charger.powerKw} kW · ${charger.tariff} ر.ي / kWh · ${charger.available ? 'متاح' : 'غير متاح'}',
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.caption),
                                trailing: const Icon(Icons.ev_station_rounded,
                                    color: AppColors.primary)),
                          if (chargers.isEmpty)
                            const Text('لم تتم إضافة نقاط شحن بعد',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.caption),
                          Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                  onPressed: manageChargers,
                                  icon: const Icon(Icons.add),
                                  label: const Text('إضافة نقطة شحن')))
                        ])),
                      ]))),
          OwnerStickyAction(
              child: OwnerButton(
                  label: 'حفظ المحطة',
                  onPressed: () {
                    setState(() => error = true);
                    if (name.text.trim().isEmpty ||
                        address.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.pop(
                      context,
                      OwnerStation(
                        id: widget.station?.id ??
                            DateTime.now().microsecondsSinceEpoch.toString(),
                        name: name.text.trim(),
                        address: address.text.trim(),
                        phone: phone.text.trim(),
                        active: active,
                        chargers: chargers,
                        imagePath: imagePath,
                      ),
                    );
                  }))
        ])),
      );
}
