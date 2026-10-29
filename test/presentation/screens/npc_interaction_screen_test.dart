import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/core/result/result.dart';
import 'package:everylife/domain/event/npc_interaction_outcome.dart';
import 'package:everylife/presentation/screens/npc_interaction_screen.dart';

void main() {
  Widget buildScreen(int age) => MaterialApp(
        home: NpcInteractionScreen(
          npcId: 'npc-test',
          name: 'Marshall Royce',
          relationship: 'father',
          relationshipPercent: 50,
          playerAge: age,
          onInteraction: ({required npcId, required action}) =>
              Failure<NpcInteractionOutcome>('Not used in this test.'),
        ),
      );

  testWidgets('infant has no visible interaction actions', (tester) async {
    await tester.pumpWidget(buildScreen(1));

    expect(find.text('Interactions'), findsNothing);
    expect(find.text('Talk'), findsNothing);
    expect(find.text('Spend Time'), findsNothing);
    expect(find.text('Compliment'), findsNothing);
    expect(find.text('Help'), findsNothing);
    expect(find.text('Argue'), findsNothing);
  });

  testWidgets('toddler and child only see basic interactions', (tester) async {
    await tester.pumpWidget(buildScreen(4));

    expect(find.text('Talk'), findsOneWidget);
    expect(find.text('Spend Time'), findsOneWidget);
    expect(find.text('Compliment'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Argue'), findsNothing);
  });

  testWidgets('teen and older see the existing full interaction set', (tester) async {
    await tester.pumpWidget(buildScreen(15));

    expect(find.text('Talk'), findsOneWidget);
    expect(find.text('Spend Time'), findsOneWidget);
    expect(find.text('Compliment'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Argue'), findsOneWidget);
    expect(find.text('FATHER'), findsOneWidget);
    expect(find.text('(Father)'), findsNothing);
  });
}
