import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  List logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final url = Uri.parse('http://10.0.2.2:3000/api/users/$userId/logs');

    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() => logs = jsonDecode(res.body));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activity Log")),
      body: logs.isEmpty
          ? const Center(child: Text("No logs yet."))
          : ListView.builder(
        itemCount: logs.length,
        itemBuilder: (_, i) {
          final log = logs[i];
          return ListTile(
            title: Text(
              log['cancelled'] == true
                  ? "❌ Cancelled ${log['type'].toString().capitalize()}"
                  : "🧘 ${log['type'].toString().capitalize()} - ${log['fish']?['name'] ?? 'None'}",
            ),
            subtitle: Text(
              log['cancelled'] == true
                  ? "Not completed"
                  : "${log['fish']?['rarity'] ?? 'None'} - ${DateTime.parse(log['timestamp']).toLocal()}",
            ),
          );
        },
      ),
    );
  }
}

// Add this extension to capitalize first letter
extension on String {
  String capitalize() => isEmpty ? this : this[0].toUpperCase() + substring(1);
}
