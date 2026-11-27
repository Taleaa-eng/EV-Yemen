import 'package:flutter/material.dart';

import '../../core/services/active_role_session.dart';
import '../../core/widgets/logout_confirmation_dialog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../account_selection/account_type_selection_screen.dart';
import '../station_owner/widgets/owner_widgets.dart';
import 'services/customer_local_store.dart';

const _customerItems = [
  UnifiedNavItem('الرئيسية', Icons.home_outlined),
  UnifiedNavItem('السيارات', Icons.directions_car_outlined),
  UnifiedNavItem('المحادثات', Icons.chat_bubble_outline_rounded),
  UnifiedNavItem('حسابي', Icons.person_outline_rounded),
];
const _guestItems = [
  UnifiedNavItem('الخريطة', Icons.map_outlined),
  UnifiedNavItem('معرض السيارات', Icons.directions_car_outlined),
];

const double _alRaabiLatitude = 15.3072;
const double _alRaabiLongitude = 44.1812;

class CustomerWelcomeScreen extends StatelessWidget {
  const CustomerWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('مرحباً بك في EV Yemen'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: ListView(padding: const EdgeInsets.all(24), children: [
          const SizedBox(height: 24),
          const Icon(Icons.electric_car_rounded,
              size: 92, color: AppColors.brand),
          const SizedBox(height: 18),
          const Text('تنقّل بثقة في اليمن',
              textAlign: TextAlign.right, style: AppTextStyles.h2),
          const SizedBox(height: 8),
          const Text(
              'اكتشف محطات الشحن ووكلاء السيارات ومزودي الخدمات في مكان واحد.',
              textAlign: TextAlign.right,
              style: AppTextStyles.body),
          const SizedBox(height: 18),
          const SizedBox(height: 22),
          AppButton(
              label: 'إنشاء حساب',
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const CustomerSignupScreen()))),
          const SizedBox(height: 8),
          AppButton(
              label: 'تسجيل الدخول',
              outlined: true,
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const CustomerLoginScreen()))),
          TextButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const CustomerAppScreen(isGuest: true)),
                  (_) => false),
              child: const Text('تصفح كزائر')),
        ]),
      );
}

void _noop() {}

class CustomerLoginScreen extends StatefulWidget {
  const CustomerLoginScreen({super.key});
  @override
  State<CustomerLoginScreen> createState() => _CustomerLoginScreenState();
}

class _CustomerLoginScreenState extends State<CustomerLoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }
    await CustomerLocalStore.instance.activateLogin(_email.text);
    await ActiveRoleSessionStore.instance
        .save(ActiveUserRole.customer, authenticated: true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const CustomerAppScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('تسجيل الدخول'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 36),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('مرحباً بعودتك',
                      textAlign: TextAlign.right, style: AppTextStyles.h1),
                  const Text('أدخل بياناتك للعودة إلى حسابك.',
                      textAlign: TextAlign.right, style: AppTextStyles.body),
                  const SizedBox(height: 22),
                  CustomLabeledTextField(
                      label: 'البريد الإلكتروني',
                      hint: 'example@email.com',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left),
                  const SizedBox(height: 14),
                  OwnerPasswordField(
                      label: 'كلمة المرور',
                      hint: 'أدخل كلمة المرور',
                      controller: _password),
                  if (_error != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_error!,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: AppColors.error))),
                  TextButton(
                      onPressed: () => _message(context,
                          'يرجى التواصل مع الدعم لاستعادة كلمة المرور.'),
                      child: const Text('هل نسيت كلمة المرور؟')),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) => const CustomerSignupScreen())),
                      child: const Text('ليس لديك حساب؟ إنشاء حساب جديد')),
                  TextButton(
                      onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(
                                builder: (_) =>
                                    const CustomerAppScreen(isGuest: true)),
                            (_) => false,
                          ),
                      child: const Text('استكشاف كزائر')),
                ])),
        bottomNavigationBar: OwnerStickyAction(
            keyboardAware: true,
            child: AppButton(label: 'دخول', onPressed: _login)),
      );
}

class CustomerSignupScreen extends StatefulWidget {
  const CustomerSignupScreen({super.key});
  @override
  State<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _password.text.isEmpty ||
        _confirm.text.isEmpty) {
      setState(() => _error = 'يرجى إكمال الحقول المطلوبة');
      return;
    }
    if (!_email.text.contains('@') ||
        _password.text.length < 6 ||
        _password.text != _confirm.text) {
      setState(
          () => _error = 'تحقق من البريد الإلكتروني وكلمة المرور وتأكيدها');
      return;
    }
    final profile = CustomerProfile(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim());
    Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CustomerOtpVerificationScreen(profile: profile),
        ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('إنشاء حساب'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 38),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('أنشئ حسابك للبدء باستخدام خدمات EV Yemen.',
                      textAlign: TextAlign.right, style: AppTextStyles.body),
                  const SizedBox(height: 16),
                  CustomLabeledTextField(
                      label: 'الاسم الكامل',
                      hint: 'أدخل اسمك الكامل',
                      controller: _name),
                  const SizedBox(height: 12),
                  CustomLabeledTextField(
                      label: 'البريد الإلكتروني',
                      hint: 'example@email.com',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.left),
                  const SizedBox(height: 12),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: CustomLabeledTextField(
                          label: 'رقم الهاتف',
                          hint: '+967 ...',
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left)),
                  const SizedBox(height: 12),
                  OwnerPasswordField(
                      label: 'كلمة المرور',
                      hint: 'أدخل كلمة المرور',
                      controller: _password),
                  const SizedBox(height: 12),
                  OwnerPasswordField(
                      label: 'تأكيد كلمة المرور',
                      hint: 'أعد إدخال كلمة المرور',
                      controller: _confirm),
                  if (_error != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(_error!,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: AppColors.error))),
                  const SizedBox(height: 8),
                  TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) => const CustomerLoginScreen())),
                      child: const Text('لديك حساب بالفعل؟ تسجيل الدخول')),
                ])),
        bottomNavigationBar: OwnerStickyAction(
            keyboardAware: true,
            child: AppButton(label: 'إنشاء الحساب', onPressed: _create)),
      );
}

class CustomerOtpVerificationScreen extends StatefulWidget {
  const CustomerOtpVerificationScreen({super.key, required this.profile});
  final CustomerProfile profile;
  @override
  State<CustomerOtpVerificationScreen> createState() =>
      _CustomerOtpVerificationScreenState();
}

class _CustomerOtpVerificationScreenState
    extends State<CustomerOtpVerificationScreen> {
  final _digits = List.generate(5, (_) => TextEditingController());
  final _focus = List.generate(5, (_) => FocusNode());
  String? _error;
  @override
  void dispose() {
    for (final item in _digits) {
      item.dispose();
    }
    for (final item in _focus) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _digits.map((e) => e.text).join();
    if (code.length != 5) {
      setState(() => _error = 'أدخل رمز التحقق المكوّن من 5 أرقام');
      return;
    }
    if (code != '12345') {
      setState(() => _error = 'رمز التحقق غير صحيح.');
      return;
    }
    await CustomerLocalStore.instance.saveProfile(widget.profile);
    await ActiveRoleSessionStore.instance
        .save(ActiveUserRole.customer, authenticated: true);
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
              builder: (_) => const CustomerSignupSuccessScreen()));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('تأكيد الرمز'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 18),
                  const CircleAvatar(
                      radius: 72,
                      backgroundColor: AppColors.brand,
                      child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.verified_user_outlined,
                              size: 48, color: AppColors.brand))),
                  const SizedBox(height: 24),
                  const Text('تأكيد الرمز',
                      textAlign: TextAlign.center, style: AppTextStyles.h2),
                  const Text('أدخل رمز التحقق المرسل إلى رقمك',
                      textAlign: TextAlign.center, style: AppTextStyles.body),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(widget.profile.phone,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium)),
                  const SizedBox(height: 24),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                              5,
                              (i) => SizedBox(
                                  width: 54,
                                  height: 62,
                                  child: TextField(
                                      controller: _digits[i],
                                      focusNode: _focus[i],
                                      maxLength: 1,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      textDirection: TextDirection.ltr,
                                      style: AppTextStyles.h2,
                                      decoration: const InputDecoration(
                                          counterText: '',
                                          contentPadding: EdgeInsets.zero),
                                      onChanged: (value) {
                                        if (value.isNotEmpty && i < 4) {
                                          _focus[i + 1].requestFocus();
                                        }
                                        if (value.isEmpty && i > 0) {
                                          _focus[i - 1].requestFocus();
                                        }
                                      }))))),
                  const SizedBox(height: 18),
                  const Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('00:59',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium)),
                  const Text('رمز التحقق التجريبي: 12345',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption),
                  TextButton(
                      onPressed: () =>
                          _message(context, 'تم إرسال رمز تحقق جديد.'),
                      child: const Text('إعادة إرسال الرمز')),
                  if (_error != null)
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error)),
                ])),
        bottomNavigationBar: OwnerStickyAction(
            keyboardAware: true,
            child: AppButton(label: 'تأكيد الرمز', onPressed: _verify)),
      );
}

class CustomerSignupSuccessScreen extends StatelessWidget {
  const CustomerSignupSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('تم إنشاء الحساب')),
      body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 76, color: AppColors.brand),
                const SizedBox(height: 18),
                const Text('تم إنشاء حسابك بنجاح',
                    textAlign: TextAlign.center, style: AppTextStyles.h2),
                const SizedBox(height: 22),
                AppButton(
                    label: 'متابعة',
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) => const CustomerAppScreen()),
                        (_) => false))
              ])));
}

class CustomerAppScreen extends StatefulWidget {
  const CustomerAppScreen({super.key, this.isGuest = false});
  final bool isGuest;
  @override
  State<CustomerAppScreen> createState() => _CustomerAppScreenState();
}

