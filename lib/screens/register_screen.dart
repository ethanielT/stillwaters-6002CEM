import 'package:flutter/material.dart';
import 'package:stillwaters/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  String message = '';

  void register() async {
    final res = await ApiService.registerUser(
      usernameController.text,
      passwordController.text,
    );

    if (res != null && res.startsWith("User created")) {
      // Show success and return to LoginScreen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful! Please log in.')),
        );
        Navigator.pop(context); // Back to login screen
      }
    } else {
      setState(() {
        message = res ?? "Registration failed";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: usernameController, decoration: const InputDecoration(labelText: "Username")),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: register, child: const Text('Register')),
            const SizedBox(height: 10),
            Text(message),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Go back to LoginScreen
              },
              child: const Text("Already have an account? Login"),
            )

          ],
        ),
      ),
    );
  }
}
