import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../utils/responsive_layout.dart';
import 'score_summary_card.dart';
import 'score_table.dart';

class ScoreBoard extends StatelessWidget {
  final GameController controller;
  final Future<void> Function(int roundIndex, int playerIndex, int value)
  onScoreChanged;
  final Future<void> Function(int roundIndex, int shooterIndex) onMoonHit;
  final Future<void> Function(int roundIndex) onRemoveRound;
  final Future<void> Function() onAddRound;
  final VoidCallback onShowResult;
  final VoidCallback onToggleTheme;
  final VoidCallback onConfirmRestart;
  final ThemeMode themeMode;

  const ScoreBoard({
    super.key,
    required this.controller,
    required this.onScoreChanged,
    required this.onMoonHit,
    required this.onRemoveRound,
    required this.onAddRound,
    required this.onShowResult,
    required this.onToggleTheme,
    required this.onConfirmRestart,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sticky header section
        if (controller.isGameOver) GameOverBanner(layout: layout),
        ScoreSummaryCard(
          controller: controller,
          totals: controller.playerTotals,
          layout: layout,
          onAddRound: onAddRound,
          onShowResult: onShowResult,
          onToggleTheme: onToggleTheme,
          onConfirmRestart: onConfirmRestart,
          themeMode: themeMode,
        ),
        SizedBox(height: layout.isMobile ? 8.0 : 12.0),
        // Scrollable table section
        Expanded(
          child: ScoreTable(
            controller: controller,
            layout: layout,
            onScoreChanged: onScoreChanged,
            onMoonHit: onMoonHit,
            onRemoveRound: onRemoveRound,
          ),
        ),
      ],
    );
  }
}