class _CustomerAppScreenState extends State<CustomerAppScreen> {
  int _tab = 0;
  bool _loading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await CustomerLocalStore.instance.initialize();
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = 'تعذر تحميل بيانات الحساب.';
        });
      }
    }
  }

  Future<void> _retry() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    await _loadData();
  }

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: _tab == 0
            ? null
            : AppBar(
                title: Text(widget.isGuest
                    ? 'معرض السيارات'
                    : [
                        'الرئيسية',
                        'معرض السيارات',
                        'المحادثات',
                        'حسابي'
                      ][_tab]),
                actions: [
                  if (!widget.isGuest && _tab == 1)
                    IconButton(
                        tooltip: 'الإشعارات',
                        onPressed: () =>
                            _open(const CustomerNotificationsScreen()),
                        icon: const Icon(Icons.notifications_none_rounded))
                ],
              ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? _RetryState(message: _loadError!, onRetry: _retry)
                : IndexedStack(
                    index: _tab,
                    children: widget.isGuest
                        ? [
                            CustomerHomeScreen(isGuest: true, onOpen: _open),
                            CustomerShowroomScreen(
                                isGuest: true, onOpen: _open),
                          ]
                        : [
                            CustomerHomeScreen(onOpen: _open),
                            CustomerShowroomScreen(onOpen: _open),
                            CustomerChatsScreen(onOpen: _open),
                            CustomerProfileScreen(
                                onOpen: _open, onLogout: _logout)
                          ]),
        bottomNavigationBar: UnifiedBottomNavBar(
            index: _tab,
            items: widget.isGuest ? _guestItems : _customerItems,
            onTap: (i) => setState(() => _tab = i)),
      );

  Future<void> _logout() async {
    final yes = await showLogoutConfirmationDialog(context);
    if (yes == true && mounted) {
      await ActiveRoleSessionStore.instance.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(
              builder: (_) => const AccountTypeSelectionScreen()),
          (_) => false);
    }
  }
}

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen(
      {super.key, this.isGuest = false, required this.onOpen});
  final bool isGuest;
  final ValueChanged<Widget> onOpen;
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _MapPainter()),
        SafeArea(
            child: Stack(children: [
          if (!isGuest)
            const Positioned(
                top: 8, right: 16, left: 16, child: _VehicleBanner()),
          Positioned(
              right: 18,
              top: isGuest ? 30 : 110,
              child: _MapPin(
                  icon: Icons.ev_station,
                  label: 'محطة الشحن المقترحة',
                  color: AppColors.brand,
                  onTap: () => _handleMapPin(context,
                      isGuest: isGuest,
                      title: 'محطة النور الذكية',
                      subtitle: 'محطة شحن • CCS2 • 120 kW',
                      onOpen: () => onOpen(CustomerPlaceDetailScreen(
                          title: 'محطة النور الذكية', kind: 'محطة شحن'))))),
          Positioned(
              left: 18,
              top: 245,
              child: _MapPin(
                  icon: Icons.directions_car_filled,
                  label: 'وكيل سيارات',
                  color: AppColors.info,
                  onTap: () => _handleMapPin(context,
                      isGuest: isGuest,
                      title: 'الراعبي أوتوكارز',
                      subtitle: 'وكيل سيارات كهربائية',
                      onOpen: () => onOpen(const CustomerDealerDetailScreen(
                          dealerName: 'الراعبي أوتوكارز'))))),
          Positioned(
              left: 14,
              top: 360,
              child: _MapPin(
                  icon: Icons.build,
                  label: 'ورشة',
                  color: AppColors.warning,
                  onTap: () => _handleMapPin(context,
                      isGuest: isGuest,
                      title: 'ورشة المستقبل للسيارات',
                      subtitle: 'مزود خدمة • ورشة صيانة',
                      onOpen: () => onOpen(const CustomerPlaceDetailScreen(
                          title: 'ورشة المستقبل للسيارات',
                          kind: 'ورشة صيانة'))))),
          Positioned(
              right: 30,
              top: 365,
              child: _MapPin(
                  icon: Icons.handyman_outlined,
                  label: 'قطع غيار',
                  color: AppColors.secondary,
                  onTap: () => _handleMapPin(context,
                      isGuest: isGuest,
                      title: 'مركز EV لقطع الغيار',
                      subtitle: 'مزود خدمة • قطع غيار',
                      onOpen: () => onOpen(const CustomerPlaceDetailScreen(
                          title: 'مركز EV لقطع الغيار', kind: 'قطع غيار'))))),
          const Positioned(
              left: 54,
              bottom: 150,
              child: _MapPin(
                  icon: Icons.my_location,
                  label: 'موقعك الحالي',
                  color: AppColors.brand,
                  onTap: _noop)),
          Positioned(
              right: 22,
              bottom: 132,
              child: FloatingActionButton.small(
                  heroTag: 'customer_ai_assistant',
                  onPressed: () => onOpen(const CustomerAssistantScreen()),
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.brand,
                  child: const Icon(Icons.auto_awesome))),
          Positioned(
            right: 24,
            bottom: 12,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: IntrinsicWidth(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => isGuest
                      ? _requireSignup(context)
                      : onOpen(const CustomerSuggestedRouteScreen()),
                  child: AppCard(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.navigation_outlined,
                            size: 20, color: AppColors.brand),
                        const SizedBox(width: 8),
                        const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('المسار المقترح',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.bodyMedium),
                            Text('المحطة المناسبة لوجهتك',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ])),
      ]);
}

const _showroomCars = [
  (
    id: 'car-tesla-3',
    model: 'Tesla Model 3',
    dealer: 'الراعبي أوتوكارز',
    type: 'سيدان',
    range: '540 km',
    price: '45,000 USD',
    priceValue: 45000,
    deposit: '500 USD',
    year: '2024',
    connector: 'CCS2',
    rating: '4.8'
  ),
  (
    id: 'car-tesla-y',
    model: 'Tesla Model Y',
    dealer: 'الراعبي أوتوكارز',
    type: 'SUV',
    range: '533 km',
    price: '35,000 USD',
    priceValue: 35000,
    deposit: '700 USD',
    year: '2024',
    connector: 'CCS2',
    rating: '4.9'
  ),
  (
    id: 'car-eqs',
    model: 'BYD Han',
    dealer: 'الراعبي أوتوكارز',
    type: 'سيدان',
    range: '605 km',
    price: '46,000 USD',
    priceValue: 46000,
    deposit: '900 USD',
    year: '2024',
    connector: 'GB/T',
    rating: '4.9'
  ),
  (
    id: 'car-nio-et7',
    model: 'NIO ET7',
    dealer: 'الراعبي أوتوكارز',
    type: 'سيدان ذكية',
    range: '1000 km',
    price: '58,000 USD',
    priceValue: 58000,
    deposit: '1,000 USD',
    year: '2024',
    connector: 'NACS',
    rating: '4.8'
  ),
];

class CustomerShowroomScreen extends StatefulWidget {
  const CustomerShowroomScreen(
      {super.key, this.isGuest = false, required this.onOpen});
  final bool isGuest;
  final ValueChanged<Widget> onOpen;
  @override
  State<CustomerShowroomScreen> createState() => _CustomerShowroomScreenState();
}

class _CustomerShowroomScreenState extends State<CustomerShowroomScreen> {
  String _filter = 'الكل';
  String _query = '';
  RangeValues _priceRange = const RangeValues(0, 100000);
  String _connector = 'الكل';
  String _dealer = 'الكل';
  String _specification = 'الكل';

