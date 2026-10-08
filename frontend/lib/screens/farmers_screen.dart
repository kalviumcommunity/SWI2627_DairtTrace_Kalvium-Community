import 'package:flutter/material.dart';

class FarmersScreen extends StatelessWidget {
  const FarmersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmers'),
      ),
      body: const Center(
        child: Text(
          'Farmers',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}