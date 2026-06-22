import 'package:flutter/material.dart';

import '../data/admin_api.dart';
import '../widgets/admin_stat_card.dart';
import 'manage_active_accounts_screen.dart';
import 'manage_deactivated_accounts_screen.dart';
import 'manage_violators_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const routeName = '/admin-dashboard';

  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool isLoading = true;
  String? errorMessage;
  int activeFeedwallUsersToday = 0;
  int activeAccounts = 0;
  int violators = 0;
  int deactivatedAccounts = 0;

  static const Color green = Color(0xFF00A000);
  static const Color darkGreen = Color(0xFF008000);

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final feedwallResult = await AdminApi.getActiveFeedwallUsersToday();
      final activeResult = await AdminApi.getActiveAccounts();
      final violatorResult = await AdminApi.getViolatorUsers();
      final deactivatedResult = await AdminApi.getDeactivatedAccounts();

      if (!mounted) return;
      setState(() {
        activeFeedwallUsersToday = AdminApi.dataAsInt(feedwallResult);
        activeAccounts = AdminApi.dataAsList(activeResult).length;
        violators = AdminApi.dataAsList(violatorResult).length;
        deactivatedAccounts = AdminApi.dataAsList(deactivatedResult).length;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Failed to load admin dashboard: $e';
        isLoading = false;
      });
    }
  }

  void openScreen(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> runAutoDeactivate() async {
    try {
      final result = await AdminApi.autoDeactivateInactiveAccounts();
      final rowCount = AdminApi.asInt(result['rowcount']);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auto-deactivation complete. $rowCount account(s) updated.'), backgroundColor: darkGreen),
      );
      await loadDashboard();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Auto-deactivation failed: $e'), backgroundColor: Colors.red));
    }
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: green,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: green.withOpacity(0.22), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: const Row(
        children: [
          Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 44),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Manage accounts and review user activity.', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: runAutoDeactivate,
        icon: const Icon(Icons.auto_fix_high_rounded),
        label: const Text('Auto-deactivate inactive accounts', style: TextStyle(fontWeight: FontWeight.w900)),
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FBF6),
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('FitnessGo Admin', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: loadDashboard, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: RefreshIndicator(
        onRefresh: loadDashboard,
        color: darkGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
          children: [
            buildHeader(),
            const SizedBox(height: 20),
            if (isLoading)
              const Padding(padding: EdgeInsets.only(top: 60), child: Center(child: CircularProgressIndicator(color: darkGreen)))
            else if (errorMessage != null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w800)),
              )
            else ...[
              AdminStatCard(title: 'Active Feedwall Users Today', value: '$activeFeedwallUsersToday', icon: Icons.dynamic_feed_rounded),
              const SizedBox(height: 12),
              AdminStatCard(title: 'Active Accounts', value: '$activeAccounts', icon: Icons.verified_user_rounded, onTap: () => openScreen(const ManageActiveAccountsScreen())),
              const SizedBox(height: 12),
              AdminStatCard(title: 'Violator Users', value: '$violators', icon: Icons.warning_rounded, onTap: () => openScreen(const ManageViolatorsScreen())),
              const SizedBox(height: 12),
              AdminStatCard(title: 'Deactivated Accounts', value: '$deactivatedAccounts', icon: Icons.person_off_rounded, onTap: () => openScreen(const ManageDeactivatedAccountsScreen())),
              const SizedBox(height: 22),
              buildActionButton(),
            ],
          ],
        ),
      ),
    );
  }
}

