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
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Milk Collection',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Record today\'s milk collection.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: _farmerController,
                  decoration: const InputDecoration(
                    labelText: 'Farmer Name',
                    hintText: 'Enter farmer name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the farmer name.';
                    }

                    if (value.trim().length < 2) {
                      return 'Farmer name must be at least 2 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Milk Quantity',
                    hintText: 'Enter quantity',
                    suffixText: 'Litres',
                    prefixIcon: Icon(Icons.water_drop_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the milk quantity.';
                    }

                    final quantity = double.tryParse(value);

                    if (quantity == null) {
                      return 'Please enter a valid number.';
                    }

                    if (quantity <= 0) {
                      return 'Quantity must be greater than 0.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                if (_isLoading)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          ),
                          SizedBox(width: 14),
                          Text('Recording milk collection...'),
                        ],
                      ),
                    ),
                  ),

                if (_errorMessage != null)
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_successMessage != null)
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: TextStyle(
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                if (!_isLoading &&
                    _errorMessage == null &&
                    _successMessage == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No collection recorded yet.',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _submitCollection,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      _isLoading
                          ? 'Saving...'
                          : 'Record Collection',
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _clearForm,
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}