  Future<void> _openFilters() async {
    var priceRange = _priceRange;
    var connector = _connector;
    var dealer = _dealer;
    var specification = _specification;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  TextButton(
                    onPressed: () => setSheetState(() {
                      priceRange = const RangeValues(0, 100000);
                      connector = 'الكل';
                      dealer = 'الكل';
                      specification = 'الكل';
                    }),
                    child: const Text('إعادة ضبط'),
                  ),
                  const Spacer(),
                  const Text('الفلترة', style: AppTextStyles.h2),
                ]),
                const SizedBox(height: 12),
                const Text('السعر',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: RangeSlider(
                    values: priceRange,
                    min: 0,
                    max: 100000,
                    divisions: 20,
                    labels: RangeLabels(
                      '\$${priceRange.start.round()}',
                      '\$${priceRange.end.round()}',
                    ),
                    onChanged: (value) =>
                        setSheetState(() => priceRange = value),
                  ),
                ),
                const Text('نوع الشاحن',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    for (final value in ['الكل', 'CCS2', 'GB/T', 'NACS'])
                      ChoiceChip(
                        label: Text(value),
                        selected: connector == value,
                        onSelected: (_) =>
                            setSheetState(() => connector = value),
                      ),
                  ],
                ),
                const Text('الوكيل',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    for (final value in [
                      'الكل',
                      ..._showroomCars.map((car) => car.dealer).toSet()
                    ])
                      ChoiceChip(
                        label: Text(value),
                        selected: dealer == value,
                        onSelected: (_) => setSheetState(() => dealer = value),
                      ),
                  ],
                ),
                const Text('المواصفات',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    for (final value in ['الكل', 'سيدان', 'SUV', '2024'])
                      ChoiceChip(
                        label: Text(value),
                        selected: specification == value,
                        onSelected: (_) =>
                            setSheetState(() => specification = value),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'عرض النتائج',
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (applied == true && mounted) {
      setState(() {
        _priceRange = priceRange;
        _connector = connector;
        _dealer = dealer;
        _specification = specification;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cars = _showroomCars
        .where((car) =>
            (_filter == 'الكل' || car.type == _filter) &&
            (car.priceValue >= _priceRange.start &&
                car.priceValue <= _priceRange.end) &&
            (_connector == 'الكل' || car.connector == _connector) &&
            (_dealer == 'الكل' || car.dealer == _dealer) &&
            (_specification == 'الكل' ||
                car.type == _specification ||
                car.year == _specification) &&
            ('${car.model} ${car.dealer}'.contains(_query)))
        .toList();
    return ListView(padding: const EdgeInsets.all(16), children: [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('الراعبي للسيارات',
                textAlign: TextAlign.right, style: AppTextStyles.heading),
            const SizedBox(height: 4),
            const Text('وكيل سيارات كهربائية معتمد • شارع حدة، صنعاء',
                textAlign: TextAlign.right, style: AppTextStyles.caption),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                '$_alRaabiLatitude, $_alRaabiLongitude  •  ★ 4.9',
                textAlign: TextAlign.right,
                style: AppTextStyles.caption,
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'بدء التوجه',
              icon: Icons.navigation_outlined,
              onPressed: () => widget.isGuest
                  ? _requireSignup(context)
                  : widget.onOpen(const CustomerTripScreen(
                      destinationName: 'الراعبي للسيارات',
                      latitude: _alRaabiLatitude,
                      longitude: _alRaabiLongitude,
                    )),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: OutlinedButton(
              onPressed: _openFilters,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 44),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune_rounded, size: 18),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'الفلترة',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Flexible(
            fit: FlexFit.tight,
            child: Text(
              'معرض السيارات الكهربائية',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.h2,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      TextField(
          onChanged: (value) => setState(() => _query = value.trim()),
          decoration: InputDecoration(
              hintText: 'ابحث عن سيارة أو وكيل',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.white,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
      const SizedBox(height: 10),
      Wrap(spacing: 8, children: [
        for (final type in ['الكل', 'سيدان', 'SUV'])
          ChoiceChip(
              label: Text(type),
              selected: _filter == type,
              onSelected: (_) => setState(() => _filter = type))
      ]),
      const SizedBox(height: 10),
      if (cars.isEmpty)
        const _EmptyHint(text: 'لا توجد سيارات تطابق خيارات البحث.'),
      for (final car in cars)
        Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
                onTap: () => widget.onOpen(
                    CustomerCarDetailScreen(car: car, isGuest: widget.isGuest)),
                child: AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: car.id == 'car-tesla-3'
                              ? Image.asset('assets/customer_car_detail.jpeg',
                                  height: 132,
                                  width: double.infinity,
                                  fit: BoxFit.cover)
                              : Container(
                                  height: 132,
                                  color: AppColors.mint,
                                  child: const Icon(
                                      Icons.directions_car_filled_outlined,
                                      size: 62,
                                      color: AppColors.brand))),
                      const SizedBox(height: 10),
                      Text(car.model,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.heading),
                      Text(car.dealer,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption),
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(car.price,
                                    style: AppTextStyles.bodyMedium),
                                Text(car.range, style: AppTextStyles.caption)
                              ])),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(
                            child: AppButton(
                                label: 'تفاصيل السيارة',
                                outlined: true,
                                onPressed: () => widget.onOpen(
                                    CustomerCarDetailScreen(
                                        car: car, isGuest: widget.isGuest)))),
                      ])
                    ])))),
    ]);
  }
}

class CustomerCarDetailScreen extends StatefulWidget {
  const CustomerCarDetailScreen(
      {super.key, required this.car, this.isGuest = false});
  final ({
    String id,
    String model,
    String dealer,
    String type,
    String range,
    String price,
    int priceValue,
    String deposit,
    String year,
    String connector,
    String rating
  }) car;
  final bool isGuest;
  @override
  State<CustomerCarDetailScreen> createState() =>
      _CustomerCarDetailScreenState();
}

class _CustomerCarDetailScreenState extends State<CustomerCarDetailScreen> {
  bool get _favorite =>
      CustomerLocalStore.instance.favorites.contains(widget.car.id);
  Future<void> _toggle() async {
    if (widget.isGuest) {
      await _requireSignup(context);
      return;
    }
    final store = CustomerLocalStore.instance;
    final next = {...store.favorites};
    _favorite ? next.remove(widget.car.id) : next.add(widget.car.id);
    await store.saveFavorites(next);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('تفاصيل السيارة'),
          actions: [
            IconButton(
                onPressed: _toggle,
                icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border,
                    color: _favorite ? AppColors.error : AppColors.brand)),
            OwnerBackAction(onPressed: () => Navigator.pop(context))
          ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: widget.car.id == 'car-tesla-3'
                ? Image.asset('assets/customer_car_detail.jpeg',
                    height: 210, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 210,
                    color: AppColors.mint,
                    child: const Icon(Icons.directions_car_filled_outlined,
                        size: 84, color: AppColors.brand))),
        const SizedBox(height: 14),
        Text(widget.car.model,
            textAlign: TextAlign.right, style: AppTextStyles.h2),
        Text(widget.car.dealer,
            textAlign: TextAlign.right, style: AppTextStyles.body),
        const SizedBox(height: 12),
        AppCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Text('النوع: ${widget.car.type}', textAlign: TextAlign.right),
              const SizedBox(height: 8),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                      'المدى ${widget.car.range}  •  السعر ${widget.car.price}',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMedium)),
              const SizedBox(height: 8),
              const Text('حالة السيارة: متاحة للحجز',
                  textAlign: TextAlign.right)
            ])),
        const SizedBox(height: 14),
        AppButton(
            label: 'أضف تقييماً للسيارة',
            outlined: true,
            onPressed: () => widget.isGuest
                ? _requireSignup(context)
                : _openReviewForm(context, widget.car.model)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: () => widget.isGuest
                ? _requireSignup(context)
                : Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) => CustomerDealerDetailScreen(
                            dealerName: widget.car.dealer,
                            isGuest: widget.isGuest))),
            icon: const Icon(Icons.storefront_outlined),
            label: const Text('عرض الوكيل')),
        const SizedBox(height: 8),
        AppButton(
            label: 'حجز السيارة ودفع العربون',
            onPressed: () => widget.isGuest
                ? _requireSignup(context)
                : Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (_) =>
                            CustomerDepositPaymentScreen(car: widget.car)))),
        const SizedBox(height: 8),
        AppButton(
            label: 'استفسر من الوكيل',
            outlined: true,
            onPressed: () => widget.isGuest
                ? _requireSignup(context)
                : _startInquiry(context, widget.car.dealer, widget.car.model))
      ]));
}

Future<void> _startInquiry(
    BuildContext context, String dealer, String car) async {
  final chat = await CustomerLocalStore.instance.startConversation(
      dealerName: dealer,
      carName: car,
      firstMessage: 'أهلاً، أود الاستفسار عن $car.');
  if (context.mounted) {
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (_) => CustomerConversationScreen(conversation: chat)));
  }
}

class CustomerDealerDetailScreen extends StatefulWidget {
  const CustomerDealerDetailScreen(
      {super.key, required this.dealerName, this.isGuest = false});
  final String dealerName;
  final bool isGuest;
  @override
  State<CustomerDealerDetailScreen> createState() =>
      _CustomerDealerDetailScreenState();
}

class _CustomerDealerDetailScreenState
    extends State<CustomerDealerDetailScreen> {
  String get _id => 'dealer:${widget.dealerName}';
  bool get _favorite => CustomerLocalStore.instance.favorites.contains(_id);
  Future<void> _toggle() async {
    if (widget.isGuest) {
      await _requireSignup(context);
      return;
    }
    final store = CustomerLocalStore.instance;
    final next = {...store.favorites};
    _favorite ? next.remove(_id) : next.add(_id);
    await store.saveFavorites(next);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('تفاصيل الوكيل'),
          actions: [
            IconButton(
                onPressed: _toggle,
                icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border,
                    color: _favorite ? AppColors.error : AppColors.brand)),
            OwnerBackAction(onPressed: () => Navigator.pop(context))
          ]),
      body: Builder(builder: (context) {
        final dealerCars = _showroomCars
            .where((car) => car.dealer == widget.dealerName)
            .toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'وكيل سيارات كهربائية معتمد • شارع حدة، صنعاء • خدمة ما بعد البيع وضمان.',
              textAlign: TextAlign.right,
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            'assets/dealer_profile/vehicle_1.jpeg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(widget.dealerName,
                                textAlign: TextAlign.right,
                                style: AppTextStyles.heading.copyWith(
                                    color: AppColors.brand,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            const Text('صنعاء، اليمن',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.caption),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: AppColors.brand),
                                const Text('4.9',
                                    textDirection: TextDirection.ltr,
                                    style: AppTextStyles.bodyMedium),
                                const SizedBox(width: 12),
                                const Icon(Icons.directions_car_outlined,
                                    size: 16, color: AppColors.brand),
                                Text('${dealerCars.length} سيارات متاحة',
                                    style: AppTextStyles.caption),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'عرض الموقع',
                          icon: Icons.location_on_outlined,
                          outlined: true,
                          onPressed: () => _showDealerLocation(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          label: 'تواصل بنا',
                          icon: Icons.chat_bubble_outline,
                          onPressed: () => widget.isGuest
                              ? _requireSignup(context)
                              : _startInquiry(context, widget.dealerName, ''),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('${dealerCars.length} سيارات',
                    style: AppTextStyles.caption),
                const Spacer(),
                const Text('سيارات الوكيل', style: AppTextStyles.heading),
              ],
            ),
            if (dealerCars.isEmpty)
              const _EmptyHint(
                  text: 'لا توجد سيارات متاحة لهذا الوكيل حالياً.'),
            for (final car in dealerCars)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => CustomerCarDetailScreen(
                          car: car, isGuest: widget.isGuest),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: _DealerVehicleCard(
                    car: car,
                    isGuest: widget.isGuest,
                    onDetails: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => CustomerCarDetailScreen(
                            car: car, isGuest: widget.isGuest),
                      ),
                    ),
                    onBook: () => widget.isGuest
                        ? _requireSignup(context)
                        : Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CustomerDepositPaymentScreen(car: car),
                            ),
                          ),
                  ),
                ),
              ),
          ],
        );
      }));
}

