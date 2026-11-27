import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/services/active_role_session.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/logout_confirmation_dialog.dart';
import '../../core/widgets/business_branches_screen.dart';
import '../account_selection/account_type_selection_screen.dart';
import '../customer/services/customer_local_store.dart';
import '../station_owner/widgets/owner_widgets.dart';
import 'dealer_conversations_screen.dart';
import 'dealer_document_upload_screen.dart';
import 'dealer_local_store.dart';
import 'dealer_widgets.dart';

const _dealerTabs = [
  UnifiedNavItem('الرئيسية', Icons.home_outlined),
  UnifiedNavItem('السيارات', Icons.directions_car_outlined),
  UnifiedNavItem('الحجوزات', Icons.bolt_outlined),
  UnifiedNavItem('المحادثات', Icons.chat_bubble_outline_rounded),
  UnifiedNavItem('حسابي', Icons.person_outline_rounded),
];

class DealerApp extends StatefulWidget {
  const DealerApp({super.key});

  @override
  State<DealerApp> createState() => _DealerAppState();
}

class _DealerAppState extends State<DealerApp> {
  final _store = DealerLocalStore.instance;
  int _tab = 0;
  late final Future<void> _ready = _loadStores();

  Future<void> _loadStores() async {
    await _store.initialize();
    await CustomerLocalStore.instance.initialize();
  }

  static const _titles = [
    'لوحة التحكم',
    'سياراتي / المعرض',
    'الطلبات والحجوزات',
    'الرسائل',
    'بيانات الوكيل / المعرض',
  ];

  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
        future: _ready,
        builder: (context, snapshot) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(_titles[_tab]),
            actions: [
              if (_tab < 4)
                IconButton(
                  tooltip: 'الإشعارات',
                  onPressed: _openNotifications,
                  icon: const Icon(Icons.notifications_none_rounded),
                ),
            ],
          ),
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.brand))
              : AnimatedBuilder(
                  animation: _store,
                  builder: (context, _) => IndexedStack(
                    index: _tab,
                    children: [
                      DealerDashboardScreen(
                        store: _store,
                        onOpenTab: (tab) => setState(() => _tab = tab),
                        onAddVehicle: (vehicle) => _addVehicle(vehicle),
                      ),
                      DealerCarsScreen(
                          store: _store,
                          onAddVehicle: (vehicle) => _addVehicle(vehicle)),
                      DealerOrdersScreen(store: _store),
                      DealerMessagesTab(
                          onOpen: (conversation) => _openChat(conversation)),
                      DealerProfileScreen(
                        store: _store,
                        onSettings: _openSettings,
                        onNotifications: _openNotifications,
                        onLogout: _logout,
                      ),
                    ],
                  ),
                ),
          bottomNavigationBar: UnifiedBottomNavBar(
              index: _tab,
              items: _dealerTabs,
              onTap: (index) => setState(() => _tab = index)),
        ),
      );

  Future<void> _addVehicle([DealerVehicle? vehicle]) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DealerVehicleFormScreen(vehicle: vehicle),
      ),
    );
  }

  Future<void> _openChat(CustomerConversation conversation) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DealerChatRoomScreen(conversation: conversation),
      ),
    );
  }

  void _openNotifications() => Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (_) => const DealerNotificationsScreen()),
      );

  void _openSettings() => Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (_) => DealerSettingsScreen(store: _store)),
      );

  Future<void> _logout() async {
    final confirmed = await showLogoutConfirmationDialog(context);
    if (!confirmed || !mounted) return;
    await ActiveRoleSessionStore.instance.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(
          builder: (_) => const AccountTypeSelectionScreen()),
      (_) => false,
    );
  }
}

class DealerDashboardScreen extends StatelessWidget {
  const DealerDashboardScreen({
    super.key,
    required this.store,
    required this.onOpenTab,
    required this.onAddVehicle,
  });
  final DealerLocalStore store;
  final ValueChanged<int> onOpenTab;
  final ValueChanged<DealerVehicle?> onAddVehicle;

