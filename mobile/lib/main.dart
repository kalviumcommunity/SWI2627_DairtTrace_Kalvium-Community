import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/collection.dart';
import 'services/collection_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const DairyTraceApp());
}

// --------------------------------------------------
// APP
// --------------------------------------------------

class DairyTraceApp extends StatelessWidget {
  const DairyTraceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DairyTrace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9F7),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// --------------------------------------------------
// AUTHENTICATION GATE
// --------------------------------------------------

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Unable to check your account. Please try again.'),
            ),
          );
        }

        if (snapshot.hasData) {
          return const SplashScreen();
        }

        return const LoginPage();
      },
    );
  }
}

// --------------------------------------------------
// LOGIN AND REGISTRATION
// --------------------------------------------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isRegistering) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = switch (error.code) {
          'invalid-email' => 'Please enter a valid email address.',
          'user-not-found' ||
          'wrong-password' ||
          'invalid-credential' => 'Email or password is incorrect.',
          'email-already-in-use' => 'This email is already registered.',
          'weak-password' => 'Choose a stronger password.',
          'network-request-failed' => 'Check your internet connection.',
          'too-many-requests' => 'Too many attempts. Please try again later.',
          _ => error.message ?? 'Authentication failed.',
        };
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });

      debugPrint('Authentication error: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.water_drop, size: 76, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      'DairyTrace',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRegistering
                          ? 'Create your account'
                          : 'Sign in to manage milk collections',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (email.isEmpty) {
                          return 'Email is required.';
                        }

                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        final password = value ?? '';

                        if (password.isEmpty) {
                          return 'Password is required.';
                        }

                        if (_isRegistering && password.length < 6) {
                          return 'Password must be at least 6 characters.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton(
                      onPressed: _isLoading ? null : _authenticate,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isRegistering ? 'Create Account' : 'Sign In',
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _isRegistering = !_isRegistering;
                                _errorMessage = null;
                              });
                            },
                      child: Text(
                        _isRegistering
                            ? 'Already have an account? Sign in'
                            : 'New user? Create an account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// SPLASH SCREEN
// --------------------------------------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MilkCollectionPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'DairyTrace',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// MILK COLLECTION PAGE
// --------------------------------------------------

class MilkCollectionPage extends StatefulWidget {
  const MilkCollectionPage({super.key});

  @override
  State<MilkCollectionPage> createState() => _MilkCollectionPageState();
}

class _MilkCollectionPageState extends State<MilkCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _farmerController = TextEditingController();
  final _quantityController = TextEditingController();

  final CollectionService _collectionService = CollectionService();

  late final Stream<List<Collection>> _collectionsStream;

  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();

    _collectionsStream = _createCollectionsStream();
  }

  Stream<List<Collection>> _createCollectionsStream() {
    try {
      return _collectionService.watchCollections();
    } catch (error, stackTrace) {
      debugPrint('Collection stream setup error: $error');
      debugPrintStack(stackTrace: stackTrace);

      return Stream<List<Collection>>.error(error, stackTrace);
    }
  }

  Future<void> _submitCollection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final farmerName = _farmerController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim());

    if (quantity == null || !quantity.isFinite || quantity <= 0) {
      setState(() {
        _errorMessage = 'Enter a valid quantity greater than zero.';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _collectionService.addCollection(
        farmerName: farmerName,
        quantityLitres: quantity,
      );

      if (!mounted) return;

      _farmerController.clear();
      _quantityController.clear();
      _formKey.currentState?.reset();

      setState(() {
        _successMessage = 'Collection saved successfully!';
      });
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Firestore save error: ${error.code} ${error.message}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage = error.code == 'permission-denied'
            ? 'Access denied. Check your Firestore security rules.'
            : 'Could not save the collection. Please try again.';
      });
    } catch (error, stackTrace) {
      debugPrint('Collection save error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _errorMessage = error is ArgumentError || error is StateError
            ? error.toString()
            : 'Could not save the collection. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      debugPrint('Sign-out error: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign out. Please try again.')),
      );
    }
  }

  @override
  void dispose() {
    _farmerController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'DairyTrace',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Record Milk Collection',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _farmerController,
                                  enabled: !_isSaving,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: const InputDecoration(
                                    labelText: 'Farmer Name',
                                    hintText: 'Enter farmer name',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    final name = value?.trim() ?? '';

                                    if (name.isEmpty) {
                                      return 'Farmer name is required.';
                                    }

                                    if (name.length < 2) {
                                      return 'Farmer name must be at least 2 characters.';
                                    }

                                    if (!RegExp(r'^[a-zA-Z ]+$')
                                        .hasMatch(name)) {
                                      return 'Use letters and spaces only.';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _quantityController,
                                  enabled: !_isSaving,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Milk Quantity',
                                    hintText: 'Enter quantity',
                                    suffixText: 'Litres',
                                    prefixIcon: Icon(Icons.water_drop_outlined),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Milk quantity is required.';
                                    }

                                    final quantity = double.tryParse(
                                      value.trim(),
                                    );

                                    if (quantity == null ||
                                        !quantity.isFinite ||
                                        quantity <= 0) {
                                      return 'Enter a valid quantity greater than 0.';
                                    }

                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                if (_errorMessage != null) ...[
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (_successMessage != null) ...[
                                  Text(
                                    _successMessage!,
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: _isSaving
                                        ? null
                                        : _submitCollection,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.save_outlined),
                                    label: Text(
                                      _isSaving
                                          ? 'Saving...'
                                          : 'Save Collection',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Recent Collections',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildCollectionList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionList() {
    return StreamBuilder<List<Collection>>(
      stream: _collectionsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Collection list error: ${snapshot.error}');

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Unable to load collections.\n${snapshot.error}'),
              child: const Text(
                'Unable to load collections. Check your connection and try again.',
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final collections = snapshot.data ?? [];

        if (collections.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 44, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No collections yet. Record your first collection.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: collections.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final collection = collections[index];
            final date = collection.collectionDate;

            final dateText = date == null
                ? 'Date pending'
                : date.toLocal().toString().substring(0, 16);

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.water_drop, color: Colors.green.shade800),
                ),
                title: Text(collection.farmerName),
                subtitle: Text(dateText),
                trailing: Text(
                  '${collection.quantityLitres.toStringAsFixed(2)} L',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