Future<void> _showDealerLocation(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('موقع الوكيل',
                style: AppTextStyles.heading, textAlign: TextAlign.right),
            const SizedBox(height: 10),
            const Text('شارع حدة، صنعاء، اليمن',
                style: AppTextStyles.body, textAlign: TextAlign.right),
            const SizedBox(height: 8),
            const Directionality(
              textDirection: TextDirection.ltr,
              child: Text('15.3072, 44.1812',
                  style: AppTextStyles.caption, textAlign: TextAlign.right),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DealerLocationPreview extends StatelessWidget {
  const _DealerLocationPreview({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 117,
          decoration: BoxDecoration(
            color: const Color(0xFFEDF3EF),
            border: Border.all(color: const Color(0xFFDBE6DE)),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              const Positioned.fill(child: CustomPaint(painter: _MapPainter())),
              const Align(
                alignment: Alignment(0.05, -0.05),
                child:
                    Icon(Icons.location_on, size: 32, color: AppColors.brand),
              ),
              Positioned(
                right: 8,
                bottom: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: .85),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    child: Text('صنعاء • اليمن', style: AppTextStyles.caption),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.all(7),
                  child: const Icon(Icons.my_location_outlined,
                      size: 18, color: AppColors.brand),
                ),
              ),
            ],
          ),
        ),
      );
}

class _DealerVehicleCard extends StatelessWidget {
  const _DealerVehicleCard({
    required this.car,
    required this.isGuest,
    required this.onDetails,
    required this.onBook,
  });

  final ({
    String id,
    String model,
    String dealer,
    String type,
    String range,
    String price,
    int priceValue,
    String deposit,
    String year,
    String connector,
    String rating,
  }) car;
  final bool isGuest;
  final VoidCallback onDetails;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CustomerLocalStore.instance,
      builder: (context, _) {
        final favorite = CustomerLocalStore.instance.favorites.contains(car.id);
        return AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 224,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(9)),
                      child: Image.asset(
                        switch (car.id) {
                          'car-tesla-3' =>
                            'assets/dealer_profile/vehicle_6.jpeg',
                          'car-tesla-y' =>
                            'assets/dealer_profile/vehicle_7.jpeg',
                          'car-eqs' => 'assets/dealer_profile/vehicle_4.jpeg',
                          'car-nio-et7' =>
                            'assets/dealer_profile/vehicle_2.jpeg',
                          _ => 'assets/customer_car_detail.jpeg',
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 16,
                      child: Material(
                        color: AppColors.white.withValues(alpha: .9),
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip:
                              favorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                          onPressed: () async {
                            if (isGuest) {
                              await _requireSignup(context);
                              return;
                            }
                            final store = CustomerLocalStore.instance;
                            final next = {...store.favorites};
                            favorite ? next.remove(car.id) : next.add(car.id);
                            await store.saveFavorites(next);
                          },
                          icon: Icon(
                            favorite ? Icons.favorite : Icons.favorite_border,
                            color: favorite ? AppColors.error : AppColors.brand,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: .92),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text('★ ${car.rating}',
                              style: AppTextStyles.caption),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(car.price,
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: AppColors.brand)),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(car.model,
                                textAlign: TextAlign.right,
                                style: AppTextStyles.heading
                                    .copyWith(fontSize: 20)),
                            Text('${car.year} • ${car.type}',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.caption),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _VehicleSpecTile(
                              label: 'الموصل',
                              value: car.connector,
                              icon: Icons.ev_station_outlined),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _VehicleSpecTile(
                              label: 'المدى',
                              value: car.range,
                              icon: Icons.bolt_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'حجز السيارة',
                            icon: Icons.calendar_month_outlined,
                            outlined: true,
                            onPressed: onBook,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppButton(
                            label: 'عرض التفاصيل',
                            // icon: Icons.arrow_forward_outlined,
                            onPressed: onDetails,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VehicleSpecTile extends StatelessWidget {
  const _VehicleSpecTile(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.brand.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.brand),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(value,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class CustomerSuggestedRouteScreen extends StatelessWidget {
  const CustomerSuggestedRouteScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('المحطة المناسبة لوجهتك'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          SizedBox(
              height: 270,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CustomPaint(
                      painter: _MapPainter(),
                      child: const Center(
                          child: Icon(Icons.location_on,
                              size: 56, color: AppColors.brand))))),
          const SizedBox(height: 14),
          const _PlaceCard(
              title: 'محطة النور الذكية',
              subtitle: 'على مسارك • صنعاء',
              rating: '4.9',
              detail: 'متاحة • CCS2 • 120 kW',
              icon: Icons.ev_station_outlined,
              favorite: false,
              onFavorite: _noop,
              onTap: _noop),
          const SizedBox(height: 12),
          const AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                Text('تفاصيل المسار',
                    textAlign: TextAlign.right, style: AppTextStyles.heading),
                SizedBox(height: 8),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('12.4 km  •  18 min',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium)),
                Text('محطة مناسبة لوجهتك وتدعم نوع موصل سيارتك.',
                    textAlign: TextAlign.right, style: AppTextStyles.caption)
              ])),
          const SizedBox(height: 14),
          AppButton(
              label: 'ابدأ الرحلة',
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const CustomerTripScreen()))),
        ]),
      );
}

class CustomerTripScreen extends StatelessWidget {
  const CustomerTripScreen({
    super.key,
    this.destinationName = 'محطة النور الذكية',
    this.latitude = 15.3072,
    this.longitude = 44.1812,
  });

  final String destinationName;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('رحلتك جارية'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _MapPainter()),
        SafeArea(
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppCard(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          Text('اتبع المسار إلى $destinationName',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.heading),
                          SizedBox(height: 8),
                          Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                  '$latitude, $longitude  •  12.4 km  •  18 min',
                                  textAlign: TextAlign.right))
                        ])))))
      ]));
}

class CustomerAssistantScreen extends StatelessWidget {
  const CustomerAssistantScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('المساعد الذكي'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const AppCard(
            child: Text(
                'مرحباً! أستطيع مساعدتك في العثور على محطة شحن أو ورشة مناسبة لسيارتك.',
                textAlign: TextAlign.right,
                style: AppTextStyles.body)),
        const SizedBox(height: 14),
        for (final q in ['أقرب محطة شحن', 'محطات تدعم CCS2', 'ورش صيانة قريبة'])
          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                  onPressed: () =>
                      _message(context, 'نعمل على تجهيز اقتراح مناسب لك.'),
                  child: Text(q)))
      ]));
}

class CustomerDepositPaymentScreen extends StatefulWidget {
  const CustomerDepositPaymentScreen({super.key, required this.car});
  final ({
    String id,
    String model,
    String dealer,
    String type,
    String range,
    String price,
    int priceValue,
    String deposit,
    String year,
    String connector,
    String rating
  }) car;
  @override
  State<CustomerDepositPaymentScreen> createState() =>
      _CustomerDepositPaymentScreenState();
}

class _CustomerDepositPaymentScreenState
    extends State<CustomerDepositPaymentScreen> {
  String _method = 'محفظة كريمي';
  bool _busy = false;
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _verificationController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _verificationController.dispose();
    super.dispose();
  }

  bool get _isBankTransfer => _method == 'تحويل بنكي';

  void _continue() {
    if (_step == 0) {
      if (_formKey.currentState?.validate() != true) return;
      setState(() => _step = 1);
      return;
    }
    if (_formKey.currentState?.validate() == true) _pay();
  }

  Future<void> _pay() async {
    setState(() => _busy = true);
    await CustomerLocalStore.instance.addBooking(CustomerBooking(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        carName: widget.car.model,
        dealerName: widget.car.dealer,
        deposit: widget.car.deposit,
        createdAt: TimeOfDay.now().format(context),
        paymentMethod: _method));
    if (!mounted) return;
    setState(() => _busy = false);
    await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('تم إنشاء الحجز'),
                content: const Text('تم تسجيل طلب الحجز والعربون بنجاح.'),
                actions: [
                  FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('حسناً'))
                ]));
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
              builder: (_) => const CustomerBookingsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('الدفع'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: Form(
          key: _formKey,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const Text('ملخص الحجز',
                textAlign: TextAlign.right, style: AppTextStyles.heading),
            const SizedBox(height: 10),
            AppCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  if (widget.car.id == 'car-tesla-3')
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/customer_car_detail.jpeg',
                            height: 132,
                            width: double.infinity,
                            fit: BoxFit.cover)),
                  if (widget.car.id == 'car-tesla-3')
                    const SizedBox(height: 10),
                  Text(widget.car.model,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMedium),
                  Text(widget.car.dealer,
                      textAlign: TextAlign.right, style: AppTextStyles.caption),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('السعر ${widget.car.price}',
                          textAlign: TextAlign.right)),
                  const Divider(),
                  const Text('العربون المطلوب:', textAlign: TextAlign.right),
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(widget.car.deposit,
                          textAlign: TextAlign.right, style: AppTextStyles.h3))
                ])),
            const SizedBox(height: 18),
            const Text('اختر وسيلة الدفع',
                textAlign: TextAlign.right, style: AppTextStyles.heading),
            for (final method in [
              'محفظة كريمي',
              'جوال بي',
              'ون كاش',
              'تحويل بنكي'
            ])
              RadioListTile<String>(
                  title: Text(method, textAlign: TextAlign.right),
                  value: method,
                  groupValue: _method,
                  activeColor: AppColors.brand,
                  onChanged: (value) => setState(() {
                        _method = value ?? _method;
                        _step = 0;
                        _verificationController.clear();
                      })),
            const SizedBox(height: 8),
            Text(_isBankTransfer ? 'بيانات الحساب البنكي' : 'بيانات المحفظة',
                textAlign: TextAlign.right, style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Directionality(
                textDirection: TextDirection.ltr,
                child: TextFormField(
                    controller: _accountController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.left,
                    validator: (value) => (value?.trim().length ?? 0) < 6
                        ? 'أدخل رقم الحساب أو المحفظة بشكل صحيح'
                        : null,
                    decoration: InputDecoration(
                        labelText: _isBankTransfer
                            ? 'رقم الحساب / مرجع التحويل'
                            : 'رقم المحفظة',
                        hintText: _isBankTransfer
                            ? 'مثال: 1234567890'
                            : '+967 7XX XXX XXX'))),
            if (_step == 1) ...[
              const SizedBox(height: 14),
              AppCard(
                  child: Text(
                      _isBankTransfer
                          ? 'أدخل رمز تأكيد التحويل الصادر من البنك لإتمام الحجز.'
                          : 'أدخل رمز التحقق أو رقم PIN المطلوب من مزود المحفظة لإتمام الحجز.',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.body)),
              const SizedBox(height: 10),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                      controller: _verificationController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.left,
                      maxLength: 6,
                      validator: (value) => (value?.trim().length ?? 0) < 4
                          ? 'أدخل رمز التحقق لإكمال العملية'
                          : null,
                      decoration: const InputDecoration(
                          labelText: 'رمز التحقق / PIN',
                          hintText: '••••••',
                          counterText: ''))),
              const SizedBox(height: 4),
              const Text('واجهة دفع تجريبية؛ لا يتم إرسال بياناتك إلى جهة دفع.',
                  textAlign: TextAlign.right, style: AppTextStyles.caption)
            ]
          ])),
      bottomNavigationBar: OwnerStickyAction(
          keyboardAware: true,
          child: AppButton(
              label: _busy
                  ? 'جارٍ تأكيد الدفع…'
                  : _step == 0
                      ? 'متابعة التحقق'
                      : 'تأكيد الحجز ودفع العربون',
              onPressed: _busy ? null : _continue)));
}

