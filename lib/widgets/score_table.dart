import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/game_controller.dart';
import '../utils/responsive_layout.dart';

class ScoreTable extends StatelessWidget {
  final GameController controller;
  final ResponsiveLayout layout;
  final Future<void> Function(int roundIndex, int playerIndex, int value)
  onScoreChanged;
  final Future<void> Function(int roundIndex, int shooterIndex) onMoonHit;
  final Future<void> Function(int roundIndex) onRemoveRound;

  const ScoreTable({
    super.key,
    required this.controller,
    required this.layout,
    required this.onScoreChanged,
    required this.onMoonHit,
    required this.onRemoveRound,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tableMinWidth = layout.isPhonePortrait
            ? constraints.maxWidth
            : layout.tableMinWidth;
        final columnWidths = layout.isPhonePortrait
            ? const <int, TableColumnWidth>{
                0: FixedColumnWidth(48.0),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
                5: FixedColumnWidth(34.0),
              }
            : <int, TableColumnWidth>{
                0: FixedColumnWidth(layout.isMobile ? 70.0 : 96.0),
              };

        final table = ConstrainedBox(
          constraints: BoxConstraints(minWidth: tableMinWidth),
          child: Table(
            border: TableBorder.all(
              color: colorScheme.outlineVariant,
              width: 1,
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: columnWidths,
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                ),
                children: [
                  _HeaderCell(
                    title: layout.isPhonePortrait ? 'Rnd' : 'Round',
                    layout: layout,
                  ),
                  for (var index = 0; index < 4; index++)
                    _PlayerNameHeaderCell(
                      playerIndex: index,
                      controller: controller,
                      layout: layout,
                    ),
                  _HeaderCell(
                    title: layout.isPhonePortrait ? 'Tot' : 'Total',
                    layout: layout,
                  ),
                ],
              ),
              for (
                var roundIndex = 0;
                roundIndex < controller.rounds.length;
                roundIndex++
              )
                _RoundScoreRow(
                  roundIndex: roundIndex,
                  controller: controller,
                  layout: layout,
                  colorScheme: colorScheme,
                  onScoreChanged: onScoreChanged,
                  onMoonHit: onMoonHit,
                  onRemoveRound: onRemoveRound,
                ).build(),
            ],
          ),
        );

        if (layout.isPhonePortrait) return table;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: table,
        );
      },
    );
  }
}

class _RoundScoreRow {
  final int roundIndex;
  final GameController controller;
  final ResponsiveLayout layout;
  final ColorScheme colorScheme;
  final Future<void> Function(int roundIndex, int playerIndex, int value)
  onScoreChanged;
  final Future<void> Function(int roundIndex, int shooterIndex) onMoonHit;
  final Future<void> Function(int roundIndex) onRemoveRound;

  const _RoundScoreRow({
    required this.roundIndex,
    required this.controller,
    required this.layout,
    required this.colorScheme,
    required this.onScoreChanged,
    required this.onMoonHit,
    required this.onRemoveRound,
  });

  TableRow build() {
    final round = controller.rounds[roundIndex];

    return TableRow(
      children: [
        _RoundLabelCell(
          layout: layout,
          roundNumber: round.roundNumber,
          canRemove: controller.canRemoveRound,
          onRemove: () => onRemoveRound(roundIndex),
        ),
        for (var playerIndex = 0; playerIndex < 4; playerIndex++)
          _ScoreEntryCell(
            roundIndex: roundIndex,
            playerIndex: playerIndex,
            controller: controller,
            layout: layout,
            colorScheme: colorScheme,
            onScoreChanged: onScoreChanged,
            onMoonHit: onMoonHit,
          ),
        _DataCell(
          layout: layout,
          child: Text(
            '${round.total}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: layout.tableLabelFontSize,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreEntryCell extends StatelessWidget {
  final int roundIndex;
  final int playerIndex;
  final GameController controller;
  final ResponsiveLayout layout;
  final ColorScheme colorScheme;
  final Future<void> Function(int roundIndex, int playerIndex, int value)
  onScoreChanged;
  final Future<void> Function(int roundIndex, int shooterIndex) onMoonHit;

  const _ScoreEntryCell({
    required this.roundIndex,
    required this.playerIndex,
    required this.controller,
    required this.layout,
    required this.colorScheme,
    required this.onScoreChanged,
    required this.onMoonHit,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = layout.isPhonePortrait;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isCompact
            ? 3.0
            : layout.isMobile
            ? 4.0
            : 6.0,
        horizontal: isCompact
            ? 1.5
            : layout.isMobile
            ? 2.0
            : 4.0,
      ),
      child: Column(
        children: [
          TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _MaxScoreInputFormatter(maxScore: 26),
            ],
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            style: TextStyle(fontSize: layout.tableInputFontSize),
            decoration: InputDecoration(
              hintText: '0',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: isCompact
                    ? 4.0
                    : layout.isMobile
                    ? 4.0
                    : 8.0,
                horizontal: isCompact
                    ? 2.0
                    : layout.isMobile
                    ? 4.0
                    : 8.0,
              ),
              isDense: true,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
            ),
            controller: controller.scoreControllerFor(roundIndex, playerIndex),
            onChanged: (value) {
              final integer = int.tryParse(value) ?? 0;
              onScoreChanged(roundIndex, playerIndex, integer);
            },
          ),
          SizedBox(
            height: isCompact
                ? 3.0
                : layout.isMobile
                ? 4.0
                : 6.0,
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: isCompact ? const Size(0, 24) : null,
              tapTargetSize: isCompact
                  ? MaterialTapTargetSize.shrinkWrap
                  : null,
              padding: EdgeInsets.symmetric(
                horizontal: _moonPaddingH(layout),
                vertical: _moonPaddingV(layout),
              ),
              textStyle: TextStyle(fontSize: layout.moonFontSize),
            ),
            onPressed: () => onMoonHit(roundIndex, playerIndex),
            child: Text(
              'Moon',
              style: TextStyle(fontSize: layout.moonFontSize),
            ),
          ),
        ],
      ),
    );
  }

