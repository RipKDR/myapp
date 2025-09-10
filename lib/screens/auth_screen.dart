import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final auth = context.watch<AuthController>();
    final initialized = FirebaseService.initialized;

    return Scaffold(
      appBar: AppBar(title: const Text('NDIS Connect'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Welcome to NDIS Connect',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Accessible companion for NDIS participants and providers',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Error message
            if (auth.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Authentication form
            if (initialized) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isSignUp ? 'Create Account' : 'Sign In',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (final value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (final value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (_isSignUp && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Sign in/up button
                        FilledButton(
                          onPressed: auth.isLoading ? null : _handleEmailAuth,
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(_isSignUp ? 'Create Account' : 'Sign In'),
                        ),
                        const SizedBox(height: 8),

                        // Toggle sign up/sign in
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                            });
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Sign in'
                                : 'Don\'t have an account? Create one',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Quick access buttons
            if (initialized)
              FilledButton.icon(
                onPressed: auth.isLoading ? null : _handleAnonymousSignIn,
                icon: const Icon(Icons.person_outline),
                label: const Text('Continue as Guest'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              )
            else
              FilledButton.icon(
                onPressed: () {
                  context.read<AuthController>().setSignedIn(true);
                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.wifi_off),
                label: const Text('Continue Offline'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _handleBiometricAuth(context),
              icon: const Icon(Icons.fingerprint),
              label: const Text('Use Biometrics'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () => _showRolePicker(context),
              icon: const Icon(Icons.switch_account),
              label: const Text('Choose Role'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    bool success = false;
    if (_isSignUp) {
      // For sign up, we need to select a role first
      final role = await _showRolePicker(context);
      if (role != null) {
        success = await auth.createAccount(email, password, role);
      }
    } else {
      success = await auth.signInWithEmail(email, password);
    }

    if (success && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleAnonymousSignIn() async {
    final auth = context.read<AuthController>();
    final success = await auth.signInAnonymously();

    if (success && context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleBiometricAuth(final BuildContext context) async {
    // Guard: biometrics not supported on web; only enable on mobile/desktop
    if (kIsWeb) {
      _showToast(context, 'Biometrics not supported on web');
      return;
    }
    // Some desktop targets may not support biometrics; try/catch around checks
    final auth = LocalAuthentication();
    bool canCheck = false;
    try {
      canCheck = await auth.canCheckBiometrics;
    } catch (_) {
      canCheck = false;
    }

    if (!canCheck) {
      _showToast(context, 'Biometrics unavailable on this device');
      return;
    }

    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Use biometrics to quickly access NDIS Connect',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // For biometric auth, we'll use anonymous sign in
        await _handleAnonymousSignIn();
      }
    } catch (e) {
      _showToast(context, 'Biometric authentication failed: $e');
    }
  }

  Future<UserRole?> _showRolePicker(final BuildContext context) async => showDialog<UserRole>(
      context: context,
      barrierDismissible: false,
      builder: (final context) => AlertDialog(
        title: const Text('Choose Your Role'),
        content: const Text(
          'Select how you want to use NDIS Connect. This helps us personalize your experience.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, UserRole.participant),
            child: const Text('Participant'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, UserRole.provider),
            child: const Text('Provider'),
          ),
        ],
      ),
    );

  void _showToast(final BuildContext context, final String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