  @override
  Widget build(BuildContext context) {
    final recentOrder = store.orders.isEmpty ? null : store.orders.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Text('صباح الخير، ${store.profile['name'] ?? 'معرض السيارات'}',
            textAlign: TextAlign.right, style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text(
            'السيارات المنشورة ${store.vehicles.where((v) => !v.draft).length} • الطلبات الجديدة ${store.orders.where((o) => o.status == 'جديد').length}',
            textAlign: TextAlign.right,
            style: AppTextStyles.body),
        const SizedBox(height: 16),
        AppButton(
          label: '＋ إضافة سيارة جديدة',
          onPressed: () => onAddVehicle(null),
        ),
        const SizedBox(height: 18),
        DealerSectionTitle('طلبات حديثة',
            action: 'عرض الكل', onAction: () => onOpenTab(2)),
        if (recentOrder == null)
          const DealerEmptyCard(
              title: 'لا توجد طلبات حديثة',
              description: 'ستظهر طلبات العملاء هنا عند وصولها.')
        else
          DealerOrderCard(
              order: recentOrder,
              onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) =>
                            DealerOrderDetailsScreen(orderId: recentOrder.id)),
                  )),
        const SizedBox(height: 6),
        DealerSectionTitle('أحدث السيارات',
            action: 'عرض الكل', onAction: () => onOpenTab(1)),
        for (final vehicle in store.vehicles.take(2))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DealerVehicleCard(
              vehicle: vehicle,
              compact: true,
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                    builder: (_) => DealerVehicleDetailsScreen(
                          vehicleId: vehicle.id,
                          onEdit: () => onAddVehicle(vehicle),
                        )),
              ),
            ),
          ),
      ],
    );
  }
}

class DealerCarsScreen extends StatefulWidget {
  const DealerCarsScreen(
      {super.key, required this.store, required this.onAddVehicle});
  final DealerLocalStore store;
  final ValueChanged<DealerVehicle?> onAddVehicle;

  @override
  State<DealerCarsScreen> createState() => _DealerCarsScreenState();
}

class _DealerCarsScreenState extends State<DealerCarsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final vehicles = widget.store.vehicles
        .where((vehicle) => '${vehicle.make} ${vehicle.model} ${vehicle.year}'
            .toLowerCase()
            .contains(_query.toLowerCase()))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        dealerSearchField(
            hint: 'ابحث عن سيارة',
            onChanged: (value) => setState(() => _query = value.trim())),
        const SizedBox(height: 12),
        Text(
            '${widget.store.vehicles.length} سيارة منشورة • ${widget.store.vehicles.where((v) => v.draft).length} مسودة',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption),
        const SizedBox(height: 12),
        if (vehicles.isEmpty)
          DealerEmptyCard(
            title:
                _query.isEmpty ? 'لا توجد سيارات في المعرض' : 'لا توجد نتائج',
            description: _query.isEmpty
                ? 'أضف سيارتك الأولى ليكتشف العملاء خياراتك.'
                : 'جرّب البحث باسم أو طراز آخر.',
          ),
        for (final vehicle in vehicles)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                DealerVehiclePhoto(path: vehicle.primaryImagePath, height: 216),
                const SizedBox(height: 10),
                DealerVehicleCard(
                    vehicle: vehicle,
                    onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) => DealerVehicleDetailsScreen(
                                    vehicleId: vehicle.id,
                                    onEdit: () => widget.onAddVehicle(vehicle),
                                  )),
                        )),
              ],
            ),
          ),
        const SizedBox(height: 2),
        AppButton(
            label: '＋ إضافة سيارة جديدة',
            onPressed: () => widget.onAddVehicle(null)),
      ],
    );
  }
}

