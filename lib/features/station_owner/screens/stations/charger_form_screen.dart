import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/station_charger.dart';
import '../../widgets/owner_widgets.dart';

class ChargerFormScreen extends StatefulWidget {
  const ChargerFormScreen({super.key, this.charger});
  final StationCharger? charger;
  @override
  State<ChargerFormScreen> createState() => _ChargerFormScreenState();
}

class _ChargerFormScreenState extends State<ChargerFormScreen> {
  late final id = TextEditingController(text: widget.charger?.id ?? '');
  late final power = TextEditingController(text: widget.charger?.powerKw ?? '');
  late final tariff = TextEditingController(text: widget.charger?.tariff ?? '');
  late String connector = widget.charger?.connector ?? 'CCS2 Fast';
  late bool available = widget.charger?.available ?? true;
  bool error = false;
  static const connectors = ['CCS2 Fast', 'CHAdeMO', 'Type 2', 'GB/T'];
  @override
  void dispose() {
    id.dispose();
    power.dispose();
    tariff.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(
                widget.charger == null ? 'إضافة نقطة شحن' : 'تعديل الشاحن'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: ListView(padding: const EdgeInsets.all(20), children: [
            Text(
                widget.charger == null
                    ? 'بيانات نقطة الشحن'
                    : 'تحديث بيانات نقطة الشحن',
                textAlign: TextAlign.right,
                style: AppTextStyles.h1),
            const SizedBox(height: 16),
            CustomLabeledTextField(
                label: 'معرّف نقطة الشحن',
                hint: 'مثال: BAY-01',
                controller: id,
                errorText:
                    error && id.text.trim().isEmpty ? 'هذا الحقل مطلوب' : null),
            const SizedBox(height: 12),
            CustomLabeledDropdown(
                label: 'نوع الموصل',
                value: connector,
                items: connectors,
                onChanged: (v) => setState(() => connector = v ?? connector)),
            const SizedBox(height: 12),
            CustomLabeledTextField(
                label: 'القدرة القصوى kW',
                hint: 'مثال: 120',
                controller: power,
                keyboardType: TextInputType.number,
                errorText: error && power.text.trim().isEmpty
                    ? 'هذا الحقل مطلوب'
                    : null),
            const SizedBox(height: 12),
            CustomLabeledTextField(
                label: 'تعرفة الشحن ر.ي / kWh',
                hint: 'مثال: 180',
                controller: tariff,
                keyboardType: TextInputType.number,
                errorText: error && tariff.text.trim().isEmpty
                    ? 'هذا الحقل مطلوب'
                    : null),
            const SizedBox(height: 12),
            OwnerCard(
                child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: available,
                    onChanged: (v) => setState(() => available = v),
                    title: const Text('الحالة المعروضة للعملاء',
                        textAlign: TextAlign.right))),
          ])),
          OwnerStickyAction(
              child: OwnerButton(
                  label: widget.charger == null
                      ? 'إضافة نقطة الشحن'
                      : 'حفظ التغييرات',
                  onPressed: () {
                    setState(() => error = true);
                    if (id.text.trim().isEmpty ||
                        power.text.trim().isEmpty ||
                        tariff.text.trim().isEmpty) {
                      return;
                    }
                    Navigator.pop(
                        context,
                        StationCharger(
                            id: id.text.trim(),
                            connector: connector,
                            powerKw: power.text.trim(),
                            tariff: tariff.text.trim(),
                            available: available));
                  }))
        ])),
      );
}
