import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/game_service.dart';
import '../utils/responsive_layout.dart';

class GameResultDialog extends StatefulWidget {
  final List<PlayerResult> results;
  final String mode;
  final Future<void> Function()? onRestart;

  const GameResultDialog({
    super.key,
    required this.results,
    required this.mode,
    this.onRestart,
  });

  @override
  State<GameResultDialog> createState() => _GameResultDialogState();
}

class _GameResultDialogState extends State<GameResultDialog>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _celebrationController;
  late ScrollController _scrollController;
  late Animation<double> _celebrationScale;
  late Animation<double> _celebrationTurns;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 850),
    );
    _scrollController = ScrollController();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 360),
      vsync: this,
    );
    _celebrationScale = Tween<double>(begin: 0.92, end: 1.1).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.easeInOutBack,
      ),
    );
    _celebrationTurns = Tween<double>(begin: -0.025, end: 0.025).animate(
      CurvedAnimation(parent: _celebrationController, curve: Curves.easeInOut),
    );
    if (widget.mode == 'celebration') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _confettiController.play();
        _celebrationController.repeat(reverse: true);
        SystemSound.play(SystemSoundType.alert);
        HapticFeedback.mediumImpact();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _celebrationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = ResponsiveLayout.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isGameOver = widget.mode == 'celebration';
    final showCelebration = widget.mode == 'celebration';
    final isPhonePortrait = layout.isPhonePortrait;
    final horizontalInset = isPhonePortrait ? 12.0 : 24.0;
    final verticalInset = isPhonePortrait ? 12.0 : 24.0;
    final availableDialogHeight = max(
      0.0,
      layout.screenHeight - (verticalInset * 2),
    );

    final titleFontSize = isPhonePortrait
        ? 16.0
        : layout.isMobile
        ? 18.0
        : layout.isTablet
        ? 24.0 * layout.largeScreenScale
        : layout.isSmartTV
        ? 28.0 * layout.largeScreenScale
        : 26.0 * layout.largeScreenScale;
    final resultFontSize = isPhonePortrait
        ? 12.0
        : layout.isMobile
        ? 13.0
        : layout.isTablet
        ? 15.0 * layout.largeScreenScale
        : layout.isSmartTV
        ? 18.0 * layout.largeScreenScale
        : 16.0 * layout.largeScreenScale;
    final scoreFontSize = isPhonePortrait
        ? 20.0
        : layout.isMobile
        ? 22.0
        : layout.isTablet
        ? 24.0 * layout.largeScreenScale
        : layout.isSmartTV
        ? 30.0 * layout.largeScreenScale
        : 26.0 * layout.largeScreenScale;
    final preferredDialogWidth = isPhonePortrait
        ? layout.screenWidth * 0.82
        : layout.isMobile
        ? layout.screenWidth * 0.85
        : layout.isTablet
        ? 600.0 * layout.largeScreenScale
        : layout.isSmartTV
        ? 900.0 * layout.largeScreenScale
        : 760.0 * layout.largeScreenScale;
    final dialogWidth = min(
      preferredDialogWidth,
      layout.screenWidth - (horizontalInset * 2),
    );
    final preferredDialogHeight = isPhonePortrait
        ? layout.screenHeight * 0.72
        : layout.isMobile
        ? 500.0
        : layout.isSmartTV
        ? 620.0 * layout.largeScreenScale
        : 520.0 * layout.largeScreenScale;
    final dialogHeight = min(preferredDialogHeight, availableDialogHeight);
    final displayResults = _withSharedScoreRanks(widget.results);

    return Stack(
      children: [
        Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: verticalInset,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: dialogHeight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isPhonePortrait ? 16.0 : 24.0,
                    isPhonePortrait ? 14.0 : 24.0,
                    isPhonePortrait ? 8.0 : 12.0,
                    isPhonePortrait ? 4.0 : 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.mode == 'celebration'
                              ? 'Game Over!'
                              : 'Current Result',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: widget.mode == 'celebration'
                                ? colorScheme.error
                                : colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        iconSize: layout.isMobile
                            ? 24.0
                            : layout.isSmartTV
                            ? 26.0 * layout.largeScreenScale
                            : 28.0,
                        onPressed: () => Navigator.pop(context),
                        visualDensity: isPhonePortrait
                            ? VisualDensity.compact
                            : VisualDensity.standard,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isPhonePortrait ? 16.0 : 24.0,
                      isPhonePortrait ? 4.0 : 20.0,
                      isPhonePortrait ? 16.0 : 24.0,
                      isPhonePortrait ? 8.0 : 20.0,
                    ),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: showCelebration
                                ? LinearGradient(
                                    colors: [
                                      colorScheme.errorContainer.withValues(
                                        alpha: 0.35,
                                      ),
                                      colorScheme.tertiaryContainer.withValues(
                                        alpha: 0.35,
                                      ),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: layout.isMobile ? 250.0 : 350.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showCelebration)
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: isPhonePortrait
                                          ? 6
                                          : layout.isMobile
                                          ? 12
                                          : layout.isTablet
                                          ? 14 * layout.largeScreenScale
                                          : layout.isSmartTV
                                          ? 18 * layout.largeScreenScale
                                          : 16,
                                    ),
                                    child: Column(
                                      children: [
                                        ScaleTransition(
                                          scale: _celebrationScale,
                                          child: RotationTransition(
                                            turns: _celebrationTurns,
                                            child: Icon(
                                              Icons.celebration,
                                              color: colorScheme.tertiary,
                                              size: isPhonePortrait
                                                  ? 34
                                                  : layout.isMobile
                                                  ? 44
                                                  : layout.isSmartTV
                                                  ? 72 * layout.largeScreenScale
                                                  : 58 *
                                                        layout.largeScreenScale,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: isPhonePortrait ? 4 : 8,
                                        ),
                                        Text(
                                          'Congratulations to the winner!',
                                          style: TextStyle(
                                            fontSize: isPhonePortrait
                                                ? 11.0
                                                : layout.isMobile
                                                ? 13.0
                                                : layout.isSmartTV
                                                ? 16.0 * layout.largeScreenScale
                                                : 15.0 *
                                                      layout.largeScreenScale,
                                            fontStyle: FontStyle.italic,
                                            color: colorScheme.tertiary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                for (
                                  var index = 0;
                                  index < displayResults.length;
                                  index++
                                )
                                  _ResultTile(
                                    index: index,
                                    result: displayResults[index],
                                    isGameOver: isGameOver,
                                    layout: layout,
                                    resultFontSize: resultFontSize,
                                    scoreFontSize: scoreFontSize,
                                    compact: isPhonePortrait,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isPhonePortrait ? 12.0 : 24.0,
                    0,
                    isPhonePortrait ? 12.0 : 24.0,
                    isPhonePortrait ? 10.0 : 16.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isGameOver && widget.onRestart != null) ...[
                        FilledButton(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: layout.isMobile
                                  ? 14
                                  : layout.isSmartTV
                                  ? 18 * layout.largeScreenScale
                                  : 18,
                              vertical: layout.isMobile
                                  ? 8
                                  : layout.isSmartTV
                                  ? 12 * layout.largeScreenScale
                                  : 12,
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            await widget.onRestart!();
                          },
                          child: Text(
                            'Start Over',
                            style: TextStyle(fontSize: layout.buttonFontSize),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Close',
                          style: TextStyle(fontSize: layout.buttonFontSize),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showCelebration)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 36,
              minBlastForce: 8,
              emissionFrequency: 0.85,
              numberOfParticles: 16,
              gravity: 0.1,
            ),
          ),
        if (showCelebration)
          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              maxBlastForce: 36,
              minBlastForce: 8,
              emissionFrequency: 0.85,
              numberOfParticles: 16,
              gravity: 0.1,
            ),
          ),
      ],
    );
  }

  List<PlayerResult> _withSharedScoreRanks(List<PlayerResult> results) {
    final sortedScores = results.map((result) => result.score).toSet().toList()
      ..sort();
    final rankByScore = <int, int>{
      for (var i = 0; i < sortedScores.length; i++) sortedScores[i]: i + 1,
    };

    return [
      for (final result in results)
        result.copyWith(rank: rankByScore[result.score] ?? result.rank),
    ];
  }
}