class DealerVehicleDetailsScreen extends StatelessWidget {
  const DealerVehicleDetailsScreen({
    super.key,
    required this.vehicleId,
    required this.onEdit,
  });
  final String vehicleId;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: DealerLocalStore.instance,
        builder: (context, _) {
          final store = DealerLocalStore.instance;
          final vehicle =
              store.vehicles.firstWhere((item) => item.id == vehicleId);
          return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: const Text('تفاصيل السيارة'),
                actions: [
                  OwnerBackAction(onPressed: () => Navigator.pop(context))
                ]),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                DealerVehiclePhoto(path: vehicle.primaryImagePath),
                const SizedBox(height: 14),
                Text(vehicle.displayName,
                    textAlign: TextAlign.left, style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                      'البطارية ${vehicle.batteryKwh} kWh • المدى ${vehicle.rangeKm} km',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body),
                ),
                const SizedBox(height: 8),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                      'منفذ ${vehicle.connector} • ${vehicle.available ? 'متوفرة للحجز' : 'متوقفة'} • ${formatYemeniRial(vehicle.priceYer)} ر.ي',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body),
                ),
                const SizedBox(height: 8),
                Text('${vehicle.inquiries} استفسارات من العملاء',
                    textAlign: TextAlign.right, style: AppTextStyles.caption),
                const SizedBox(height: 18),
                AppButton(label: 'تعديل بيانات السيارة', onPressed: onEdit),
                const SizedBox(height: 10),
                AppButton(
                  label: vehicle.available ? 'إيقاف التوفر' : 'إتاحة السيارة',
                  outlined: true,
                  onPressed: () => store.setVehicleAvailability(
                      vehicle.id, !vehicle.available),
                ),
              ],
            ),
          );
        },
      );
}

class DealerVehicleFormScreen extends StatefulWidget {
  const DealerVehicleFormScreen({super.key, this.vehicle});
  final DealerVehicle? vehicle;

  @override
  State<DealerVehicleFormScreen> createState() =>
      _DealerVehicleFormScreenState();
}

class _DealerVehicleFormScreenState extends State<DealerVehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _make = TextEditingController(text: widget.vehicle?.make ?? '');
  late final _model = TextEditingController(text: widget.vehicle?.model ?? '');
  late final _year = TextEditingController(text: widget.vehicle?.year ?? '');
  late final _battery =
      TextEditingController(text: widget.vehicle?.batteryKwh ?? '');
  late final _range =
      TextEditingController(text: widget.vehicle?.rangeKm ?? '');
  late final _price = TextEditingController(
      text: widget.vehicle == null ? '' : '${widget.vehicle!.priceYer}');
  String _connector = 'CCS2';
  List<String> _photos = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _connector = widget.vehicle?.connector ?? 'CCS2';
    _photos = [...?widget.vehicle?.photoPaths];
  }

  @override
  void dispose() {
    _make.dispose();
    _model.dispose();
    _year.dispose();
    _battery.dispose();
    _range.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickPhotos() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true);
    if (!mounted || result == null) return;
    setState(() => _photos = result.files
        .where((file) => file.path != null)
        .take(3)
        .map((file) => file.path!)
        .toList());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final price = int.tryParse(_price.text.replaceAll(',', ''));
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أدخل سعراً صحيحاً للسيارة.')));
      return;
    }
    setState(() => _busy = true);
    final old = widget.vehicle;
    final imageAsset = old?.imageAsset ?? '';
    await DealerLocalStore.instance.saveVehicle(DealerVehicle(
      id: old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      make: _make.text.trim(),
      model: _model.text.trim(),
      year: _year.text.trim(),
      batteryKwh: _battery.text.trim(),
      rangeKm: _range.text.trim(),
      connector: _connector,
      priceYer: price,
      imageAsset: imageAsset,
      photoPaths: _photos,
      available: old?.available ?? true,
      draft: false,
      inquiries: old?.inquiries ?? 0,
    ));
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _input(String label, TextEditingController controller,
          {bool numeric = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label,
                  textAlign: TextAlign.right, style: AppTextStyles.label),
              const SizedBox(height: 8),
              Directionality(
                textDirection: numeric ? TextDirection.ltr : TextDirection.rtl,
                child: TextFormField(
                  controller: controller,
                  keyboardType: numeric ? TextInputType.number : null,
                  textAlign: numeric ? TextAlign.left : TextAlign.right,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'هذا الحقل مطلوب'
                      : null,
                  decoration: const InputDecoration(),
                ),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: Text(widget.vehicle == null
                ? 'إضافة سيارة جديدة'
                : 'تعديل بيانات السيارة'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              const DealerSectionTitle('المعلومات الأساسية'),
              _input('الشركة والطراز', _make),
              _input('اسم الطراز', _model),
              _input('سنة الصنع', _year, numeric: true),
              const DealerSectionTitle('المواصفات الفنية والشحن'),
              _input('البطارية (kWh)', _battery, numeric: true),
              _input('المدى (km)', _range, numeric: true),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('نوع منفذ الشحن',
                        textAlign: TextAlign.right, style: AppTextStyles.label),
                    DropdownButtonFormField<String>(
                      value: _connector,
                      items: const [
                        DropdownMenuItem(value: 'CCS2', child: Text('CCS2')),
                        DropdownMenuItem(value: 'GB/T', child: Text('GB/T')),
                        DropdownMenuItem(
                            value: 'CHAdeMO', child: Text('CHAdeMO')),
                      ],
                      onChanged: (value) =>
                          setState(() => _connector = value ?? _connector),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const DealerSectionTitle('السعر والصور'),
              _input('السعر (ر.ي)', _price, numeric: true),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('صور السيارة',
                        textAlign: TextAlign.right, style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickPhotos,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(_photos.isEmpty
                          ? '＋ اختر صور السيارة'
                          : 'تغيير الصور (${_photos.length}/3)'),
                    ),
                    const Text('يمكن اختيار حتى 3 صور للسيارة.',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                  label: _busy ? 'جارٍ الحفظ…' : 'حفظ بيانات السيارة',
                  onPressed: _busy ? null : _save),
            ],
          ),
        ),
      );
}