  double _moonPaddingH(ResponsiveLayout layout) {
    if (layout.isPhonePortrait) return 4.0;
    if (layout.isMobile) return 8.0;
    if (layout.isSmartTV) return 16.0 * layout.largeScreenScale;
    return 14.0 * layout.largeScreenScale;
  }

  double _moonPaddingV(ResponsiveLayout layout) {
    if (layout.isPhonePortrait) return 3.0;
    if (layout.isMobile) return 4.0;
    return 8.0 * layout.largeScreenScale;
  }
}

class _MaxScoreInputFormatter extends TextInputFormatter {
  final int maxScore;

  const _MaxScoreInputFormatter({required this.maxScore});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    if (value == null || value > maxScore) return oldValue;
    return newValue;
  }
}

class _DataCell extends StatelessWidget {
  final Widget child;
  final ResponsiveLayout layout;

  const _DataCell({required this.child, required this.layout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        layout.isPhonePortrait
            ? 2.0
            : layout.isMobile
            ? 4.0
            : 8.0,
      ),
      child: Center(child: child),
    );
  }
}

class _RoundLabelCell extends StatelessWidget {
  final int roundNumber;
  final bool canRemove;
  final VoidCallback onRemove;
  final ResponsiveLayout layout;

  const _RoundLabelCell({
    required this.roundNumber,
    required this.canRemove,
    required this.onRemove,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: layout.isPhonePortrait
            ? 3.0
            : layout.isMobile
            ? 4.0
            : 8.0,
        horizontal: layout.isPhonePortrait
            ? 1.0
            : layout.isMobile
            ? 4.0
            : 8.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'R$roundNumber',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: layout.tableLabelFontSize,
            ),
          ),
          SizedBox(height: layout.isPhonePortrait ? 2.0 : 4.0),
          Tooltip(
            message: canRemove
                ? 'Delete Round $roundNumber'
                : 'At least one round is required',
            child: IconButton(
              onPressed: canRemove ? onRemove : null,
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
              disabledColor: colorScheme.onSurfaceVariant.withValues(
                alpha: 0.45,
              ),
              iconSize: _deleteIconSize(),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: BoxConstraints.tightFor(
                width: _deleteButtonSize(),
                height: _deleteButtonSize(),
              ),
              tooltip: '',
            ),
          ),
        ],
      ),
    );
  }

  double _deleteIconSize() {
    if (layout.isPhonePortrait) return 16.0;
    if (layout.isMobile) return 18.0;
    if (layout.isSmartTV) return 26.0 * layout.largeScreenScale;
    return 22.0 * layout.largeScreenScale;
  }

  double _deleteButtonSize() {
    if (layout.isPhonePortrait) return 24.0;
    if (layout.isMobile) return 28.0;
    if (layout.isSmartTV) return 40.0 * layout.largeScreenScale;
    return 34.0 * layout.largeScreenScale;
  }
}

class _HeaderCell extends StatelessWidget {
  final String title;
  final ResponsiveLayout layout;

  const _HeaderCell({required this.title, required this.layout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: layout.isPhonePortrait
            ? 5.0
            : layout.isMobile
            ? 6.0
            : 10.0,
        horizontal: layout.isPhonePortrait
            ? 2.0
            : layout.isMobile
            ? 4.0
            : 8.0,
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: layout.tableHeaderFontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _PlayerNameHeaderCell extends StatelessWidget {
  final int playerIndex;
  final GameController controller;
  final ResponsiveLayout layout;

  const _PlayerNameHeaderCell({
    required this.playerIndex,
    required this.controller,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: layout.isPhonePortrait
            ? 4.0
            : layout.isMobile
            ? 6.0
            : 10.0,
        horizontal: layout.isPhonePortrait
            ? 1.5
            : layout.isMobile
            ? 2.0
            : 8.0,
      ),
      child: TextField(
        controller: controller.playerNameControllers[playerIndex],
        textAlign: TextAlign.center,
        maxLines: 1,
        onTapOutside: (_) {
          controller.savePlayerName(playerIndex);
          FocusManager.instance.primaryFocus?.unfocus();
        },
        style: TextStyle(fontSize: layout.tableHeaderFontSize),
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(
            vertical: layout.isPhonePortrait
                ? 5.0
                : layout.isMobile
                ? 6.0
                : 12.0,
            horizontal: layout.isPhonePortrait
                ? 2.0
                : layout.isMobile
                ? 4.0
                : 8.0,
          ),
          isDense: true,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest,
        ),
        onChanged: (value) => controller.updatePlayerName(playerIndex, value),
        onEditingComplete: () => controller.savePlayerName(playerIndex),
        onSubmitted: (_) => controller.savePlayerName(playerIndex),
      ),
    );
  }
}
