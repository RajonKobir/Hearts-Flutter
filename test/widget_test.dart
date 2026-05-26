// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hearts_flutter/main.dart';
import 'package:hearts_flutter/services/game_service.dart';
import 'package:hearts_flutter/widgets/game_result_dialog.dart';

void main() {
  testWidgets('App starts on the score dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const HeartsScoreApp());
    await tester.pump();

    expect(find.text('Hearts Score Manager'), findsOneWidget);
    expect(find.byIcon(Icons.insights), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt), findsOneWidget);
  });

  testWidgets('Result dialog shows shared positions for tied scores', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameResultDialog(
            mode: 'celebration',
            results: [
              PlayerResult(rank: 1, name: 'Player 1', score: 52),
              PlayerResult(rank: 2, name: 'Player 2', score: 52),
              PlayerResult(rank: 3, name: 'Player 3', score: 104),
              PlayerResult(rank: 4, name: 'Player 4', score: 104),
            ],
          ),
        ),
      ),
    );

    expect(find.text('1st'), findsNWidgets(2));
    expect(find.text('2nd'), findsNWidgets(2));
    expect(find.text('3rd'), findsNothing);
    expect(find.text('4th'), findsNothing);
  });
}