class DealerOrdersScreen extends StatefulWidget {
  const DealerOrdersScreen({super.key, required this.store});
  final DealerLocalStore store;

  @override
  State<DealerOrdersScreen> createState() => _DealerOrdersScreenState();
}

class _DealerOrdersScreenState extends State<DealerOrdersScreen> {
  String _query = '';
  String _filter = 'الكل';
  static const _filters = ['الكل', 'جديدة', 'قيد التنفيذ', 'مكتملة', 'ملغاة'];

  @override
  Widget build(BuildContext context) {
    final status = _filter == 'جديدة'
        ? 'جديد'
        : _filter == 'مكتملة'
            ? 'مكتمل'
            : _filter == 'ملغاة'
                ? 'ملغي'
                : _filter;
    final orders = widget.store.orders
        .where((order) =>
            (_filter == 'الكل' || order.status == status) &&
            '${order.customer} ${order.vehicleName} ${order.id}'
                .toLowerCase()
                .contains(_query.toLowerCase()))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        dealerSearchField(
            hint: 'ابحث باسم العميل أو السيارة',
            onChanged: (value) => setState(() => _query = value.trim())),
        const SizedBox(height: 14),
        const Text('طلبات العملاء',
            textAlign: TextAlign.right, style: AppTextStyles.label),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: AppButton(
              label: 'الكل (${widget.store.orders.length})',
              onPressed: () => setState(() => _filter = 'الكل')),
        ),
        const SizedBox(height: 8),
        for (final row in [
          _filters.sublist(1, 3),
          _filters.sublist(3, 5),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _filter = row[i]),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.brand,
                        side: const BorderSide(color: AppColors.border),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(row[i]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        const SizedBox(height: 8),
        if (orders.isEmpty)
          DealerEmptyCard(
              title: 'لا توجد طلبات ${_filter == 'الكل' ? '' : _filter}',
              description: 'ستظهر طلبات العملاء هنا عند وصولها.'),
        for (final order in orders)
          DealerOrderCard(
              order: order,
              onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) =>
                            DealerOrderDetailsScreen(orderId: order.id)),
                  )),
      ],
    );
  }
}

