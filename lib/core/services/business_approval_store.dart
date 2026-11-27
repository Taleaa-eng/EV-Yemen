import 'package:shared_preferences/shared_preferences.dart';

enum BusinessApprovalStatus { pending, approved, rejected }

class BusinessApprovalStore {
  BusinessApprovalStore._();
  static final BusinessApprovalStore instance = BusinessApprovalStore._();

  String _key(String businessKey) => 'ev_yemen.admin_approval.$businessKey.v1';

  Future<BusinessApprovalStatus> statusFor(String businessKey) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key(businessKey));
    // Accounts created before approval tracking retain their prior access.
    return BusinessApprovalStatus.values.firstWhere(
      (status) => status.name == raw,
      orElse: () => BusinessApprovalStatus.approved,
    );
  }

  Future<void> submitForReview(String businessKey) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key(businessKey), 'pending');
  }

  Future<void> setStatus(
      String businessKey, BusinessApprovalStatus status) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key(businessKey), status.name);
  }
}
