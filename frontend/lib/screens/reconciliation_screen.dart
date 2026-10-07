import 'package:flutter/material.dart';

class ReconciliationScreen extends StatelessWidget {
  const ReconciliationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation'),
      ),
      body: const Center(
        child: Text(
          'Monthly Reconciliation',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}