class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('الإشعارات'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: ListView(padding: const EdgeInsets.all(16), children: const [
        AppCard(
            child: ListTile(
                leading:
                    Icon(Icons.ev_station_outlined, color: AppColors.brand),
                title: Text('محطة النور الذكية أصبحت متاحة',
                    textAlign: TextAlign.right),
                subtitle: Text('تتوفر محطة مناسبة على مسارك المقترح.',
                    textAlign: TextAlign.right))),
        SizedBox(height: 10),
        AppCard(
            child: ListTile(
                leading:
                    Icon(Icons.directions_car_outlined, color: AppColors.brand),
                title:
                    Text('تحديث على حجز السيارة', textAlign: TextAlign.right),
                subtitle: Text('يمكنك متابعة تفاصيل الحجز من حجوزاتي.',
                    textAlign: TextAlign.right)))
      ]));
}

class _MapPin extends StatelessWidget {
  const _MapPin(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 6)
                ]),
            child: Icon(icon, color: Colors.white, size: 22)),
        const SizedBox(height: 3),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Text(label, style: AppTextStyles.caption))
      ]));
}

Future<void> _requireSignup(BuildContext context) async {
  await Navigator.push(context,
      MaterialPageRoute<void>(builder: (_) => const CustomerSignupScreen()));
}

void _handleMapPin(BuildContext context,
    {required bool isGuest,
    required String title,
    required String subtitle,
    required VoidCallback onOpen}) {
  if (!isGuest) {
    onOpen();
    return;
  }
  showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) => SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.heading),
                    Text(subtitle,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.caption),
                    const SizedBox(height: 14),
                    AppButton(
                        label: 'توجه إلى الموقع',
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _requireSignup(context);
                        })
                  ]))));
}

class _VehicleBanner extends StatelessWidget {
  const _VehicleBanner();
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: CustomerLocalStore.instance,
      builder: (context, _) => AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(children: [
            const Icon(Icons.directions_car_filled_outlined,
                color: AppColors.brand, size: 30),
            const SizedBox(width: 10),
            const Expanded(
                child: Text('أهلاً بك، اختر سيارتك الحالية',
                    textAlign: TextAlign.right, style: AppTextStyles.caption)),
            DropdownButton<String>(
              value: CustomerLocalStore.instance.profile.vehicle.isEmpty
                  ? null
                  : CustomerLocalStore.instance.profile.vehicle,
              // hint: const Text('اختر السيارة', style: AppTextStyles.caption),
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.brand),
              items: const [
                DropdownMenuItem(
                    value: 'Tesla Model 3', child: Text('Tesla Model 3')),
                DropdownMenuItem(
                    value: 'Mercedes EQS Sedan',
                    child: Text('Mercedes EQS Sedan')),
                DropdownMenuItem(
                    value: 'Audi e-tron GT', child: Text('Audi e-tron GT')),
                DropdownMenuItem(value: 'Lucid Air', child: Text('Lucid Air')),
              ],
              onChanged: (value) {
                if (value != null) {
                  CustomerLocalStore.instance.saveProfile(CustomerLocalStore
                      .instance.profile
                      .copyWith(vehicle: value));
                }
              },
            ),
          ])));
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFEAF0E7));
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final minor = Paint()
      ..color = const Color(0xFFD7DFD4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final paths = [
      Path()
        ..moveTo(0, size.height * .28)
        ..cubicTo(size.width * .25, size.height * .45, size.width * .55,
            size.height * .15, size.width, size.height * .37),
      Path()
        ..moveTo(size.width * .1, size.height)
        ..cubicTo(size.width * .3, size.height * .65, size.width * .5,
            size.height * .6, size.width * .78, 0),
      Path()
        ..moveTo(0, size.height * .75)
        ..lineTo(size.width, size.height * .66)
    ];
    for (final p in paths) {
      canvas.drawPath(p, road);
      canvas.drawPath(p, minor);
    }
    for (var i = 0; i < 6; i++) {
      final x = size.width * (.08 + i * .16);
      canvas.drawLine(Offset(x, 0), Offset(x - 16, size.height), minor);
    }
    final suggestedRoute = Path()
      ..moveTo(size.width * .29, size.height * .87)
      ..cubicTo(size.width * .28, size.height * .68, size.width * .27,
          size.height * .58, size.width * .36, size.height * .56)
      ..cubicTo(size.width * .57, size.height * .55, size.width * .61,
          size.height * .47, size.width * .67, size.height * .39)
      ..cubicTo(size.width * .72, size.height * .29, size.width * .73,
          size.height * .24, size.width * .73, size.height * .22);
    canvas.drawPath(
        suggestedRoute,
        Paint()
          ..color = AppColors.brand
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
        const Spacer(),
        Text(title, style: AppTextStyles.heading)
      ]));
}

class CustomerBrowseScreen extends StatelessWidget {
  const CustomerBrowseScreen({super.key, required this.kind});
  final String kind;
  @override
  Widget build(BuildContext context) {
    final workshops = kind.contains('ورش');
    final items = workshops
        ? [
            (
              'ورشة المستقبل للسيارات',
              'شارع تعز، صنعاء',
              '4.6',
              'صيانة السيارات الكهربائية'
            ),
            ('مركز EV للصيانة', 'شارع حدة، صنعاء', '4.9', 'فحص وإصلاح السيارات')
          ]
        : [
            ('محطة صنعاء للشحن', 'شارع حدة، صنعاء', '4.8', 'CCS2  •  120 kW'),
            ('محطة الجامعة', 'شارع الستين، صنعاء', '4.5', 'CCS2  •  80 kW')
          ];
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(kind),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          TextField(
              decoration: InputDecoration(
                  hintText: 'ابحث عن ${workshops ? 'ورشة' : 'محطة'}',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 14),
          for (final item in items)
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlaceCard(
                    title: item.$1,
                    subtitle: item.$2,
                    rating: item.$3,
                    detail: item.$4,
                    icon: workshops
                        ? Icons.build_outlined
                        : Icons.ev_station_outlined,
                    favorite: false,
                    onFavorite: () => _message(context, 'أضيف إلى المفضلة.'),
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) => CustomerPlaceDetailScreen(
                                title: item.$1,
                                kind:
                                    workshops ? 'ورشة صيانة' : 'محطة شحن'))))),
          OutlinedButton.icon(
              onPressed: () =>
                  _message(context, 'سيتم عرض المواقع على الخريطة.'),
              icon: const Icon(Icons.map_outlined),
              label: Text('عرض ${workshops ? 'الورش' : 'المحطات'} على الخريطة'))
        ]));
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard(
      {required this.title,
      required this.subtitle,
      required this.rating,
      required this.detail,
      required this.icon,
      required this.favorite,
      required this.onFavorite,
      required this.onTap});
  final String title, subtitle, rating, detail;
  final IconData icon;
  final bool favorite;
  final VoidCallback onFavorite, onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AppCard(
          child: Row(
            children: [
              Icon(icon, size: 34, color: AppColors.brand),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium),
                    Text(subtitle,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.caption),
                    Text(detail,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.caption),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 15, color: AppColors.accent),
                          Text(' $rating', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border,
                    color: favorite ? AppColors.error : AppColors.secondary),
              ),
            ],
          ),
        ),
      );
}

class CustomerPlaceDetailScreen extends StatefulWidget {
  const CustomerPlaceDetailScreen(
      {super.key,
      required this.title,
      required this.kind,
      this.isGuest = false,
      this.latitude,
      this.longitude});
  final String title, kind;
  final bool isGuest;
  final double? latitude, longitude;
  @override
  State<CustomerPlaceDetailScreen> createState() =>
      _CustomerPlaceDetailScreenState();
}

class _CustomerPlaceDetailScreenState extends State<CustomerPlaceDetailScreen> {
  String get _id => 'place:${widget.title}';
  (double, double) get _coordinates {
    if (widget.latitude != null && widget.longitude != null) {
      return (widget.latitude!, widget.longitude!);
    }
    return switch (widget.title) {
      'ورشة المستقبل للسيارات' => (15.3078, 44.1818),
      'مركز EV لقطع الغيار' => (15.3149, 44.2064),
      'ورشة النور' => (12.7855, 45.0187),
      _ => (15.3072, 44.1812),
    };
  }

