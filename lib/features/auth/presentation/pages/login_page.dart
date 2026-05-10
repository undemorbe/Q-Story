import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../stores/auth_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthStore _store = getIt<AuthStore>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.requestPermissions();
    if (mounted) {
      final prefs = getIt<SharedPreferences>();
      final dailyNotificationsEnabled =
          prefs.getBool('daily_notifications_enabled') ?? true;
      if (dailyNotificationsEnabled) {
        await NotificationService.scheduleDailyNotification();
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
      body: GothicBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '— ✦ ◆ ✦ —',
                      style: TextStyle(
                        color: AppColors.primaryGold.withValues(alpha: 0.65),
                        fontSize: 18,
                        letterSpacing: 5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.cinzelDecorative(
                        color: AppColors.primaryGold,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your credentials to continue',
                      style: GoogleFonts.crimsonText(
                        color: AppColors.onSurface,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _emailController,
                      style: GoogleFonts.crimsonText(
                          color: AppColors.onBackground, fontSize: 18),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      style: GoogleFonts.crimsonText(
                          color: AppColors.onBackground, fontSize: 18),
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Observer(
                          builder: (_) => Checkbox(
                            value: _store.rememberMe,
                            onChanged: (value) {
                              _store.setRememberMe(value ?? false);
                            },
                          ),
                        ),
                        Text(
                          'Remember Me',
                          style: GoogleFonts.cinzel(
                              color: AppColors.onSurface, fontSize: 11),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Forgot Password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Observer(
                      builder: (_) {
                        if (_store.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _store.login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                if (_store.isAuthenticated && context.mounted) {
                                  context.go('/main');
                                } else if (_store.errorMessage != null &&
                                    context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text(_store.errorMessage!)),
                                  );
                                }
                              }
                            },
                            child: const Text('Login'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _store.checkBiometrics();
                          if (_store.isAuthenticated && context.mounted) {
                            context.go('/main');
                          }
                        },
                        icon: const Icon(Icons.fingerprint, size: 18),
                        label: const Text('Login with Biometrics'),
                      ),
                    ),
                    const SizedBox(height: 36),
                    const GothicDivider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.crimsonText(
                              color: AppColors.onSurface, fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: const Text('Register'),
                        ),
                      ],
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
