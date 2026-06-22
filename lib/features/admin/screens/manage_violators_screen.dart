import 'package:flutter/material.dart';

import '../data/admin_api.dart';
import '../widgets/admin_account_card.dart';

class ManageViolatorsScreen extends StatefulWidget {
  const ManageViolatorsScreen({super.key});

  @override
  State<ManageViolatorsScreen> createState() => _ManageViolatorsScreenState();
}

class _ManageViolatorsScreenState extends State<ManageViolatorsScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> violators = [];
  static const Color darkGreen = Color(0xFF008000);

  @override
  void initState() {
    super.initState();
    loadViolators();
  }

  Future<void> loadViolators() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final result = await AdminApi.getViolatorUsers();
      if (!mounted) return;
      setState(() { violators = AdminApi.dataAsList(result); isLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { errorMessage = 'Failed to load violator users: $e'; isLoading = false; });
    }
  }

  Future<void> sendNotice(Map<String, dynamic> user) async {
    final userId = AdminApi.asInt(user['UserId']);
    final name = AdminApi.asString(user['Fullname'], fallback: 'this user');
    final controller = TextEditingController(text: 'Your account has received a community guideline notice. Please review your posts and avoid repeated violations.');

    final notice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send notice to $name'),
        content: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(labelText: 'Login notice', border: OutlineInputBorder())),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Send')),
        ],
      ),
    );

    if (notice == null || notice.isEmpty) return;
    final result = await AdminApi.setLoginNotice(userId: userId, notice: notice);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['success'] == true ? 'Notice saved.' : 'Failed to save notice.'), backgroundColor: result['success'] == true ? darkGreen : Colors.red),
    );
  }

  Future<void> addViolation(Map<String, dynamic> user) async {
    final userId = AdminApi.asInt(user['UserId']);
    final name = AdminApi.asString(user['Fullname'], fallback: 'this user');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add violation?'),
        content: Text('This will increase $name\'s violation count. If the user reaches 5 violations, the backend may deactivate the account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add Violation')),
        ],
      ),
    );

    if (confirmed != true) return;
    final result = await AdminApi.incrementUserViolation(userId: userId);
    final total = AdminApi.dataAsInt(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Violation updated. Total violations: $total'), backgroundColor: darkGreen));
    await loadViolators();
  }

  Widget buildTrailing(Map<String, dynamic> user) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'notice') sendNotice(user);
        if (value == 'violation') addViolation(user);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'notice', child: Text('Send login notice')),
        PopupMenuItem(value: 'violation', child: Text('Add violation')),
      ],
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
        title: const Text('Violator Users', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: loadViolators, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: RefreshIndicator(
        onRefresh: loadViolators,
        color: darkGreen,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('${violators.length} violator user(s)', style: const TextStyle(color: darkGreen, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 16),
            if (isLoading)
              const Padding(padding: EdgeInsets.only(top: 80), child: Center(child: CircularProgressIndicator(color: darkGreen)))
            else if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red))
            else if (violators.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.only(top: 80), child: Text('No active violators found.')))
            else
              ...violators.map((user) => AdminAccountCard(
                name: AdminApi.asString(user['Fullname']),
                email: AdminApi.asString(user['Email']),
                subtitle: '${AdminApi.asInt(user['ViolationCount'])} violation(s)',
                leadingIcon: Icons.warning_rounded,
                trailing: buildTrailing(user),
              )),
          ],
        ),
      ),
    );
  }
}
