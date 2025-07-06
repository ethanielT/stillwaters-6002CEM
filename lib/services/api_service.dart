import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // For Android emulator

  static Future<String?> registerUser(String username, String password) async {
    final url = Uri.parse('$baseUrl/users');
    final response = await http.post(url, body: jsonEncode({
      'username': username,
      'password': password
    }), headers: {
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return "User created: ${data['username']}";
    } else {
      return "Error: ${response.body}";
    }
  }

  static Future<String?> loginUser(String username, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    final response = await http.post(url, body: jsonEncode({
      'username': username,
      'password': password
    }), headers: {
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', data['userId']);
      await prefs.setString('username', data['username']);
      return "Login successful";
    } else {
      return "Login failed: ${response.body}";
    }
  }

  static Future<Map<String, dynamic>?> catchFish(String userId) async {
    final url = Uri.parse('$baseUrl/users/$userId/catch');

    final response = await http.post(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // contains { message, fish }
    } else {
      return null;
    }
  }

  static Future<void> logExercise(String userId, String type, Map<String, dynamic>? fish, {bool cancelled = false}) async {
    final url = Uri.parse('$baseUrl/users/$userId/log');
    final body = {
      'type': type,
      'cancelled': cancelled,
      if (fish != null) 'fish': fish,
    };

    await http.post(url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
