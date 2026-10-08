import 'package:flutter/material.dart';

void main() {
  runApp(const DairyTraceApp());
}

class DairyTraceApp extends StatelessWidget {
  const DairyTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DairyTrace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const MilkCollectionPage(),
    );
  }
}

class MilkCollectionPage extends StatefulWidget {
  const MilkCollectionPage({super.key});

  @override
  State<MilkCollectionPage> createState() => _MilkCollectionPageState();
}

class _MilkCollectionPageState extends State<MilkCollectionPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _farmerController =
      TextEditingController();

  final TextEditingController _quantityController =
      TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _farmerController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _submitCollection() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = 'Please correct the highlighted fields.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulating a submission request.
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _successMessage =
          'Milk collection recorded successfully.';
      _farmerController.clear();
      _quantityController.clear();
    });
  }

  void _clearForm() {
    setState(() {
      _farmerController.clear();
      _quantityController.clear();
      _errorMessage = null;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DairyTrace'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Milk Collection',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Record today’s milk collection',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _farmerController,
                decoration: const InputDecoration(
                  labelText: 'Farmer Name',
                  hintText: 'Enter farmer name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Farmer name is required';
                  }

                  if (value.trim().length < 2) {
                    return 'Farmer name must be at least 2 characters';
                  }

                  if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
                    return 'Farmer name can contain only letters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Milk Quantity (Litres)',
                  hintText: 'Enter quantity',
                  prefixIcon: Icon(Icons.water_drop),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Milk quantity is required';
                  }

                  final quantity = double.tryParse(value.trim());

                  if (quantity == null) {
                    return 'Enter a valid number';
                  }

                  if (quantity <= 0) {
                    return 'Quantity must be greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                    ),
                  ),
                ),

              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _successMessage!,
                    style: TextStyle(
                      color: Colors.green.shade700,
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              FilledButton(
                onPressed: _isLoading ? null : _submitCollection,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Record Collection'),
              ),

              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: _isLoading ? null : _clearForm,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}