  Future<void> _navigateToLocation() async {
    if (widget.isGuest) {
      await _requireSignup(context);
      return;
    }
    final coordinates = _coordinates;
    if (!mounted) return;
    await Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (_) => CustomerTripScreen(
                destinationName: widget.title,
                latitude: coordinates.$1,
                longitude: coordinates.$2)));
  }

  bool get _favorite => CustomerLocalStore.instance.favorites.contains(_id);
  Future<void> _toggle() async {
    if (widget.isGuest) {
      await _requireSignup(context);
      return;
    }
    final store = CustomerLocalStore.instance;
    final next = {...store.favorites};
    _favorite ? next.remove(_id) : next.add(_id);
    await store.saveFavorites(next);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('التفاصيل'),
          actions: [
            IconButton(
                onPressed: _toggle,
                icon: Icon(_favorite ? Icons.favorite : Icons.favorite_border,
                    color: _favorite ? AppColors.error : AppColors.brand)),
            OwnerBackAction(onPressed: () => Navigator.pop(context))
          ]),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: widget.kind == 'محطة شحن'
                ? Image.asset('assets/customer_station_detail.jpeg',
                    height: 185, width: double.infinity, fit: BoxFit.cover)
                : Container(
                    height: 185,
                    color: AppColors.mint,
                    child: const Icon(Icons.location_on_outlined,
                        size: 60, color: AppColors.brand))),
        const SizedBox(height: 15),
        Text(widget.title, textAlign: TextAlign.right, style: AppTextStyles.h2),
        Text(widget.kind,
            textAlign: TextAlign.right, style: AppTextStyles.body),
        const SizedBox(height: 10),
        AppCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Text(
                  widget.title.contains('النور')
                      ? 'عدن، اليمن'
                      : 'صنعاء، اليمن',
                  textAlign: TextAlign.right),
              const SizedBox(height: 8),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                      '${_coordinates.$1.toStringAsFixed(4)}, ${_coordinates.$2.toStringAsFixed(4)}',
                      textAlign: TextAlign.right)),
              const SizedBox(height: 8),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text('★ 4.8  •  (26)', textAlign: TextAlign.right))
            ])),
        const SizedBox(height: 15),
        const _SectionHeading(title: 'التقييمات'),
        const _ReviewTile(
            name: 'محمد عبدالله',
            score: '5.0',
            review: 'خدمة ممتازة وتعامل رائع.'),
        const SizedBox(height: 14),
        if (widget.kind == 'ورشة صيانة' || widget.kind == 'قطع غيار') ...[
          AppButton(label: 'توجه للموقع', onPressed: _navigateToLocation),
          const SizedBox(height: 8),
        ],
        AppButton(
            label: widget.kind == 'محطة شحن'
                ? 'توجه إلى المحطة'
                : 'تواصل مع مزود الخدمة',
            onPressed: () => widget.isGuest
                ? _requireSignup(context)
                : widget.kind == 'محطة شحن'
                    ? _navigateToLocation()
                    : _message(context, 'سيتم تجهيز التواصل مع مزود الخدمة.')),
        const SizedBox(height: 8),
        AppButton(
            label: 'أضف تقييماً',
            outlined: true,
            onPressed: () => widget.isGuest
                ? _requireSignup(context)
                : _openReviewForm(context, widget.title)),
      ]));
}

class CustomerVehicleScreen extends StatefulWidget {
  const CustomerVehicleScreen({super.key, this.selectionMode = false});
  final bool selectionMode;
  @override
  State<CustomerVehicleScreen> createState() => _CustomerVehicleScreenState();
}

class _CustomerVehicleScreenState extends State<CustomerVehicleScreen> {
  String selected = CustomerLocalStore.instance.profile.vehicle;
  final vehicles = const [
    ('Mercedes EQS Sedan', 'Mercedes-Benz', '2024', '480 km', 'CCS2'),
    ('Tesla Model 3', 'Tesla', '2023', '420 km', 'CCS2'),
    ('Audi e-tron GT', 'Audi', '2024', '390 km', 'CCS2'),
    ('Lucid Air', 'Lucid', '2023', '500 km', 'CCS2')
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: widget.selectionMode
          ? AppBar(
              automaticallyImplyLeading: false,
              title: const Text('اختر سيارتك'))
          : null,
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (!widget.selectionMode)
          const Text('سياراتي',
              textAlign: TextAlign.right, style: AppTextStyles.h2),
        for (final v in vehicles)
          Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                  onTap: () => setState(() => selected = v.$1),
                  child: AppCard(
                      child: Row(children: [
                    Icon(
                        selected == v.$1
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: AppColors.brand),
                    const SizedBox(width: 12),
                    const Icon(Icons.directions_car_outlined,
                        color: AppColors.brand, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          Text(v.$1,
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodyMedium),
                          Text('${v.$2}  •  ${v.$3}',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.caption),
                          Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text('${v.$4}  •  ${v.$5}',
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.caption))
                        ]))
                  ])))),
        if (!widget.selectionMode)
          const _EmptyHint(text: 'أضف سيارتك لمشاهدة معلوماتها هنا.')
      ]),
      bottomNavigationBar: widget.selectionMode
          ? OwnerStickyAction(
              child: AppButton(
                  label: 'تعيين السيارة',
                  onPressed: () async {
                    await CustomerLocalStore.instance.saveProfile(
                        CustomerLocalStore.instance.profile
                            .copyWith(vehicle: selected));
                    if (context.mounted) Navigator.pop(context);
                  }))
          : null);
}

class CustomerChatsScreen extends StatefulWidget {
  const CustomerChatsScreen({super.key, required this.onOpen});
  final ValueChanged<Widget> onOpen;
  @override
  State<CustomerChatsScreen> createState() => _CustomerChatsScreenState();
}

class _CustomerChatsScreenState extends State<CustomerChatsScreen> {
  String _query = '';
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: CustomerLocalStore.instance,
      builder: (context, _) =>
          ListView(padding: const EdgeInsets.all(16), children: [
            const Text('المحادثات',
                textAlign: TextAlign.right, style: AppTextStyles.heading),
            const SizedBox(height: 12),
            TextField(
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                    hintText: 'ابحث في المحادثات',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border)))),
            const SizedBox(height: 14),
            if (CustomerLocalStore.instance.conversations
                .where((c) =>
                    c.customerEmail ==
                    CustomerLocalStore.instance.profile.email)
                .isEmpty)
              const _EmptyHint(
                  text:
                      'لا توجد محادثات بعد. ابدأ استفساراً من صفحة وكيل سيارات.'),
            for (final item in CustomerLocalStore.instance.conversations.where(
                (c) =>
                    c.customerEmail ==
                        CustomerLocalStore.instance.profile.email &&
                    '${c.dealerName} ${c.carName} ${c.lastMessage}'
                        .contains(_query)))
              AppCard(
                  child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                          backgroundColor: AppColors.mint,
                          child: Icon(Icons.storefront_outlined,
                              color: AppColors.brand)),
                      title: Text(item.dealerName,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium),
                      subtitle: Text(
                          '${item.carName.isEmpty ? '' : '${item.carName} • '}${item.lastMessage}',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption),
                      trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Directionality(
                                textDirection: TextDirection.ltr,
                                child: Text(item.updatedAt,
                                    style: AppTextStyles.caption)),
                            if (item.unread)
                              const CircleAvatar(
                                  radius: 4, backgroundColor: AppColors.brand)
                          ]),
                      onTap: () => widget.onOpen(
                          CustomerConversationScreen(conversation: item))))
          ]));
}

class CustomerConversationScreen extends StatefulWidget {
  const CustomerConversationScreen({super.key, required this.conversation});
  final CustomerConversation conversation;
  @override
  State<CustomerConversationScreen> createState() =>
      _CustomerConversationScreenState();
}

