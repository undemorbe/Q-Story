import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/gothic_widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Discover History',
      description:
          'Explore historical events and figures from around the world.',
      icon: Icons.history_edu,
    ),
    OnboardingItem(
      title: 'Scan QR Codes',
      description:
          'Scan QR codes at museums and historical sites to unlock content.',
      icon: Icons.qr_code_scanner,
    ),
    OnboardingItem(
      title: 'Save Favorites',
      description: 'Keep track of your favorite historical moments.',
      icon: Icons.favorite,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GothicBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];
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
                                  color: AppColors.outline, width: 1),
                              color: AppColors.surfaceVariant,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGold
                                      .withValues(alpha: 0.2),
                                  blurRadius: 28,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(item.icon,
                                size: 52, color: AppColors.primaryGold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '◆',
                            style: TextStyle(
                              color:
                                  AppColors.primaryGold.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            item.title,
                            style: GoogleFonts.cinzelDecorative(
                              color: AppColors.onBackground,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            item.description,
                            style: GoogleFonts.crimsonText(
                              color: AppColors.onSurface,
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
                        _items.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: _currentPage == index
                                  ? AppColors.primaryGold
                                  : AppColors.outline,
                              fontSize: _currentPage == index ? 14 : 9,
                            ),
                            child: const Text('◆'),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_currentPage < _items.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          final prefs = getIt<SharedPreferences>();
                          await prefs.setBool('has_seen_onboarding', true);
                          if (context.mounted) {
                            context.go('/map');
                          }
                        }
                      },
                      child: Text(
                          _currentPage < _items.length - 1 ? 'Continue' : 'Begin'),
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

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
