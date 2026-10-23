import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'form_validators.dart';
import 'models/collection.dart';
import 'services/collection_service.dart';
import 'utils/user_feedback.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Object? initializationError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    initializationError = error;
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(DairyTraceApp(initializationError: initializationError));
}

class FirebaseStartupErrorScreen extends StatelessWidget {
  const FirebaseStartupErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                'Unable to start DairyTrace',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'DairyTrace could not connect to its services. '
                'Please check your internet connection and app '
                'configuration, then restart the app.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    initializationError = error;
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(DairyTraceApp(initializationError: initializationError));
}

class FirebaseStartupErrorScreen extends StatelessWidget {
  const FirebaseStartupErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                'Unable to start DairyTrace',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'DairyTrace could not connect to its services. '
                'Please check your internet connection and app '
                'configuration, then restart the app.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// APP
// --------------------------------------------------

class DairyTraceApp extends StatelessWidget {
  const DairyTraceApp({super.key, this.initializationError});

  final Object? initializationError;

  @override
  Widget build(BuildContext context) {
    const emerald = Color(0xFF008D70);

    return MaterialApp(
      title: 'DairyTrace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: emerald),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7FAF8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF183C32),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: emerald,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: initializationError == null
          ? const AuthGate()
          : const FirebaseStartupErrorScreen(),
    );
  }
}

// --------------------------------------------------
// AUTHENTICATION GATE
// --------------------------------------------------

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.authStateChanges});

  final Stream<User?> Function()? authStateChanges;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = _createAuthStream();
  }

  Stream<User?> _createAuthStream() {
    // Use the injected stream in tests; otherwise use Firebase.
    return widget.authStateChanges?.call() ??
        FirebaseAuth.instance.authStateChanges();
  }

  void _retryAuthentication() {
    setState(() {
      _authStream = _createAuthStream();
    });
  }

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Stream<User?> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = FirebaseAuth.instance.authStateChanges();
  }

  void _retryAuthentication() {
    setState(() {
      _authStream = FirebaseAuth.instance.authStateChanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking your authentication...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 56,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to check your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please check your connection and try again.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _retryAuthentication,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to check your account. Please try again.'),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _retryAuthentication,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
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
  const LoginPage({super.key, this.auth});

  final FirebaseAuth? auth;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final FirebaseAuth _auth = widget.auth ?? FirebaseAuth.instance;

  bool _isRegistering = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _authenticate() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (_isRegistering) {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await _auth.signInWithEmailAndPassword(
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
          _ => 'Authentication failed. Please try again.',
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
                    const Icon(
                      Icons.water_drop,
                      color: Color(0xFF008D70),
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DairyTrace',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF183C32),
                      ),
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
                      validator: validateEmail,
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
                      validator: (value) => validatePassword(
                        value,
                        isRegistering: _isRegistering,
                      ),
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
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isRegistering ? 'Register' : 'Sign In'),
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

// -------------------- SPLASH SCREEN --------------------
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MilkCollectionPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF006B54), Color(0xFF23A581)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop,
                  size: 58,
                  color: Color(0xFF008D70),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'DairyTrace',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tracking every drop from farm to table',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 42),
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              const Text('Loading...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- MILK COLLECTION --------------------
// --------------------------------------------------
// MILK COLLECTION PAGE
// --------------------------------------------------

class MilkCollectionPage extends StatefulWidget {
  const MilkCollectionPage({super.key, this.collectionService, this.auth});

  final CollectionService? collectionService;
  final FirebaseAuth? auth;

  @override
  State<MilkCollectionPage> createState() => _MilkCollectionPageState();
}

class _MilkCollectionPageState extends State<MilkCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _farmerController = TextEditingController();
  final _quantityController = TextEditingController();
  final _collectionService = CollectionService();
  late Stream<QuerySnapshot<Map<String, dynamic>>> _collectionsStream;

  late final CollectionService _collectionService =
      widget.collectionService ?? CollectionService();
  late final FirebaseAuth _auth = widget.auth ?? FirebaseAuth.instance;

  late Stream<List<Collection>> _collectionsStream;

  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  final _searchController = TextEditingController();


  @override
  void dispose() {
    _farmerController.dispose();
    _quantityController.dispose();
    _searchController.dispose();
    super.dispose();

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

  void _refreshCollections() {
    _collectionsStream = _createCollectionsStream();
  }

  @override
  void initState() {
    super.initState();
    _refreshCollections();
  }

  void _refreshCollections() {
    _collectionsStream = _collectionService.watchCollections();
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
        farmerName: _farmerController.text.trim(),
        quantityLitres: double.parse(_quantityController.text.trim()),
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
      UserFeedback.showSuccess(
        context,
        message: 'Collection saved successfully!',
      );
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Firestore save error: ${error.code} ${error.message}');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      final message = error.code == 'permission-denied'
          ? 'Access denied. Check your Firestore security rules.'
          : 'Could not save the collection. Please try again.';
      setState(() => _errorMessage = message);
      UserFeedback.showError(context, message: message);
    } catch (error, stackTrace) {
      debugPrint('Collection save error: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      final message = error is ArgumentError || error is StateError
          ? error.toString()
          : 'Could not save the collection. Please try again.';
      setState(() => _errorMessage = message);
      UserFeedback.showError(context, message: message);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteCollection(Collection collection) async {
    final confirmed = await UserFeedback.confirm(
      context,
      title: 'Delete collection?',
      message:
          'Delete the collection for ${collection.farmerName}? This action cannot be undone.',
      confirmText: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await _collectionService.deleteCollection(collectionId: collection.id);
      if (!mounted) return;
      UserFeedback.showSuccess(
        context,
        message: 'Collection deleted successfully.',
      );
    } on FirebaseException catch (error, stackTrace) {
      debugPrint('Firestore delete error: ${error.code} ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      UserFeedback.showError(
        context,
        message: error.code == 'permission-denied'
            ? 'Access denied. You cannot delete this collection.'
            : 'Could not delete the collection. Please try again.',
      );
    } catch (error, stackTrace) {
      debugPrint('Collection delete error: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      UserFeedback.showError(
        context,
        message: 'Could not delete the collection. Please try again.',
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      debugPrint('Sign-out error: $error');

      if (!mounted) return;

      UserFeedback.showError(
        context,
        message: 'Unable to sign out. Please try again.',
      );
    }
  }

  @override
  void dispose() {
    _farmerController.dispose();
    _quantityController.dispose();
    _searchController.dispose();
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
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (error) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Unable to sign out. Please try again.'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.logout_rounded),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'New Collection',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF183C32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Record today's milk collection.",
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          return 'Enter at least 2 characters.';
                        }

                        if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(name)) {
                          return 'Use letters and spaces only.';
                        }

                        return null;
                      },
                      validator: validateFarmerName,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      enabled: !_isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
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

                        final quantity = double.tryParse(value.trim());

                        if (quantity == null ||
                            !quantity.isFinite ||
                            quantity <= 0) {
                          return 'Enter a valid quantity greater than 0.';
                        }

                        return null;
                      },
                      validator: validateMilkQuantity,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _submitCollection,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          _isSaving ? 'Saving...' : 'Save Collection',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                _StatusMessage(
                  message: _errorMessage!,
                  color: Colors.red,
                  icon: Icons.error_outline,
                ),
              ],
              if (_successMessage != null) ...[
                const SizedBox(height: 16),
                _StatusMessage(
                  message: _successMessage!,
                  color: const Color(0xFF008D70),
                  icon: Icons.check_circle_outline,
                ),
              ],
              const SizedBox(height: 32),
              const Text(
                'Recent Collections',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF183C32),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search farmer...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF008D70),
                    ),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
SizedBox(
  height: 48,
  child: TextField(
    controller: _searchController,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      hintText: 'Search farmer...',
      prefixIcon: const Icon(
        Icons.search,
        color: Color(0xFF008D70),
      ),
      suffixIcon: _searchController.text.isEmpty
          ? null
          : IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    ),
  ),
),
const SizedBox(height: 12),
_buildCollectionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _collectionsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;

          final isPermissionDenied =
            error is FirebaseException && error.code == 'permission-denied';

          final errorTitle = isPermissionDenied
            ? 'Access denied'
            : 'Unable to load collections';

          final errorDescription = isPermissionDenied
            ? 'You do not have permission to view these collections. '
              'Please check your account access or contact your administrator.'
            : 'Check your internet connection, then try again.';
    return StreamBuilder<List<Collection>>(
      stream: _collectionsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Collection list error: ${snapshot.error}');

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 40,
                    color: Colors.red,
                  ),
                  Text(
                    errorTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Unable to load collections. Check your connection and try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(_refreshCollections);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Loading collections...'),
                ],
              ),
            ),
          );
        }

        final collections = snapshot.data ?? <Collection>[];
        final query = _searchController.text.trim().toLowerCase();
        final filteredCollections = collections
            .where(
              (collection) =>
                  collection.farmerName.toLowerCase().contains(query),
            )
            .toList();

        if (filteredCollections.isEmpty) {
          final isSearching = query.isNotEmpty;
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Loading collections...'),
                  Icon(
                    isSearching ? Icons.search_off : Icons.inbox_outlined,
                    size: 44,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isSearching
                        ? 'No matching collections found.'
                        : 'No collections yet. Record your first collection.',
                    textAlign: TextAlign.center,
                  ),
                  if (isSearching)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                      child: const Text('Clear search'),
                    ),
                ],
              ),
            ),
          );
        }

        final documents = (snapshot.data?.docs ?? []).where((document) {
          final farmerName =
            (document.data()['farmerName'] as String? ?? '').toLowerCase();

          return farmerName.contains(_searchController.text.trim().toLowerCase());
        }).toList();

        if (documents.isEmpty) {
  final isSearching = _searchController.text.trim().isNotEmpty;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.inbox_outlined,
            size: 44,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'No matching collections found.'
                : 'No collections yet. Record your first collection.',
            textAlign: TextAlign.center,
          ),
          if (isSearching)
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Text('Clear search'),
            ),
        ],
      ),
    ),
  );
}

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredCollections.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final collection = filteredCollections[index];
            final date = collection.collectionDate;

            final dateText = date == null
                ? 'Date pending'
                : date.toLocal().toString().substring(0, 16);

            return Card(
              color: Colors.white,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.water_drop, color: Colors.green.shade800),
                ),
                title: Text(collection.farmerName),
                subtitle: Text(dateText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${collection.quantityLitres.toStringAsFixed(2)} L',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete collection',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteCollection(collection),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.message,
    required this.color,
    required this.icon,
  });

  final String message;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
