import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';
import '../stores/auth_store.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthStore _store = getIt<AuthStore>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gold = context.gold;

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
                        color: gold.withValues(alpha: 0.65),
                        fontSize: 18,
                        letterSpacing: 5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.registerTitle,
                      style: GoogleFonts.cinzelDecorative(
                        color: gold,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.registerSubtitle,
                      style: GoogleFonts.crimsonText(
                        color: context.onBg,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _usernameController,
                      style: GoogleFonts.crimsonText(
                          color: context.onBg, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: l10n.usernameLabel,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.usernameLabel;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      style: GoogleFonts.crimsonText(
                          color: context.onBg, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.emailLabel;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      style: GoogleFonts.crimsonText(
                          color: context.onBg, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.passwordLabel;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 36),
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
                                await _store.register(
                                  _emailController.text,
                                  _usernameController.text,
                                  _passwordController.text,
                                );
                                if (_store.isAuthenticated && context.mounted) {
                                  context.go('/main');
                                } else if (_store.errorMessage != null &&
                                    context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(_store.errorMessage!)),
                                  );
                                }
                              }
                            },
                            child: Text(l10n.registerLink),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const GothicDivider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${l10n.alreadyHaveAccount} ',
                          style: GoogleFonts.crimsonText(
                              color: context.onBg, fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(l10n.loginLink),
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