class DealerOrderDetailsScreen extends StatelessWidget {
  const DealerOrderDetailsScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: DealerLocalStore.instance,
        builder: (context, _) {
          final store = DealerLocalStore.instance;
          final order = store.orders.firstWhere((item) => item.id == orderId);
          final vehicle = store.vehicles.cast<DealerVehicle?>().firstWhere(
                (item) =>
                    item?.displayName.contains(
                        order.vehicleName.split(' ').take(2).join(' ')) ??
                    false,
                orElse: () =>
                    store.vehicles.isEmpty ? null : store.vehicles.first,
              );
          return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: true,
                title: const Text('تفاصيل الطلب'),
                actions: [
                  OwnerBackAction(onPressed: () => Navigator.pop(context))
                ]),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: [
                Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AppStatusBadge(order.status)),
                const SizedBox(height: 12),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                      '${order.customer} • ${order.city} • ${order.phone}',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body),
                ),
                const SizedBox(height: 12),
                if (vehicle != null)
                  DealerVehiclePhoto(path: vehicle.primaryImagePath),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(order.vehicleName,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 8),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text('${formatYemeniRial(order.priceYer)} ر.ي',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.h3),
                      ),
                      const SizedBox(height: 6),
                      Text(order.connector,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text('الدفع ${order.payment}',
                    textAlign: TextAlign.right, style: AppTextStyles.body),
                const SizedBox(height: 14),
                if (order.status == 'جديد') ...[
                  AppButton(
                      label: 'قبول الطلب',
                      onPressed: () =>
                          store.updateOrder(order.id, status: 'قيد التنفيذ')),
                  const SizedBox(height: 8),
                  AppButton(
                      label: 'إرسال عرض سعر',
                      outlined: true,
                      onPressed: () => _sendPriceOffer(context, store, order)),
                  const SizedBox(height: 8),
                  AppButton(
                    label: 'رفض الطلب',
                    danger: true,
                    onPressed: () =>
                        store.updateOrder(order.id, status: 'ملغي'),
                  ),
                ],
                if (order.status == 'قيد التنفيذ')
                  AppButton(
                      label: 'تحديد كمكتمل',
                      onPressed: () =>
                          store.updateOrder(order.id, status: 'مكتمل')),
              ],
            ),
          );
        },
      );

  Future<void> _sendPriceOffer(
      BuildContext context, DealerLocalStore store, DealerOrder order) async {
    final controller = TextEditingController(text: '${order.priceYer}');
    final result = await showDialog<int>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('إرسال عرض سعر'),
              content: Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'السعر (ر.ي)'),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('إلغاء')),
                FilledButton(
                    onPressed: () => Navigator.pop(
                        dialogContext, int.tryParse(controller.text)),
                    child: const Text('إرسال')),
              ],
            ));
    controller.dispose();
    if (result != null && result > 0) {
      await store.updateOrder(order.id,
          status: 'قيد التنفيذ', priceYer: result);
    }
  }
}

class DealerMessagesTab extends StatelessWidget {
  const DealerMessagesTab({super.key, required this.onOpen});
  final ValueChanged<CustomerConversation> onOpen;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: CustomerLocalStore.instance,
        builder: (context, _) {
          final conversations = CustomerLocalStore.instance.conversations;
          if (conversations.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              children: const [
                DealerEmptyCard(
                    title: 'لا توجد محادثات بعد',
                    description:
                        'ستظهر رسائل العملاء هنا بعد تواصلهم مع معرضك.'),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              for (final conversation in conversations)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                          backgroundColor: AppColors.mint,
                          child: Icon(Icons.person_outline,
                              color: AppColors.brand)),
                      title: Text(
                          conversation.customerName.isEmpty
                              ? 'عميل'
                              : conversation.customerName,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium),
                      subtitle: Text(
                          '${conversation.carName.isEmpty ? '' : '${conversation.carName} • '}${conversation.lastMessage}',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption),
                      trailing: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(conversation.updatedAt,
                              style: AppTextStyles.caption)),
                      onTap: () => onOpen(conversation),
                    ),
                  ),
                ),
            ],
          );
        },
      );
}

