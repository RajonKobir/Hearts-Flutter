import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controllers/game_controller.dart';
import 'database.dart';
import 'services/game_repository.dart';
import 'services/game_service.dart';
import 'utils/responsive_layout.dart';
import 'widgets/game_result_dialog.dart';
import 'widgets/score_board.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HeartsScoreApp());
}

class HeartsScoreApp extends StatefulWidget {
  const HeartsScoreApp({super.key});

  @override
  State<HeartsScoreApp> createState() => _HeartsScoreAppState();
}

class _HeartsScoreAppState extends State<HeartsScoreApp> {
  var _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hearts Score Manager',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      home: DashboardScreen(themeMode: _themeMode, onToggleTheme: _toggleTheme),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
        surfaceTintColor: colorScheme.surfaceTint,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  const DashboardScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      repository: GameRepository(AppDatabase.instance),
      gameService: GameService(),
    );
    _controller.addListener(_refresh);
    _controller.initialize();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _handleScoreChanged(
    int roundIndex,
    int playerIndex,
    int value,
  ) async {
    final shouldShowGameOver = await _controller.updateRoundScore(
      roundIndex,
      playerIndex,
      value,
    );
    if (shouldShowGameOver) {
      await _showGameOver();
    }
  }

  Future<void> _handleMoonHit(int roundIndex, int shooterIndex) async {
    final shouldShowGameOver = await _controller.applyMoonHit(
      roundIndex,
      shooterIndex,
    );
    if (shouldShowGameOver) {
      await _showGameOver();
    }
  }

  Future<void> _handleRemoveRound(int roundIndex) async {
    final roundNumber = _controller.rounds[roundIndex].roundNumber;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Round $roundNumber?'),
          content: const Text(
            'This will remove the round and update all player totals.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _controller.removeRound(roundIndex);
    }
  }

  Future<void> _showGameOver() async {
    await _controller.markGameOver();
    if (!mounted) return;
    _showResultDialog(mode: 'celebration');
  }

  void _showResult() {
    if (_controller.isGameOver) {
      _showResultDialog(mode: 'celebration');
      return;
    }

    _showResultDialog(mode: 'scores');
  }

  void _showResultDialog({required String mode}) {
    final effectiveMode = _controller.isGameOver ? 'celebration' : mode;

    showDialog<void>(
      context: context,
      builder: (context) {
        return GameResultDialog(
          results: _controller.resultRows(),
          mode: effectiveMode,
          onRestart: effectiveMode == 'celebration'
              ? _controller.restartGame
              : null,
        );
      },
    );
  }

  Future<void> _confirmRestart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restart Game?'),
          content: const Text(
            'This will clear the saved game and restart from round 1.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _controller.restartGame();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _appBarHeight(layout),
        title: Text(
          'Hearts Score Manager',
          style: TextStyle(fontSize: _appBarFontSize(layout)),
        ),
        actions: [
          Tooltip(
            message: widget.themeMode == ThemeMode.dark
                ? 'Use Light Theme'
                : 'Use Dark Theme',
            child: IconButton(
              onPressed: widget.onToggleTheme,
              iconSize: _appBarIconSize(layout),
              padding: EdgeInsets.all(_appBarIconPadding(layout)),
              constraints: BoxConstraints.tightFor(
                width: _appBarActionSize(layout),
                height: _appBarActionSize(layout),
              ),
              icon: Icon(
                widget.themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
          ),
          Tooltip(
            message: 'View Results',
            child: IconButton(
              onPressed: _controller.isInitialized ? _showResult : null,
              iconSize: _appBarIconSize(layout),
              padding: EdgeInsets.all(_appBarIconPadding(layout)),
              constraints: BoxConstraints.tightFor(
                width: _appBarActionSize(layout),
                height: _appBarActionSize(layout),
              ),
              icon: const Icon(Icons.insights),
            ),
          ),
          Tooltip(
            message: 'Restart Game',
            child: IconButton(
              onPressed: _controller.isInitialized ? _confirmRestart : null,
              iconSize: _appBarIconSize(layout),
              padding: EdgeInsets.all(_appBarIconPadding(layout)),
              constraints: BoxConstraints.tightFor(
                width: _appBarActionSize(layout),
                height: _appBarActionSize(layout),
              ),
              icon: const Icon(Icons.restart_alt),
            ),
          ),
        ],
      ),
      body: _controller.isInitialized
          ? Padding(
              padding: EdgeInsets.all(_bodyPadding(layout)),
              child: ScoreBoard(
                controller: _controller,
                onScoreChanged: _handleScoreChanged,
                onMoonHit: _handleMoonHit,
                onRemoveRound: _handleRemoveRound,
                onAddRound: _controller.addRound,
                onShowResult: _showResult,
              ),
            )
          : _LoadingView(layout: layout),
    );
  }

  double _appBarFontSize(ResponsiveLayout layout) {
    if (layout.isMobile) return 18.0;
    if (layout.isTablet) return 20.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 28.0 * layout.largeScreenScale;
    return 24.0 * layout.largeScreenScale;
  }

  double _appBarHeight(ResponsiveLayout layout) {
    if (layout.isMobile) return 64.0;
    if (layout.isTablet) return 72.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 88.0 * layout.largeScreenScale;
    return 76.0 * layout.largeScreenScale;
  }

  double _appBarIconSize(ResponsiveLayout layout) {
    if (layout.isMobile) return 30.0;
    if (layout.isTablet) return 34.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 40.0 * layout.largeScreenScale;
    return 34.0 * layout.largeScreenScale;
  }

  double _appBarActionSize(ResponsiveLayout layout) {
    if (layout.isMobile) return 52.0;
    if (layout.isTablet) return 60.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 72.0 * layout.largeScreenScale;
    return 60.0 * layout.largeScreenScale;
  }

  double _appBarIconPadding(ResponsiveLayout layout) {
    if (layout.isMobile) return 8.0;
    return 10.0 * layout.largeScreenScale;
  }

  double _bodyPadding(ResponsiveLayout layout) {
    if (layout.isMobile) return 8.0;
    if (layout.isTablet) return 12.0 * layout.largeScreenScale;
    return 16.0 * layout.largeScreenScale;
  }
}

class _LoadingView extends StatelessWidget {
  final ResponsiveLayout layout;

  const _LoadingView({required this.layout});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Initializing game...',
            style: TextStyle(
              fontSize: layout.isMobile ? 14.0 : 16.0 * layout.largeScreenScale,
            ),
          ),
        ],
      ),
    );
  }
}
