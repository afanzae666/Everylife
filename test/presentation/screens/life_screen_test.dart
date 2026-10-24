import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/presentation/screens/life_screen.dart';

void main() {
  testWidgets('Life screen shows relationship categories without Family Tree', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: LifeScreen(zoom: 1)),
    );

    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Friends'), findsOneWidget);
    expect(find.text('Partner'), findsOneWidget);
    expect(find.text('Children'), findsOneWidget);
    expect(find.text('Family Tree'), findsNothing);
    expect(find.text('Family History'), findsNothing);
  });
}