class DealerProfileScreen extends StatelessWidget {
  const DealerProfileScreen({
    super.key,
    required this.store,
    required this.onSettings,
    required this.onNotifications,
    required this.onLogout,
  });
  final DealerLocalStore store;
  final VoidCallback onSettings, onNotifications, onLogout;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        children: [
          DealerVehiclePhoto(
              path: store.profile['storeImagePath'] ??
                  'assets/dealer_profile/figma_catalog_1.jpeg'),
          const SizedBox(height: 12),
          Align(
              alignment: AlignmentDirectional.centerStart,
              child: const AppStatusBadge('وكيل معتمد')),
          const SizedBox(height: 14),
          _profileCard(
              'رقم السجل التجاري', store.profile['registration'] ?? '—'),
          _profileCard('اسم المعرض', store.profile['name'] ?? '—'),
          _profileCard('رقم التواصل', store.profile['phone'] ?? '—', ltr: true),
          _profileCard('البريد الإلكتروني', store.profile['email'] ?? '—',
              ltr: true),
          _profileCard('العنوان', store.profile['address'] ?? '—'),
          DealerSectionTitle(
            'وثائق التحقق',
            action: 'إدارة الوثائق',
            onAction: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const DealerDocumentUploadScreen.profile(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in const {
                  'identity': 'الهوية الشخصية',
                  'commercial_register': 'السجل التجاري',
                  'agency_license': 'ترخيص أو تفويض الوكالة',
                  'premises_proof': 'إثبات ملكية أو إيجار المعرض',
                }.entries) ...[
                  Row(
                    children: [
                      AppStatusBadge(
                        store.documents.containsKey(entry.key)
                            ? 'مرفق'
                            : 'ناقص',
                        tone: store.documents.containsKey(entry.key)
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(entry.value,
                            textAlign: TextAlign.right,
                            style: AppTextStyles.label),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      store.documents[entry.key]?.name ?? 'لم يتم إرفاقه',
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption,
                    ),
                  ),
                  if (entry.key != 'premises_proof') const Divider(height: 20),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
              label: 'تعديل بيانات المعرض',
              outlined: true,
              onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => DealerEditProfileScreen(store: store)),
                  )),
          const SizedBox(height: 8),
          const DealerSectionTitle('الإعدادات'),
          const SizedBox(height: 12),
          _profileLink('الإعدادات', Icons.settings_outlined, onSettings),
          _profileLink('الإشعارات', Icons.notifications_none, onNotifications),
          _profileLink(
            'السياسة والخصوصية',
            Icons.privacy_tip_outlined,
            () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    const DealerInfoScreen(title: 'السياسة والخصوصية'),
              ),
            ),
          ),
          _profileLink(
            'المساعدة والدعم',
            Icons.support_agent_outlined,
            () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const DealerSupportScreen(),
              ),
            ),
          ),
          _profileLink(
            'إدارة الفروع',
            Icons.store_mall_directory_outlined,
            () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const BusinessBranchesScreen(
                  businessKey: 'car_dealer',
                  title: 'وكيل السيارات',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'تسجيل الخروج',
            outlined: true,
            danger: true,
            icon: Icons.logout_rounded,
            onPressed: onLogout,
          ),
        ],
      );

  Widget _profileCard(String label, String value, {bool ltr = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label,
                  textAlign: TextAlign.right, style: AppTextStyles.label),
              const SizedBox(height: 8),
              Directionality(
                textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
                child: Text(value,
                    textAlign: ltr ? TextAlign.left : TextAlign.right,
                    style: AppTextStyles.body),
              ),
              const SizedBox(height: 4),
              Text(value,
                  textAlign: TextAlign.right, style: AppTextStyles.caption),
            ],
          ),
        ),
      );

  Widget _profileLink(String title, IconData icon, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(title, textAlign: TextAlign.right),
            leading: Icon(icon, color: AppColors.brand),
            trailing: const Icon(Icons.chevron_left_rounded),
          ),
        ),
      );
}