class _CustomerConversationScreenState
    extends State<CustomerConversationScreen> {
  final _input = TextEditingController();
  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    _input.clear();
    await CustomerLocalStore.instance.sendMessage(widget.conversation.id, text);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.conversation.dealerName),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: Column(children: [
        if (widget.conversation.carName.isNotEmpty)
          Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: AppCard(
                  child: Row(children: [
                const Icon(Icons.directions_car_outlined,
                    color: AppColors.brand),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(widget.conversation.carName,
                        textAlign: TextAlign.right,
                        style: AppTextStyles.bodyMedium)),
                const AppStatusBadge('استفسار سيارة')
              ]))),
        Expanded(
            child: AnimatedBuilder(
                animation: CustomerLocalStore.instance,
                builder: (context, _) {
                  final messages = CustomerLocalStore
                          .instance.messages[widget.conversation.id] ??
                      [];
                  if (messages.isEmpty) {
                    return const _EmptyHint(
                        text:
                            'لا توجد رسائل بعد. اكتب استفسارك لبدء المحادثة.');
                  }
                  return ListView(padding: const EdgeInsets.all(14), children: [
                    for (final message in messages)
                      Align(
                          alignment: message.fromCustomer
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(maxWidth: 290),
                              decoration: BoxDecoration(
                                  color: message.fromCustomer
                                      ? AppColors.white
                                      : AppColors.brand,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: message.fromCustomer
                                          ? AppColors.border
                                          : AppColors.brand)),
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(message.text,
                                        textAlign: TextAlign.right,
                                        style: message.fromCustomer
                                            ? AppTextStyles.body
                                            : AppTextStyles.body.copyWith(
                                                color: AppColors.white)),
                                    Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Text(message.sentAt,
                                            textAlign: TextAlign.left,
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                    color: message.fromCustomer
                                                        ? AppColors.secondary
                                                        : AppColors.white
                                                            .withValues(
                                                                alpha: .8))))
                                  ])))
                  ]);
                })),
        SafeArea(
            top: false,
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(
                      child: TextField(
                          controller: _input,
                          decoration:
                              const InputDecoration(hintText: 'اكتب رسالتك'))),
                  IconButton(
                      onPressed: _send,
                      icon: const Icon(Icons.send, color: AppColors.brand))
                ])))
      ]));
}

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen(
      {super.key, required this.onOpen, required this.onLogout});
  final ValueChanged<Widget> onOpen;
  final VoidCallback onLogout;
  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  @override
  void initState() {
    super.initState();
    final p = CustomerLocalStore.instance.profile;
    _name.text = p.name;
    _phone.text = p.phone;
    _email.text = p.email;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await CustomerLocalStore.instance.saveProfile(
        CustomerLocalStore.instance.profile.copyWith(
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            email: _email.text.trim()));
    if (mounted) {
      setState(() {});
      _message(context, 'تم حفظ تعديلات الحساب.');
    }
  }

  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(16), children: [
        const CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.mint,
            child: Icon(Icons.person, size: 38, color: AppColors.brand)),
        const SizedBox(height: 8),
        Text(
            CustomerLocalStore.instance.profile.name.isEmpty
                ? 'حساب العميل'
                : CustomerLocalStore.instance.profile.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.heading),
        const SizedBox(height: 16),
        _VehicleBanner(),
        const SizedBox(height: 18),
        const _SectionHeading(title: 'بيانات الحساب'),
        CustomLabeledTextField(label: 'الاسم الكامل', controller: _name),
        const SizedBox(height: 10),
        Directionality(
            textDirection: TextDirection.ltr,
            child: CustomLabeledTextField(
                label: 'رقم الهاتف',
                controller: _phone,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left)),
        const SizedBox(height: 10),
        CustomLabeledTextField(
            label: 'البريد الإلكتروني',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left),
        const SizedBox(height: 12),
        AppButton(label: 'حفظ التعديلات', onPressed: _save),
        const SizedBox(height: 18),
        _SectionHeading(
            title: 'التقييمات والمراجعات',
            action: 'عرض الكل',
            onAction: () => widget.onOpen(const CustomerReviewsScreen())),
        if (CustomerLocalStore.instance.reviews.isEmpty)
          const _EmptyHint(text: 'لم ترسل تقييماً بعد.'),
        for (final review in CustomerLocalStore.instance.reviews.take(2))
          _CustomerReviewCard(review: review),
        const SizedBox(height: 14),
        AppCard(
            child: Column(children: [
          ListTile(
              leading:
                  const Icon(Icons.favorite_border, color: AppColors.brand),
              title: const Text('المفضلة', textAlign: TextAlign.right),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => widget.onOpen(const CustomerFavoritesScreen())),
          const Divider(height: 1),
          ListTile(
              leading:
                  const Icon(Icons.bookmark_border, color: AppColors.brand),
              title: const Text('حجوزاتي', textAlign: TextAlign.right),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => widget.onOpen(const CustomerBookingsScreen())),
          const Divider(height: 1),
          ListTile(
              leading: const Icon(Icons.store_mall_directory_outlined,
                  color: AppColors.brand),
              title: const Text('مزودو الخدمات', textAlign: TextAlign.right),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  widget.onOpen(const CustomerServiceDirectoryScreen())),
          const Divider(height: 1),
          ListTile(
              leading: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.brand),
              title: const Text('الإشعارات', textAlign: TextAlign.right),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => widget.onOpen(const CustomerNotificationsScreen())),
          const Divider(height: 1),
          ListTile(
              leading: const Icon(Icons.rate_review_outlined,
                  color: AppColors.brand),
              title:
                  const Text('تقييماتي ومراجعاتي', textAlign: TextAlign.right),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => widget.onOpen(const CustomerReviewsScreen())),
          const Divider(height: 1),
          ListTile(
              leading:
                  const Icon(Icons.settings_outlined, color: AppColors.brand),
              title: const Text('إعدادات الحساب', textAlign: TextAlign.right),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => widget.onOpen(const CustomerSettingsScreen())),
          const Divider(height: 1),
          ListTile(
              leading: const Icon(Icons.support_agent_outlined,
                  color: AppColors.brand),
              title: const Text('الدعم والخصوصية', textAlign: TextAlign.right),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => widget.onOpen(const CustomerSupportScreen())),
          const Divider(height: 1),
          ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('تسجيل الخروج',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: AppColors.error)),
              onTap: widget.onLogout)
        ]))
      ]);
}

class CustomerSavedAndBookingsScreen extends StatefulWidget {
  const CustomerSavedAndBookingsScreen({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<CustomerSavedAndBookingsScreen> createState() =>
      _CustomerSavedAndBookingsScreenState();
}

class _CustomerSavedAndBookingsScreenState
    extends State<CustomerSavedAndBookingsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.initialTab == 0 ? 'المفضلة' : 'حجوزاتي'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: widget.initialTab == 0 ? _favoritesList() : _bookingsList(),
      );

  Widget _favoritesList() => AnimatedBuilder(
      animation: CustomerLocalStore.instance,
      builder: (context, _) {
        final store = CustomerLocalStore.instance;
        if (store.favorites.isEmpty) {
          return const _EmptyHint(text: 'لم تحفظ عناصر في المفضلة بعد.');
        }
        final keys = store.favorites.toList();
        return ListView(padding: const EdgeInsets.all(16), children: [
          for (final id in keys)
            _FavoriteItem(
                id: id,
                onRemove: () async {
                  final next = {...store.favorites}..remove(id);
                  await store.saveFavorites(next);
                })
        ]);
      });

  Widget _bookingsList() => AnimatedBuilder(
      animation: CustomerLocalStore.instance,
      builder: (context, _) {
        final bookings = CustomerLocalStore.instance.bookings;
        if (bookings.isEmpty) {
          return const _EmptyHint(text: 'لا توجد حجوزات حالياً.');
        }
        return ListView(padding: const EdgeInsets.all(16), children: [
          for (final booking in bookings)
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      Text(booking.carName,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium),
                      Text(booking.dealerName,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption),
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text('Deposit: ${booking.deposit}',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.bodyMedium)),
                      Text('وسيلة الدفع: ${booking.paymentMethod}',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption),
                      Text('الحالة: ${booking.status}',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.caption),
                      if (booking.status == 'نشط')
                        Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                                onPressed: () =>
                                    _confirmCancel(context, booking),
                                child: const Text('إلغاء الحجز',
                                    style: TextStyle(color: AppColors.error))))
                    ])))
        ]);
      });

  Future<void> _confirmCancel(
      BuildContext context, CustomerBooking booking) async {
    final yes = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
                title: const Text('إلغاء الحجز'),
                content: const Text(
                    'لن يتم استرداد مبلغ العربون المدفوع. هل تريد تأكيد إلغاء الحجز؟'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('العودة')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('تأكيد الإلغاء'))
                ]));
    if (yes == true) CustomerLocalStore.instance.cancelBooking(booking.id);
  }
}

class CustomerFavoritesScreen extends StatelessWidget {
  const CustomerFavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) => const CustomerSavedAndBookingsScreen();
}

class CustomerBookingsScreen extends StatelessWidget {
  const CustomerBookingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const CustomerSavedAndBookingsScreen(initialTab: 1);
}

class _FavoriteItem extends StatelessWidget {
  const _FavoriteItem({required this.id, required this.onRemove});
  final String id;
  final VoidCallback onRemove;
  @override
  Widget build(BuildContext context) {
    final cars = _showroomCars.where((e) => e.id == id).toList();
    final car = cars.isEmpty ? null : cars.first;
    final title = car?.model ??
        (id.startsWith('dealer:')
            ? id.substring(7)
            : id.startsWith('place:')
                ? id.substring(6)
                : id == 'workshop-future' || id == 'workshop1'
                    ? 'ورشة المستقبل للسيارات'
                    : id == 'workshop-light'
                        ? 'ورشة النور'
                        : id == 'parts-ev'
                            ? 'مركز EV لقطع الغيار'
                            : 'محطة صنعاء للشحن');
    final icon = car != null
        ? Icons.directions_car_outlined
        : id.startsWith('dealer:')
            ? Icons.storefront_outlined
            : id.contains('workshop') ||
                    id == 'workshop1' ||
                    (id.startsWith('place:') && title.contains('ورشة'))
                ? Icons.build_outlined
                : id == 'parts-ev' || title.contains('قطع غيار')
                    ? Icons.handyman_outlined
                    : Icons.ev_station_outlined;
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
            child: Row(children: [
          Icon(icon, color: AppColors.brand),
          const SizedBox(width: 10),
          Expanded(
              child: InkWell(
                  onTap: () {
                    if (car != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) =>
                                  CustomerCarDetailScreen(car: car)));
                    } else if (id.startsWith('dealer:')) {
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) => CustomerDealerDetailScreen(
                                  dealerName: title)));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                              builder: (_) => CustomerPlaceDetailScreen(
                                  title: title,
                                  kind: id == 'parts-ev' ||
                                          title.contains('قطع غيار')
                                      ? 'قطع غيار'
                                      : id.contains('workshop') ||
                                              id == 'workshop1' ||
                                              title.contains('ورشة')
                                          ? 'ورشة صيانة'
                                          : 'محطة شحن')));
                    }
                  },
                  child: Text(title,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMedium))),
          IconButton(
              tooltip: 'إزالة من المفضلة',
              onPressed: onRemove,
              icon: const Icon(Icons.favorite, color: AppColors.error))
        ])));
  }
}

class CustomerServiceDirectoryScreen extends StatefulWidget {
  const CustomerServiceDirectoryScreen({super.key});
  @override
  State<CustomerServiceDirectoryScreen> createState() =>
      _CustomerServiceDirectoryScreenState();
}

