import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import '../utils/responsive_layout.dart';

class GameOverBanner extends StatelessWidget {
  final ResponsiveLayout layout;

  const GameOverBanner({super.key, required this.layout});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(
        layout.isMobile
            ? 8
            : layout.isTablet
            ? 10
            : layout.isSmartTV
            ? 20
            : 12,
      ),
      margin: EdgeInsets.only(
        bottom: layout.isMobile
            ? 8.0
            : layout.isSmartTV
            ? 20.0
            : 12.0,
      ),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        border: Border.all(color: colorScheme.error, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: colorScheme.tertiary,
            size: layout.isMobile
                ? 24.0
                : layout.isSmartTV
                ? 48.0
                : 28.0,
          ),
          SizedBox(
            width: layout.isMobile
                ? 8.0
                : layout.isSmartTV
                ? 20.0
                : 12.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Over!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: layout.isMobile
                        ? 14
                        : layout.isSmartTV
                        ? 22 * layout.largeScreenScale
                        : 16 * layout.largeScreenScale,
                    color: colorScheme.onErrorContainer,
                  ),
                ),
                SizedBox(
                  height: layout.isMobile
                      ? 2.0
                      : layout.isSmartTV
                      ? 8.0
                      : 4.0,
                ),
                Text(
                  'Click "See Result" to view final rankings.',
                  style: TextStyle(
                    fontSize: layout.isMobile
                        ? 10.0
                        : layout.isSmartTV
                        ? 16.0 * layout.largeScreenScale
                        : 12.0 * layout.largeScreenScale,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreSummaryCard extends StatelessWidget {
  final GameController controller;
  final List<int> totals;
  final ResponsiveLayout layout;
  final Future<void> Function() onAddRound;
  final VoidCallback onShowResult;

  const ScoreSummaryCard({
    super.key,
    required this.controller,
    required this.totals,
    required this.layout,
    required this.onAddRound,
    required this.onShowResult,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(
          layout.isMobile
              ? 10
              : layout.isTablet
              ? 12
              : layout.isSmartTV
              ? 24
              : 14,
        ),
        child: layout.isMobile || layout.isTablet
            ? _mobileContent(colorScheme)
            : _wideContent(colorScheme),
      ),
    );
  }

  Widget _wideContent(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(child: _titleAndTotals(colorScheme)),
        SizedBox(width: layout.isMobile ? 8.0 : 16.0),
        _RoundActionButton(
          isGameOver: controller.isGameOver,
          layout: layout,
          onAddRound: onAddRound,
          canAddRound: controller.canAddRound,
          onShowResult: onShowResult,
        ),
      ],
    );
  }

  Widget _mobileContent(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleAndTotals(colorScheme),
        const SizedBox(height: 12.0),
        SizedBox(
          width: double.infinity,
          child: _RoundActionButton(
            isGameOver: controller.isGameOver,
            layout: layout,
            onAddRound: onAddRound,
            canAddRound: controller.canAddRound,
            onShowResult: onShowResult,
          ),
        ),
      ],
    );
  }

  Widget _titleAndTotals(ColorScheme colorScheme) {
    final currentRound = controller.rounds.last.roundNumber;
    final passDirection = _passDirectionForRound(currentRound);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: layout.isMobile ? 8.0 : 12.0,
          runSpacing: layout.isMobile ? 6.0 : 8.0,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Hearts Score Manager',
              style: TextStyle(
                fontSize: layout.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Chip(
              avatar: Icon(
                Icons.compare_arrows,
                size: layout.isMobile ? 16.0 : 18.0,
                color: colorScheme.onTertiaryContainer,
              ),
              label: Text(
                passDirection.toUpperCase(),
                style: TextStyle(
                  fontSize: layout.chipFontSize,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              backgroundColor: colorScheme.tertiaryContainer,
              side: BorderSide(color: colorScheme.outlineVariant),
              padding: EdgeInsets.symmetric(
                horizontal: layout.isMobile ? 6.0 : 8.0,
                vertical: layout.isMobile ? 4.0 : 6.0,
              ),
            ),
          ],
        ),
        SizedBox(height: layout.isMobile ? 10.0 : 12.0),
        _scorePills(colorScheme),
      ],
    );
  }

  Widget _scorePills(ColorScheme colorScheme) {
    final gap = layout.isMobile ? 8.0 : 12.0 * layout.largeScreenScale;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _scorePillAt(0, colorScheme)),
            SizedBox(width: gap),
            Expanded(child: _scorePillAt(1, colorScheme)),
          ],
        ),
        SizedBox(height: gap),
        Row(
          children: [
            Expanded(child: _scorePillAt(2, colorScheme)),
            SizedBox(width: gap),
            Expanded(child: _scorePillAt(3, colorScheme)),
          ],
        ),
      ],
    );
  }

  Widget _scorePillAt(int index, ColorScheme colorScheme) {
    return _ScorePill(
      playerName: controller.currentGame.playerNames[index],
      score: totals[index],
      colorScheme: colorScheme,
      layout: layout,
    );
  }

  String _passDirectionForRound(int roundNumber) {
    return switch ((roundNumber - 1) % 4) {
      0 => 'right',
      1 => 'left',
      2 => 'crossover',
      _ => 'none',
    };
  }
}