class _ResultTile extends StatelessWidget {
  final int index;
  final PlayerResult result;
  final bool isGameOver;
  final ResponsiveLayout layout;
  final double resultFontSize;
  final double scoreFontSize;
  final bool compact;

  const _ResultTile({
    required this.index,
    required this.result,
    required this.isGameOver,
    required this.layout,
    required this.resultFontSize,
    required this.scoreFontSize,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final isWinner = result.rank == 1 && isGameOver;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: compact
            ? 3
            : layout.isMobile
            ? 6
            : layout.isSmartTV
            ? 8 * layout.largeScreenScale
            : 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isWinner
            ? colorScheme.tertiaryContainer
            : colorScheme.surfaceContainerHighest,
        border: isWinner
            ? Border.all(color: colorScheme.tertiary, width: 2)
            : Border.all(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact
              ? 10
              : layout.isMobile
              ? 12
              : layout.isSmartTV
              ? 16 * layout.largeScreenScale
              : 16,
          vertical: compact
              ? 2
              : layout.isMobile
              ? 6
              : layout.isSmartTV
              ? 8 * layout.largeScreenScale
              : 8,
        ),
        leading: CircleAvatar(
          backgroundColor: isWinner
              ? colorScheme.tertiary
              : colorScheme.primary,
          radius: compact
              ? 15
              : layout.isMobile
              ? 16
              : layout.isSmartTV
              ? 20 * layout.largeScreenScale
              : 20,
          child: Text(
            _rankLabel(result.rank),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWinner ? colorScheme.onTertiary : colorScheme.onPrimary,
              fontSize: compact
                  ? 10
                  : layout.isMobile
                  ? 11
                  : layout.isSmartTV
                  ? 14 * layout.largeScreenScale
                  : 13,
            ),
          ),
        ),
        title: Text(
          result.name,
          style: TextStyle(
            fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
            fontSize: isWinner
                ? resultFontSize
                : resultFontSize - (layout.isSmartTV ? 4.0 : 2.0),
            color: colorScheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${result.score}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isWinner
                ? scoreFontSize
                : scoreFontSize - (layout.isSmartTV ? 8.0 : 4.0),
            color: isWinner
                ? colorScheme.onTertiaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  String _rankLabel(int rank) {
    return switch (rank) {
      1 => '1st',
      2 => '2nd',
      3 => '3rd',
      _ => '${rank}th',
    };
  }
}
