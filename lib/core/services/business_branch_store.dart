import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/business_branch.dart';

class BusinessBranchStore extends ChangeNotifier {
  BusinessBranchStore._();
  static final BusinessBranchStore instance = BusinessBranchStore._();

  final Map<String, List<BusinessBranch>> _branchesByBusiness = {};

  List<BusinessBranch> branchesFor(String businessKey) =>
      List.unmodifiable(_branchesByBusiness[businessKey] ?? const []);

  String _key(String businessKey) => 'ev_yemen.branches.$businessKey.v1';

  Future<void> load(String businessKey) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key(businessKey));
    try {
      _branchesByBusiness[businessKey] = raw == null
          ? []
          : (jsonDecode(raw) as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(BusinessBranch.fromJson)
              .toList();
    } catch (_) {
      _branchesByBusiness[businessKey] = [];
    }
    notifyListeners();
  }

  Future<void> save(String businessKey, BusinessBranch branch) async {
    final branches = [...branchesFor(businessKey)];
    branches.add(branch);
    _branchesByBusiness[businessKey] = branches;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _key(businessKey),
      jsonEncode(branches.map((item) => item.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> setApproval(
      String businessKey, String branchId, bool approved) async {
    final branches = [
      for (final branch in branchesFor(businessKey))
        if (branch.id == branchId)
          branch.copyWith(approved: approved)
        else
          branch,
    ];
    _branchesByBusiness[businessKey] = branches;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _key(businessKey),
      jsonEncode(branches.map((item) => item.toJson()).toList()),
    );
    notifyListeners();
  }
}