class _CustomerServiceDirectoryScreenState
    extends State<CustomerServiceDirectoryScreen> {
  String _query = '';
  String _type = 'الكل';
  final _providers = const [
    (
      id: 'place:ورشة المستقبل للسيارات',
      name: 'ورشة المستقبل للسيارات',
      type: 'ورشة',
      city: 'صنعاء',
      score: '4.6'
    ),
    (
      id: 'place:مركز EV لقطع الغيار',
      name: 'مركز EV لقطع الغيار',
      type: 'قطع غيار',
      city: 'صنعاء',
      score: '4.8'
    ),
    (
      id: 'place:ورشة النور',
      name: 'ورشة النور',
      type: 'ورشة',
      city: 'عدن',
      score: '4.7'
    ),
  ];
  @override
  Widget build(BuildContext context) {
    final results = _providers
        .where((p) =>
            (_type == 'الكل' || p.type == _type) &&
            '${p.name} ${p.city}'.contains(_query))
        .toList();
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('مزودو الخدمات'),
            actions: [
              OwnerBackAction(onPressed: () => Navigator.pop(context))
            ]),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                  hintText: 'ابحث عن ورشة أو قطع غيار',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            for (final type in ['الكل', 'ورشة', 'قطع غيار'])
              ChoiceChip(
                  label: Text(type),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type))
          ]),
          const SizedBox(height: 12),
          if (results.isEmpty)
            const _EmptyHint(text: 'لا يوجد مزودون مطابقون للبحث.'),
          for (final p in results)
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlaceCard(
                    title: p.name,
                    subtitle: '${p.type} • ${p.city}',
                    rating: p.score,
                    detail: p.type == 'ورشة'
                        ? 'خدمات صيانة المركبات الكهربائية'
                        : 'مزود قطع غيار للمركبات الكهربائية',
                    icon: p.type == 'ورشة'
                        ? Icons.build_outlined
                        : Icons.handyman_outlined,
                    favorite:
                        CustomerLocalStore.instance.favorites.contains(p.id),
                    onFavorite: () async {
                      final store = CustomerLocalStore.instance;
                      final next = {...store.favorites};
                      next.contains(p.id) ? next.remove(p.id) : next.add(p.id);
                      await store.saveFavorites(next);
                      setState(() {});
                    },
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (_) => CustomerPlaceDetailScreen(
                                title: p.name,
                                kind: p.type == 'ورشة'
                                    ? 'ورشة صيانة'
                                    : 'قطع غيار')))))
        ]));
  }
}

class CustomerReviewsScreen extends StatelessWidget {
  const CustomerReviewsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('تقييماتي ومراجعاتي'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: AnimatedBuilder(
          animation: CustomerLocalStore.instance,
          builder: (context, _) {
            final reviews = CustomerLocalStore.instance.reviews;
            if (reviews.isEmpty) {
              return const _EmptyHint(text: 'لم ترسل تقييماً بعد.');
            }
            return ListView(padding: const EdgeInsets.all(16), children: [
              for (final review in reviews) _CustomerReviewCard(review: review)
            ]);
          }));
}

class _CustomerReviewCard extends StatelessWidget {
  const _CustomerReviewCard({required this.review});
  final CustomerReview review;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(review.targetName,
            textAlign: TextAlign.right, style: AppTextStyles.bodyMedium),
        Directionality(
            textDirection: TextDirection.ltr,
            child: Text('★ ${review.score}',
                textAlign: TextAlign.right, style: AppTextStyles.caption)),
        Text(review.comment,
            textAlign: TextAlign.right, style: AppTextStyles.body),
        if (review.reply.isNotEmpty)
          Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(8)),
              child: Text('رد الجهة: ${review.reply}',
                  textAlign: TextAlign.right, style: AppTextStyles.caption))
      ])));
}

Future<void> _openReviewForm(BuildContext context, String target) async {
  await showDialog<void>(
      context: context, builder: (_) => _ReviewFormDialog(target: target));
}

class _ReviewFormDialog extends StatefulWidget {
  const _ReviewFormDialog({required this.target});
  final String target;

  @override
  State<_ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<_ReviewFormDialog> {
  final _comment = TextEditingController();
  int _score = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final comment = _comment.text.trim();
    if (comment.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    await CustomerLocalStore.instance.addReview(CustomerReview(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        targetName: widget.target,
        score: '$_score',
        comment: comment));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('أضف تقييماً'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.target, textAlign: TextAlign.right),
          DropdownButton<int>(
              value: _score,
              items: [
                for (var i = 5; i >= 1; i--)
                  DropdownMenuItem(
                      value: i,
                      child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text('$i ★')))
              ],
              onChanged: _submitting
                  ? null
                  : (value) => setState(() => _score = value ?? _score)),
          TextField(
              controller: _comment,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'اكتب تعليقك'))
        ]),
        actions: [
          TextButton(
              onPressed: _submitting ? null : () => Navigator.of(context).pop(),
              child: const Text('إلغاء')),
          FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'جارٍ الإرسال…' : 'إرسال'))
        ],
      );
}

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});
  @override
  State<CustomerSettingsScreen> createState() => _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  final store = CustomerLocalStore.instance;
  Future<void> _notify(bool value, bool offers) async {
    await store.saveNotifications(enabled: value, offers: offers);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('إعدادات الحساب'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const _SectionHeading(title: 'الإشعارات'),
        AppCard(
            child: Column(children: [
          SwitchListTile(
              title: const Text('الإشعارات', textAlign: TextAlign.right),
              subtitle: const Text('تنبيهات الطلبات والمحادثات',
                  textAlign: TextAlign.right),
              value: store.notificationsEnabled,
              activeTrackColor: AppColors.brand,
              onChanged: (v) => _notify(v, store.offersEnabled)),
          const Divider(height: 1),
          SwitchListTile(
              title:
                  const Text('العروض والتحديثات', textAlign: TextAlign.right),
              subtitle: const Text('استقبل آخر العروض والأخبار',
                  textAlign: TextAlign.right),
              value: store.offersEnabled,
              activeTrackColor: AppColors.brand,
              onChanged: (v) => _notify(store.notificationsEnabled, v))
        ])),
        const SizedBox(height: 16),
        const _SectionHeading(title: 'اللغة'),
        AppCard(
            child: ListTile(
                title: const Text('لغة التطبيق', textAlign: TextAlign.right),
                subtitle: Text(store.language, textAlign: TextAlign.right),
                trailing: const Icon(Icons.language),
                onTap: () async {
                  final lang = await showModalBottomSheet<String>(
                      context: context,
                      builder: (_) => SafeArea(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                ListTile(
                                    title: const Text('العربية'),
                                    onTap: () =>
                                        Navigator.pop(context, 'العربية')),
                                ListTile(
                                    title: const Text('English'),
                                    onTap: () =>
                                        Navigator.pop(context, 'English'))
                              ])));
                  if (lang != null) {
                    await store.saveLanguage(lang);
                    setState(() {});
                  }
                })),
        const SizedBox(height: 16),
        const _SectionHeading(title: 'الأمان والدعم'),
        AppCard(
            child: Column(children: [
          ListTile(
              title:
                  const Text('تغيير كلمة المرور', textAlign: TextAlign.right),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const CustomerChangePasswordScreen()))),
          const Divider(height: 1),
          ListTile(
              title: const Text('الخصوصية والدعم', textAlign: TextAlign.right),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                      builder: (_) => const CustomerSupportScreen())))
        ]))
      ]));
}

class CustomerChangePasswordScreen extends StatefulWidget {
  const CustomerChangePasswordScreen({super.key});
  @override
  State<CustomerChangePasswordScreen> createState() =>
      _CustomerChangePasswordScreenState();
}

class _CustomerChangePasswordScreenState
    extends State<CustomerChangePasswordScreen> {
  final a = TextEditingController();
  final b = TextEditingController();
  @override
  void dispose() {
    a.dispose();
    b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('تغيير كلمة المرور'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(children: [
            OwnerPasswordField(label: 'كلمة المرور الجديدة', controller: a),
            const SizedBox(height: 12),
            OwnerPasswordField(label: 'تأكيد كلمة المرور', controller: b)
          ])),
      bottomNavigationBar: OwnerStickyAction(
          keyboardAware: true,
          child: AppButton(
              label: 'حفظ',
              onPressed: () {
                if (a.text.length < 6 || a.text != b.text) {
                  _message(context, 'تحقق من كلمة المرور وتأكيدها.');
                  return;
                }
                _message(context, 'تم تحديث كلمة المرور.');
                Navigator.pop(context);
              })));
}

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('الدعم والخصوصية'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const AppCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Text('كيف يمكننا مساعدتك؟',
                  textAlign: TextAlign.right, style: AppTextStyles.heading),
              SizedBox(height: 8),
              Text('يسعد فريق EV Yemen بمساعدتك في أي استفسار.',
                  textAlign: TextAlign.right, style: AppTextStyles.body)
            ])),
        const SizedBox(height: 14),
        AppCard(
            child: ListTile(
                leading:
                    const Icon(Icons.phone_outlined, color: AppColors.brand),
                title: const Text('اتصل بالدعم'),
                subtitle: const Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('+967 1 234 567')),
                onTap: () =>
                    _message(context, 'سيتم فتح قناة التواصل قريباً.'))),
        const SizedBox(height: 10),
        const AppCard(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              Text('سياسة الخصوصية',
                  textAlign: TextAlign.right, style: AppTextStyles.heading),
              SizedBox(height: 8),
              Text(
                  'نحافظ على بياناتك ونستخدمها لتقديم خدمات EV Yemen وتحسين تجربتك.',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.body)
            ]))
      ]));
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile(
      {required this.name, required this.score, required this.review});
  final String name, score, review;
  @override
  Widget build(BuildContext context) => AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(name, textAlign: TextAlign.right, style: AppTextStyles.bodyMedium),
        Directionality(
            textDirection: TextDirection.ltr,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              const Icon(Icons.star_rounded, color: AppColors.accent, size: 17),
              Text(' $score', style: AppTextStyles.caption)
            ])),
        Text(review, textAlign: TextAlign.right, style: AppTextStyles.body)
      ]));
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.inbox_outlined,
                size: 42, color: AppColors.disabled),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: AppTextStyles.body)
          ])));
}

class _RetryState extends StatelessWidget {
  const _RetryState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, style: AppTextStyles.body),
        TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'))
      ]));
}

void _message(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, textAlign: TextAlign.right)));
