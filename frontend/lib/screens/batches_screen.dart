import 'package:flutter/material.dart';

class BatchesScreen extends StatelessWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batches'),
      ),
      body: const Center(
        child: Text(
          'Milk Batches',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}