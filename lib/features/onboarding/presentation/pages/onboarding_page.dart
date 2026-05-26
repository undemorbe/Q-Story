import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/gothic_widgets.dart';
import '../../../../core/theme/theme_ext.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _pageCount = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final gold = context.gold;

    final items = [
      (icon: Icons.history_edu, title: l10n.onboarding1Title, desc: l10n.onboarding1Desc),
      (icon: Icons.qr_code_scanner, title: l10n.onboarding2Title, desc: l10n.onboarding2Desc),
      (icon: Icons.favorite, title: l10n.onboarding3Title, desc: l10n.onboarding3Desc),
    ];

    return Scaffold(
      body: GothicBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pageCount,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: context.outlineClr, width: 1),
                              color: context.surfaceVar,
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withValues(alpha: 0.2),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(item.icon,
                                size: 52, color: gold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '◆',
                            style: TextStyle(
                              color: gold.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            item.title,
                            style: GoogleFonts.cinzelDecorative(
                              color: context.onBg,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            item.desc,
                            style: GoogleFonts.crimsonText(
                              color: context.onBg,
                              fontSize: 18,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        _pageCount,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: _currentPage == index
                                  ? gold
                                  : context.outlineClr,
                              fontSize: _currentPage == index ? 14 : 9,
                            ),
                            child: const Text('◆'),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_currentPage < _pageCount - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          final prefs = getIt<SharedPreferences>();
                          await prefs.setBool('has_seen_onboarding', true);
                          if (context.mounted) context.go('/map');
                        }
                      },
                      child: Text(_currentPage < _pageCount - 1
                          ? l10n.continueButton
                          : l10n.beginButton),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
