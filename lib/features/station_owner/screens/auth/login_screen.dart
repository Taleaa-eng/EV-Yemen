import 'package:flutter/material.dart';
import '../../../../core/services/auth_validators.dart';
import '../../../../core/services/active_role_session.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/owner_widgets.dart';
import '../../services/station_owner_local_store.dart';
import '../application/status_screen.dart';
import '../dashboard/owner_home_screen.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.store});
  final StationOwnerLocalStore? store;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool submitted = false;
  bool busy = false;
  bool invalidCredentials = false;
  bool invalidIdentifier = false;
  bool invalidPassword = false;
  late final Future<void> _storeReady;
  StationOwnerLocalStore get store =>
      widget.store ?? StationOwnerLocalStore.instance;

  @override
  void initState() {
    super.initState();
    _storeReady = store.initialize();
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('تسجيل الدخول'),
          actions: [OwnerBackAction(onPressed: () => Navigator.pop(context))],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(submitted ? 'تعذّر تسجيل الدخول' : 'مرحباً بعودتك',
                textAlign: TextAlign.right, style: AppTextStyles.h1),
            const SizedBox(height: 12),
            Text(
                submitted
                    ? 'تحقق من البيانات المدخلة ثم حاول مرة أخرى.'
                    : 'أدخل بيانات حساب صاحب المحطة للمتابعة.',
                textAlign: TextAlign.right,
                style: AppTextStyles.body),
            const SizedBox(height: 12),
            CustomLabeledTextField(
                label: 'البريد الإلكتروني أو رقم الهاتف',
                hint: 'ahmed.alqahtani@mail.ye',
                helperText:
                    submitted ? null : 'أدخل بريدك الإلكتروني أو رقم هاتفك.',
                controller: email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {
                      invalidCredentials = false;
                      invalidIdentifier = false;
                    }),
                errorText: submitted && email.text.trim().isEmpty
                    ? 'أدخل بريدك الإلكتروني أو رقم هاتفك'
                    : submitted && invalidIdentifier
                        ? 'أدخل بريداً إلكترونياً أو رقم هاتف صالحاً'
                        : submitted && invalidCredentials
                            ? 'بيانات الدخول غير صحيحة'
                            : null),
            const SizedBox(height: 12),
            OwnerPasswordField(
                label: 'كلمة المرور',
                hint: 'أدخل كلمة المرور',
                helperText:
                    submitted ? null : 'أدخل كلمة المرور الخاصة بحسابك.',
                controller: password,
                onChanged: (_) => setState(() {
                      invalidCredentials = false;
                      invalidPassword = false;
                    }),
                errorText: submitted && password.text.isEmpty
                    ? 'أدخل كلمة المرور'
                    : submitted && invalidPassword
                        ? 'كلمة المرور يجب أن تتكون من 8 أحرف على الأقل'
                        : submitted && invalidCredentials
                            ? 'بيانات الدخول غير صحيحة'
                            : null),
            const SizedBox(height: 16),
            OwnerButton(
                label: 'إنشاء حساب جديد',
                outlined: true,
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RegistrationScreen(store: store)))),
          ]),
        ),
        bottomNavigationBar: OwnerStickyAction(
          keyboardAware: true,
          child: OwnerButton(
            label: busy ? 'جارٍ التحقق...' : 'تسجيل الدخول',
            onPressed: busy ? null : _login,
          ),
        ),
      );

  Future<void> _login() async {
    setState(() {
      submitted = true;
      invalidCredentials = false;
      invalidIdentifier = false;
      invalidPassword = false;
    });
    final identifier = email.text.trim();
    if (identifier.isEmpty || password.text.isEmpty) return;
    final validIdentifier =
        isValidEmail(identifier) || isValidYemenPhone(identifier);
    final validPassword = isValidPassword(password.text);
    if (!validIdentifier || !validPassword) {
      setState(() {
        invalidIdentifier = !validIdentifier;
        invalidPassword = !validPassword;
      });
      return;
    }
    await _storeReady;
    if (!mounted) return;
    setState(() => busy = true);
    final success = await store.login(email.text, password.text);
    if (!mounted) return;
    setState(() => busy = false);
    if (success && store.currentAccount?.approved != true) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                const StatusScreen(status: ApplicationStatus.pending)),
      );
      return;
    }
    if (success) {
      await ActiveRoleSessionStore.instance
          .save(ActiveUserRole.stationOwner, authenticated: true);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OwnerHome(store: store)),
        (route) => false,
      );
    } else {
      setState(() {
        submitted = true;
        invalidCredentials = true;
      });
    }
  }
}
