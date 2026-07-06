import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'providers/library_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/search_provider.dart';
import 'providers/collections_provider.dart';
import 'providers/reading_stats_provider.dart';
import 'repositories/file_backed_repository.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/library/library_screen.dart';
import 'screens/search_screen.dart';
import 'screens/collections_screen.dart';
import 'screens/profile_screen.dart';
import 'utils/initializable.dart';

class PoneglyphApp extends StatefulWidget {
  const PoneglyphApp({super.key});

  @override
  State<PoneglyphApp> createState() => _PoneglyphAppState();
}

class _PoneglyphAppState extends State<PoneglyphApp> {
  bool _ready = false;
  late FileBackedRepository _repo;

  @override
  void initState() {
    super.initState();
    _initRepo();
  }

  Future<void> _initRepo() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _repo = FileBackedRepository(dir);
    } catch (_) {
      // Fallback to in-memory if documents directory unavailable
      _repo = FileBackedRepository(Directory.systemTemp);
    }

    // Warm up the providers that need async init before first render
    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => LibraryProvider(repo: _repo)),
        ChangeNotifierProvider(create: (_) => SearchProvider(repo: _repo)),
        ChangeNotifierProvider(
            create: (_) => CollectionsProvider(repo: _repo)),
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
  bool _bootstrapped = false;

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
    // Show splash for 2s while we bootstrap providers
    await Future.delayed(const Duration(seconds: 1));

    // Initialize all providers that need async start-up
    await _bootstrapProviders();

    // Remaining splash time
    await Future.delayed(const Duration(seconds: 1));

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

  /// Call [initialize()] on every provider that implements [Initializable].
  /// This guarantees data is loaded before the first screen paints.
  Future<void> _bootstrapProviders() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    final providers = <Initializable>[
      context.read<LibraryProvider>(),
      context.read<CollectionsProvider>(),
    ];

    await Future.wait(providers.map((p) => p.initialize()));
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
