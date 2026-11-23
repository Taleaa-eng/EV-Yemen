import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../models/station_charger.dart';
import '../../widgets/owner_widgets.dart';
import 'charger_form_screen.dart';

class ChargerManagementScreen extends StatefulWidget {
  const ChargerManagementScreen({super.key, required this.chargers});
  final List<StationCharger> chargers;
  @override
  State<ChargerManagementScreen> createState() =>
      _ChargerManagementScreenState();
}

class _ChargerManagementScreenState extends State<ChargerManagementScreen> {
  late final items = [...widget.chargers];
  Future<void> add() async {
    final result = await Navigator.push<StationCharger>(
        context, MaterialPageRoute(builder: (_) => const ChargerFormScreen()));
    if (result != null) setState(() => items.add(result));
  }

  Future<void> edit(int index) async {
    final result = await Navigator.push<StationCharger>(
        context,
        MaterialPageRoute(
            builder: (_) => ChargerFormScreen(charger: items[index])));
    if (result != null) setState(() => items[index] = result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: const Text('إدارة الشواحن'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context, items))
            ]),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: ListView(padding: const EdgeInsets.all(20), children: [
            Text('${items.length} نقاط شحن',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 14),
            for (var i = 0; i < items.length; i++) ...[
              OwnerCard(
                  child: InkWell(
                      onTap: () => edit(i),
                      child: Row(children: [
                        IconButton(
                            onPressed: () => setState(() => items.removeAt(i)),
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error)),
                        const Spacer(),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(items[i].id, style: AppTextStyles.h3),
                              const SizedBox(height: 4),
                              Text(
                                  '${items[i].connector} · ${items[i].powerKw} kW · ${items[i].tariff} ر.ي / kWh',
                                  style: AppTextStyles.caption),
                              Text(items[i].available ? 'متاح' : 'غير متاح',
                                  style: AppTextStyles.caption.copyWith(
                                      color: items[i].available
                                          ? AppColors.success
                                          : AppColors.secondary))
                            ]),
                        const SizedBox(width: 10),
                        const Icon(Icons.ev_station_rounded,
                            color: AppColors.primary),
                      ]))),
              const SizedBox(height: 10),
            ],
            OwnerButton(
                label: 'إضافة نقطة شحن',
                icon: Icons.add_rounded,
                outlined: true,
                onPressed: add),
          ])),
          OwnerStickyAction(
              child: OwnerButton(
                  label: 'حفظ الشواحن',
                  onPressed: () => Navigator.pop(context, items)))
        ])),
      );
}
