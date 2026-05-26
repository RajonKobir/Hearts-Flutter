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

  const ScoreBoard({
    super.key,
    required this.controller,
    required this.onScoreChanged,
    required this.onMoonHit,
    required this.onRemoveRound,
    required this.onAddRound,
    required this.onShowResult,
  });

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: _bottomScrollSpace(context, layout)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controller.isGameOver) GameOverBanner(layout: layout),
          ScoreSummaryCard(
            controller: controller,
            totals: controller.playerTotals,
            layout: layout,
            onAddRound: onAddRound,
            onShowResult: onShowResult,
          ),
          SizedBox(height: layout.isMobile ? 8.0 : 12.0),
          ScoreTable(
            controller: controller,
            layout: layout,
            onScoreChanged: onScoreChanged,
            onMoonHit: onMoonHit,
            onRemoveRound: onRemoveRound,
          ),
        ],
      ),
    );
  }

  double _bottomScrollSpace(BuildContext context, ResponsiveLayout layout) {
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;
    if (layout.isPhoneLandscape) return safeBottom + 112.0;
    if (layout.isPhonePortrait) return safeBottom + 80.0;
    if (layout.isTablet) return safeBottom + 104.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return safeBottom + 128.0 * layout.largeScreenScale;
    return safeBottom + 88.0 * layout.largeScreenScale;
  }
}