class _ScorePill extends StatelessWidget {
  final String playerName;
  final int score;
  final ColorScheme colorScheme;
  final ResponsiveLayout layout;

  const _ScorePill({
    required this.playerName,
    required this.score,
    required this.colorScheme,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: layout.isMobile
            ? 48.0
            : layout.isSmartTV
            ? 78.0 * layout.largeScreenScale
            : 58.0 * layout.largeScreenScale,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: layout.isPhonePortrait
            ? 6.0
            : layout.isMobile
            ? 10.0
            : 18.0 * layout.largeScreenScale,
        vertical: layout.isPhonePortrait
            ? 9.0
            : layout.isMobile
            ? 10.0
            : 12.0 * layout.largeScreenScale,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: layout.pointSummaryFontSize,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSecondaryContainer,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(': $score'),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final bool isGameOver;
  final ResponsiveLayout layout;
  final Future<void> Function() onAddRound;
  final bool canAddRound;
  final VoidCallback onShowResult;

  const _RoundActionButton({
    required this.isGameOver,
    required this.layout,
    required this.onAddRound,
    required this.canAddRound,
    required this.onShowResult,
  });

  @override
  Widget build(BuildContext context) {
    if (isGameOver) {
      return FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: Size(_buttonWidth(), _buttonHeight()),
          padding: EdgeInsets.symmetric(
            horizontal: _buttonPaddingH(),
            vertical: _buttonPaddingV(),
          ),
        ),
        onPressed: onShowResult,
        child: Text(
          'See Result',
          style: TextStyle(
            fontSize: _buttonFontSize(),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: Size(_buttonWidth(), _buttonHeight()),
        padding: EdgeInsets.symmetric(
          horizontal: _buttonPaddingH(),
          vertical: _buttonPaddingV(),
        ),
      ),
      icon: Icon(Icons.add, size: _buttonIconSize()),
      label: Text(
        'New Round',
        style: TextStyle(
          fontSize: _buttonFontSize(),
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: canAddRound ? onAddRound : null,
    );
  }

  double _buttonFontSize() {
    if (layout.isMobile) return 16.0;
    if (layout.isTablet) return 18.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 24.0 * layout.largeScreenScale;
    return 20.0 * layout.largeScreenScale;
  }

  double _buttonIconSize() {
    if (layout.isMobile) return 24.0;
    if (layout.isTablet) return 26.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 34.0 * layout.largeScreenScale;
    return 28.0 * layout.largeScreenScale;
  }

  double _buttonHeight() {
    if (layout.isMobile) return 52.0;
    if (layout.isTablet) return 60.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 78.0 * layout.largeScreenScale;
    return 62.0 * layout.largeScreenScale;
  }

  double _buttonWidth() {
    if (layout.isMobile) return 0.0;
    if (layout.isTablet) return 180.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 260.0 * layout.largeScreenScale;
    return 200.0 * layout.largeScreenScale;
  }

  double _buttonPaddingH() {
    if (layout.isMobile) return 18.0;
    if (layout.isTablet) return 24.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 34.0 * layout.largeScreenScale;
    return 28.0 * layout.largeScreenScale;
  }

  double _buttonPaddingV() {
    if (layout.isMobile) return 12.0;
    if (layout.isTablet) return 14.0 * layout.largeScreenScale;
    if (layout.isSmartTV) return 20.0 * layout.largeScreenScale;
    return 16.0 * layout.largeScreenScale;
  }
}
