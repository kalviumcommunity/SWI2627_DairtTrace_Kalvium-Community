import 'demo_backend.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'app_shell.dart';
import 'widgets/brand.dart';
import 'widgets/app_theme.dart';
import 'form_validators.dart';
import 'models/collection.dart';
import 'screens/directory_page.dart';
import 'services/collection_service.dart';
import 'utils/user_feedback.dart';
import 'utils/quality_checker.dart';

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

// --------------------------------------------------
// APP
// --------------------------------------------------

class DairyTraceApp extends StatelessWidget {
  const DairyTraceApp({super.key, this.initializationError});

  final Object? initializationError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DairyTrace',
      debugShowCheckedModeBanner: false,
      theme: dairyTheme(),
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
  const AuthGate({super.key, this.authStateChanges});

  final Stream<User?> Function()? authStateChanges;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Stream<User?> _authStream;
  bool _hadUser = false;

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
              ),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          _hadUser = true;
          return const SplashScreen();
        }
        if (_hadUser) {
          _hadUser = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
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
  bool _showPassword = false;
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
                    const Center(child: DairyBrand(size: 100)),
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
                          : 'Trace · Trust · Together',
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
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_isLoading,
                      obscureText: !_showPassword,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _showPassword
                              ? 'Hide password'
                              : 'Show password',
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) => validatePassword(
                        value,
                        isRegistering: _isRegistering,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_isRegistering)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final email = _emailController.text.trim();
                                  if (validateEmail(email) != null) {
                                    UserFeedback.showError(
                                      context,
                                      message:
                                          'Enter your email address first.',
                                    );
                                    return;
                                  }
                                  try {
                                    await _auth.sendPasswordResetEmail(
                                      email: email,
                                    );
                                    if (context.mounted) {
                                      UserFeedback.showInfo(
                                        context,
                                        message: 'If an account exists, reset instructions will be sent.',
                                      );
                                    }
                                  } catch (_) {
                                    if (context.mounted) {
                                      UserFeedback.showError(
                                        context,
                                        message: 'Unable to request reset. Please try again.',
                                      );
                                    }
                                  }
                                },
                          child: const Text('Forgot Password?'),
                        ),
                      ),
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
                    const SizedBox(height: 12),
                    TextButton.icon(
                      icon: const Icon(Icons.science_outlined),
                      label: const Text('Explore sample app'),
                      onPressed: _isLoading
                          ? null
                          : () async {
                              await AppBackend.startDemo();
                              if (!context.mounted) {
                                AppBackend.closeDemo();
                                return;
                              }
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const DemoAppPage(),
                                ),
                              );
                              AppBackend.closeDemo();
                            },
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: const FarmLandscape(height: 110),
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
  bool ready = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (ready) {
      return DairyTraceShell(
        onNewCollection: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const NewCollectionPage()),
        ),
      );
    }
    return const Scaffold(
      backgroundColor: Color(0xFFF2FAF5),
      body: SafeArea(
        child: Column(
          children: [
            Spacer(),
            DairyBrand(size: 125),
            SizedBox(height: 12),
            Text(
              'DairyTrace',
              style: TextStyle(
                fontSize: 36,
                color: Color(0xFF006B50),
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Trace · Trust · Together',
              style: TextStyle(color: Color(0xFF006B50)),
            ),
            Spacer(),
            FarmLandscape(height: 240),
            SizedBox(height: 24),
            Text('Building a transparent dairy supply chain'),
            SizedBox(height: 16),
            Text('Loading...'),
            SizedBox(height: 24),
          ],
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
  final _fatController = TextEditingController();
  final _snfController = TextEditingController();
  final _temperatureController = TextEditingController();
  String? _qualityAlert;
  late final CollectionService _collectionService =
      widget.collectionService ?? CollectionService();
  late final FirebaseAuth _auth = widget.auth ?? FirebaseAuth.instance;

  late Stream<List<Collection>> _collectionsStream;

  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  final _searchController = TextEditingController();

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

  Future<void> _submitCollection() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fat = double.parse(_fatController.text.trim());
    final snf = double.parse(_snfController.text.trim());
    final temperature = double.parse(_temperatureController.text.trim());
    final quality = QualityChecker.check(
      fat: fat,
      snf: snf,
      temperature: temperature,
    );
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
      _qualityAlert = null;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _collectionService.addCollection(
        farmerName: farmerName,
        quantityLitres: quantity,
        fat: fat,
        snf: snf,
        temperature: temperature,
      );

      if (!mounted) return;

      _farmerController.clear();
      _quantityController.clear();
      _fatController.clear();
      _snfController.clear();
      _temperatureController.clear();
      _formKey.currentState?.reset();

      setState(() {
        if (quality.isAccepted) {
          _successMessage = 'Collection saved successfully! Quality: ACCEPTED.';
        } else {
          _qualityAlert = 'Collection saved. Quality ALERT: ${quality.message}';
        }
      });
      if (quality.isAccepted) {
        UserFeedback.showSuccess(context, message: _successMessage!);
      } else {
        UserFeedback.showError(context, message: _qualityAlert!);
      }
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
    _fatController.dispose();
    _snfController.dispose();
    _temperatureController.dispose();
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
            tooltip: 'Farmers and Centres',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const DirectoryPage())),
            icon: const Icon(Icons.people_outline),
          ),
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
                      validator: validateMilkQuantity,
                    ),
                    const SizedBox(height: 16),
                    _qualityField(_fatController, 'Fat %', percentage: true),
                    const SizedBox(height: 16),
                    _qualityField(_snfController, 'SNF %', percentage: true),
                    const SizedBox(height: 16),
                    _qualityField(_temperatureController, 'Temperature (°C)'),
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
              if (_qualityAlert != null) ...[
                const SizedBox(height: 16),
                _StatusMessage(
                  message: _qualityAlert!,
                  color: Colors.orange.shade900,
                  icon: Icons.warning_amber,
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
              _buildCollectionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qualityField(
    TextEditingController controller,
    String label, {
    bool percentage = false,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_isSaving,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
      validator: (value) =>
          validateQualityReading(value, label: label, percentage: percentage),
    );
  }

  Widget _buildCollectionList() {
    return StreamBuilder<List<Collection>>(
      stream: _collectionsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Collection list error: ${snapshot.error}');

          final error = snapshot.error;
          final isPermissionDenied =
              error is FirebaseException && error.code == 'permission-denied';

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
                    isPermissionDenied
                        ? 'Access denied'
                        : 'Unable to load collections',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPermissionDenied
                        ? 'You do not have permission to view these collections. '
                              'Please check your account access or contact your administrator.'
                        : 'Check your internet connection, then try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateText),
                    Text(
                      'Fat: ${collection.fat?.toStringAsFixed(1) ?? "—"}% · SNF: ${collection.snf?.toStringAsFixed(1) ?? "—"}%',
                    ),
                    Text(
                      'Temperature: ${collection.temperature?.toStringAsFixed(1) ?? "—"}°C',
                    ),
                    Text(
                      'Quality: ${collection.qualityStatus}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: collection.qualityStatus == 'ALERT'
                            ? Colors.orange.shade900
                            : collection.qualityStatus == 'ACCEPTED'
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
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

class DemoAppPage extends StatelessWidget {
  const DemoAppPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sample data - isolated demo')),
    body: Navigator(
      onGenerateRoute: (_) => MaterialPageRoute<void>(
        builder: (innerContext) => DairyTraceShell(
          onNewCollection: () => Navigator.of(innerContext).push(
            MaterialPageRoute<void>(builder: (_) => const NewCollectionPage()),
          ),
        ),
      ),
    ),
  );
}
