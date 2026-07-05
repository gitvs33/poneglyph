import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/buttons.dart';
import 'welcome_page.dart';
import 'permissions_page.dart';
import 'import_page.dart';
import 'theme_selection_page.dart';
import 'finish_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const WelcomePage(),
      const PermissionsPage(),
      const ImportPage(),
      ThemeSelectionPage(
        onThemeChanged: (mode) {
          context.read<ThemeProvider>().setTheme(mode);
        },
      ),
      const FinishPage(),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    _pageController.jumpToPage(_pages.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (_currentPage < _pages.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.grid24,
                  vertical: DesignTokens.grid16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PONEGLYPH',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    TextButton(
                      onPressed: _skip,
                      child: const Text('Skip'),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: _pages,
              ),
            ),
            // Progress dots
            Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.grid32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withAlpha(40),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid24,
                0,
                DesignTokens.grid24,
                DesignTokens.grid48,
              ),
              child: PrimaryButton(
                label: _currentPage < _pages.length - 1 ? 'Continue' : 'Get Started',
                onPressed: _currentPage < _pages.length - 1
                    ? _nextPage
                    : () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
