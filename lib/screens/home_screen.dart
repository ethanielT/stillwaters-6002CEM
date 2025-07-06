import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'breathing_screen.dart';
import 'meditation_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _completeExercise(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found. Please login again.')),
      );
      return;
    }

    Future<void> afterExercise() async {
      final result = await ApiService.catchFish(userId);

      if (result != null && mounted) {
        final fish = result['fish'];

        await ApiService.logExercise(userId, type, fish);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("🐟 You caught a fish!"),
            content: Text("🎉 ${fish['name']} (${fish['rarity']})"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Nice!"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to catch fish. Please try again.")),
        );
      }
    }

    Future<void> onCancel() async {
      await ApiService.logExercise(userId, type, null, cancelled: true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$type cancelled")),
      );
    }

    final screen = (type == 'meditation')
        ? MeditationScreen(onComplete: afterExercise, onCancel: onCancel)
        : BreathingScreen(onComplete: afterExercise, onCancel: onCancel);

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Still Waters"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Welcome, ${widget.username}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completeExercise('meditation'),
              child: const Text("Meditation"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _completeExercise('breathing'),
              child: const Text("Breathing Exercise"),
            ),
          ],
        ),
      ),
    );
  }
}
