import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khedmalink/core/localization/app_localization.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  static const _onboardingCompletedKey = 'onboarding_completed';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _checkIfCompleted();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkIfCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool(_onboardingCompletedKey) ?? false;
    if (completed && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        context.go('/home');
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          _buildPage(
            index: 0,
            title: localizations.welcome,
            subtitle: 'KhedmaLink تربطك بأفضل مقدمي الخدمات في منطقتك',
            image: Icons.supervised_user_circle,
          ),
          _buildPage(
            index: 1,
            title: 'خدمات موثوقة',
            subtitle: 'نحرص على جودة الخدمة ورضا العملاء',
            image: Icons.shopping_bag,
          ),
          _buildPage(
            index: 2,
            title: 'ابدأ الآن',
            subtitle: 'اكتشف الخدمات واحجز موعدك بسهولة',
            image: Icons.launch,
          ),
        ],
      ),
      bottomSheet: Container(
        color: Theme.of(context).colorScheme.surface,
        height: kBottomNavigationBarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage < 2)
                TextButton(
                  onPressed: () => _nextPage(),
                  child: Text(_currentPage == 0
                      ? localizations.skip
                      : localizations.next),
                ),
              if (_currentPage < 2)
                const SizedBox(width: 8),
              if (_currentPage < 2)
                const VerticalDivider(thickness: 1, width: 16),
              if (_currentPage < 2)
                const SizedBox(width: 8),
              if (_currentPage < 2)
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == 2
                      ? localizations.done
                      : localizations.next),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required int index,
    required String title,
    required String subtitle,
    required IconData image,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              image,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}