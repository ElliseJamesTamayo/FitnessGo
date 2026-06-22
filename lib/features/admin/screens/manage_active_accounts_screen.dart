import 'package:flutter/material.dart';

import '../data/admin_api.dart';
import '../widgets/admin_account_card.dart';

class ManageActiveAccountsScreen extends StatefulWidget {
  const ManageActiveAccountsScreen({super.key});

  @override
  State<ManageActiveAccountsScreen> createState() => _ManageActiveAccountsScreenState();
}

class _ManageActiveAccountsScreenState extends State<ManageActiveAccountsScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> accounts = [];
  static const Color darkGreen = Color(0xFF008000);

  @override
  void initState() {
    super.initState();
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await AdminApi.getActiveAccounts();
      if (!mounted) return;
      setState(() { accounts = AdminApi.dataAsList(result); isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { errorMessage = 'Failed to load active accounts: $e'; isLoading = false; });
    }
  }

  String formatLastLogin(dynamic value) {
    final text = AdminApi.asString(value, fallback: 'No last login');
    return text.isEmpty ? 'No last login' : 'Last login: $text';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FBF6),
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text('Active Accounts', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: loadAccounts, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: RefreshIndicator(
        onRefresh: loadAccounts,
        color: darkGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('${accounts.length} active account(s)', style: const TextStyle(color: darkGreen, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            if (isLoading)
              const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator(color: darkGreen)))
            else if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red))
            else if (accounts.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.only(top: 80), child: Text('No active accounts found.')))
            else
              ...accounts.map((account) => AdminAccountCard(
                name: AdminApi.asString(account['Fullname']),
                email: AdminApi.asString(account['Email']),
                subtitle: formatLastLogin(account['LastLogin']),
                leadingIcon: Icons.verified_user_rounded,
              )),
          ],
        ),
      ),
    );
  }
}
