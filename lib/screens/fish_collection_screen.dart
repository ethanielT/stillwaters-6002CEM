import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FishCollectionScreen extends StatefulWidget {
  const FishCollectionScreen({super.key});

  @override
  State<FishCollectionScreen> createState() => _FishCollectionScreenState();
}

class _FishCollectionScreenState extends State<FishCollectionScreen> {
  Map<String, List<dynamic>> collection = {};

  @override
  void initState() {
    super.initState();
    _fetchCollection();
  }

  Future<void> _fetchCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final url = Uri.parse('http://10.0.2.2:3000/api/users/$userId/collection');

    final res = await http.get(url);
    if (res.statusCode == 200) {
      setState(() {
        collection = Map<String, List<dynamic>>.from(jsonDecode(res.body));
      });
    }
  }

  Color _rarityColor(String rarity) {
    switch (rarity) {
      case 'legendary':
        return Colors.orange;
      case 'rare':
        return Colors.deepPurpleAccent.shade100;
      case 'uncommon':
        return Colors.green.shade400;
      case 'common':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fish Collection")),
      body: collection.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: collection.entries.map((entry) {
          final rarity = entry.key;
          final fishList = entry.value;

          return ExpansionTile(
            title: Text(
              rarity.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _rarityColor(rarity),
              ),
            ),
            children: fishList.map((fish) {
              final caught = fish['count'] > 0;
              return ListTile(
                leading: Icon(
                  Icons.abc,
                  color: caught ? _rarityColor(rarity) : Colors.grey.shade400,
                ),
                title: Text(
                  fish['name'],
                  style: TextStyle(
                    color: caught ? _rarityColor(rarity) : Colors.grey,
                  ),
                ),
                trailing: caught
                    ? Text("x${fish['count']}")
                    : const Text("Not caught", style: TextStyle(color: Colors.grey)),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
