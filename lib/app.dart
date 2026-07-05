import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'providers/library_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/search_provider.dart';
import 'providers/collections_provider.dart';
import 'providers/reading_stats_provider.dart';
import 'repositories/in_memory_repository.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/search_screen.dart';
import 'screens/collections_screen.dart';
import 'screens/profile_screen.dart';

class PoneglyphApp extends StatelessWidget {
  const PoneglyphApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = InMemoryRepository();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => LibraryProvider(repo: repo)),
        ChangeNotifierProvider(create: (_) => SearchProvider(repo: repo)),
        ChangeNotifierProvider(create: (_) => CollectionsProvider(repo: repo)),
        ChangeNotifierProvider(create: (_) => ReadingStatsProvider()),
        ChangeNotifierProvider(
            create: (_) => SettingsProvider()..loadSettings()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Poneglyph',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  bool _showSplash = true;

  final List<Widget> _screens = [
    const LibraryScreen(),
    const _ReaderPlaceholder(),
    const CollectionsScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final settings = context.read<SettingsProvider>();
    final onboardingComplete = settings.onboardingComplete;
    setState(() => _showSplash = false);
    if (!onboardingComplete) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          fullscreenDialog: true,
        ),
      );
      if (mounted && (result == true || result == null)) {
        context.read<SettingsProvider>().setOnboardingComplete(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) return const SplashScreen();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final unselected =
        theme.textTheme.bodySmall?.color?.withAlpha(110) ??
            Colors.white.withAlpha(110);
    final surface = theme.cardColor;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surface,
          border: Border(
            top: BorderSide(color: Colors.white.withAlpha(18), width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 58,
            child: Row(
              children: [
                _navItem(0, Icons.local_library_outlined, Icons.local_library,
                    'Library', primary, unselected),
                _navItem(1, Icons.menu_book_outlined, Icons.menu_book,
                    'Reader', primary, unselected),
                _navItem(2, Icons.collections_bookmark_outlined,
                    Icons.collections_bookmark, 'Bookshelves', primary, unselected),
                _navItem(3, Icons.search_outlined, Icons.search, 'Search',
                    primary, unselected),
                _navItem(4, Icons.person_outline, Icons.person, 'Profile',
                    primary, unselected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label,
      Color primary, Color unselected) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon,
                color: isActive ? primary : unselected, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? primary : unselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderPlaceholder extends StatelessWidget {
  const _ReaderPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined,
                size: 64,
                color: theme.colorScheme.primary.withAlpha(80)),
            const SizedBox(height: 16),
            Text(
              'Open a book from your Library',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(130),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