class DealerEditProfileScreen extends StatefulWidget {
  const DealerEditProfileScreen({super.key, required this.store});
  final DealerLocalStore store;

  @override
  State<DealerEditProfileScreen> createState() =>
      _DealerEditProfileScreenState();
}

class _DealerEditProfileScreenState extends State<DealerEditProfileScreen> {
  late final _name = TextEditingController(text: widget.store.profile['name']);
  late final _registration =
      TextEditingController(text: widget.store.profile['registration']);
  late final _phone =
      TextEditingController(text: widget.store.profile['phone']);
  late final _email =
      TextEditingController(text: widget.store.profile['email']);
  late final _address =
      TextEditingController(text: widget.store.profile['address']);

  @override
  void dispose() {
    _name.dispose();
    _registration.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('تعديل بيانات المعرض')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            _edit('اسم المعرض', _name),
            _edit('رقم السجل التجاري', _registration),
            _edit('رقم التواصل', _phone,
                ltr: true, keyboard: TextInputType.phone),
            _edit('البريد الإلكتروني', _email,
                ltr: true, keyboard: TextInputType.emailAddress),
            _edit('العنوان', _address),
            const SizedBox(height: 12),
            AppButton(
              label: 'حفظ التعديلات',
              onPressed: () async {
                await widget.store.saveProfile({
                  'name': _name.text.trim(),
                  'registration': _registration.text.trim(),
                  'phone': _phone.text.trim(),
                  'email': _email.text.trim(),
                  'address': _address.text.trim(),
                });
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      );

  Widget _edit(String label, TextEditingController controller,
          {bool ltr = false, TextInputType? keyboard}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label,
                  textAlign: TextAlign.right, style: AppTextStyles.label),
              const SizedBox(height: 8),
              Directionality(
                  textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboard,
                    textAlign: ltr ? TextAlign.left : TextAlign.right,
                  )),
            ],
          ),
        ),
      );
}

class DealerSettingsScreen extends StatelessWidget {
  const DealerSettingsScreen({super.key, required this.store});
  final DealerLocalStore store;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الإعدادات')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            const AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('لغة التطبيق',
                      textAlign: TextAlign.right, style: AppTextStyles.label),
                  SizedBox(height: 8),
                  Text('العربية',
                      textAlign: TextAlign.right, style: AppTextStyles.body),
                  SizedBox(height: 4),
                  Text('واجهة عربية • اتجاه من اليمين إلى اليسار',
                      textAlign: TextAlign.right, style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title:
                    const Text('إعدادات الإشعارات', textAlign: TextAlign.right),
                subtitle: const Text(
                    'طلبات ورسائل العملاء • تخصيص التنبيهات ووسائل الاستلام',
                    textAlign: TextAlign.right),
                trailing: const Icon(Icons.chevron_left_rounded),
                onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) =>
                            DealerNotificationSettingsScreen(store: store))),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
                onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => const DealerInfoScreen(
                            title: 'السياسة والخصوصية'))),
                child: const Text('السياسة والخصوصية')),
            const SizedBox(height: 8),
            OutlinedButton(
                onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => const DealerSupportScreen())),
                child: const Text('المساعدة والدعم')),
          ],
        ),
      );
}

class DealerNotificationSettingsScreen extends StatefulWidget {
  const DealerNotificationSettingsScreen({super.key, required this.store});
  final DealerLocalStore store;

  @override
  State<DealerNotificationSettingsScreen> createState() =>
      _DealerNotificationSettingsScreenState();
}

