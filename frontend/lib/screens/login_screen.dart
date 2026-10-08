import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DairyTrace'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_drink,
                size: 80,
              ),

              const SizedBox(height: 20),

              const Text(
                'Welcome to DairyTrace',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Dairy Cooperative Management System',
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.dashboard,
                    );
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}