class _DealerNotificationSettingsScreenState
    extends State<DealerNotificationSettingsScreen> {
  late final Map<String, bool> _settings =
      Map.of(widget.store.notificationSettings);

  Future<void> _toggle(String key, bool value) async {
    setState(() => _settings[key] = value);
    await widget.store.saveNotificationSettings(_settings);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('إعدادات الإشعارات')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _section('أنواع الإشعارات', [
              _switch('طلبات جديدة', 'orders'),
              _switch('رسائل العملاء', 'messages'),
              _switch('حالة الحساب', 'account'),
              _switch('عروض وتحديثات المعرض', 'offers'),
            ]),
            const SizedBox(height: 16),
            _section('قنوات الاستلام', [
              _switch('إشعارات التطبيق', 'push'),
              _switch('البريد الإلكتروني', 'email'),
            ]),
          ],
        ),
      );

  Widget _section(String title, List<Widget> children) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, textAlign: TextAlign.right, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      );

  Widget _switch(String title, String key) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, textAlign: TextAlign.right),
        value: _settings[key] ?? false,
        activeTrackColor: AppColors.brand,
        onChanged: (value) => _toggle(key, value),
      );
}

class DealerNotificationsScreen extends StatelessWidget {
  const DealerNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('الإشعارات')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: const [
            Text('اليوم',
                textAlign: TextAlign.right, style: AppTextStyles.label),
            SizedBox(height: 8),
            _DealerNotificationCard(
                title: 'طلب تجربة قيادة',
                detail: 'سارة محمد • BYD Song Plus EV 2024',
                time: 'منذ ٥ دقائق • جديد'),
            SizedBox(height: 10),
            _DealerNotificationCard(
                title: 'تم اعتماد حساب معرضك',
                detail: 'تم تفعيل إدارة المعرض',
                time: 'أمس • تم الاطلاع'),
            SizedBox(height: 10),
            _DealerNotificationCard(
                title: 'رسالة جديدة',
                detail: 'أحمد صالح: أرسلوا تفاصيل التمويل',
                time: 'أمس • غير مقروءة'),
          ],
        ),
      );
}

class _DealerNotificationCard extends StatelessWidget {
  const _DealerNotificationCard(
      {required this.title, required this.detail, required this.time});
  final String title, detail, time;
  @override
  Widget build(BuildContext context) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                textAlign: TextAlign.right, style: AppTextStyles.bodyMedium),
            Text(detail, textAlign: TextAlign.right, style: AppTextStyles.body),
            Text(time,
                textAlign: TextAlign.right, style: AppTextStyles.caption),
          ],
        ),
      );
}

class DealerInfoScreen extends StatelessWidget {
  const DealerInfoScreen({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
                title == 'السياسة والخصوصية'
                    ? 'نحافظ على بيانات المعرض ونستخدمها لإدارة السيارات والطلبات والتواصل مع العملاء.'
                    : 'فريق دعم الوكلاء جاهز لمساعدتك في إدارة معرضك وطلبات العملاء.',
                textAlign: TextAlign.right,
                style: AppTextStyles.body),
          ],
        ),
      );
}

class DealerSupportScreen extends StatefulWidget {
  const DealerSupportScreen({super.key});
  @override
  State<DealerSupportScreen> createState() => _DealerSupportScreenState();
}

class _DealerSupportScreenState extends State<DealerSupportScreen> {
  final _message = TextEditingController();
  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('المساعدة والدعم')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text('فريق دعم الوكلاء جاهز لمساعدتك',
                textAlign: TextAlign.right, style: AppTextStyles.body),
            const SizedBox(height: 8),
            const Directionality(
                textDirection: TextDirection.ltr,
                child: Text('+967 1 234 567', textAlign: TextAlign.right)),
            const SizedBox(height: 16),
            TextField(
                controller: _message,
                maxLines: 4,
                decoration:
                    const InputDecoration(hintText: 'اكتب رسالتك للدعم')),
            const SizedBox(height: 14),
            AppButton(
                label: 'إرسال الرسالة',
                onPressed: () {
                  if (_message.text.trim().isEmpty) return;
                  _message.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال رسالتك للدعم.')));
                }),
          ],
        ),
      );
}
