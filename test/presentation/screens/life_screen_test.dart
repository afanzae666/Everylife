import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everylife/presentation/screens/life_screen.dart';

void main() {
  testWidgets('Life screen has family navigation and no Family Tree', (
    tester,
  ) async {
    var familyTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LifeScreen(
          zoom: 1,
          onFamilyTap: () => familyTapped = true,
        ),
      ),
    );

    expect(find.text('Family Tree'), findsNothing);
    expect(find.text('Family History'), findsNothing);
    expect(find.text('Family'), findsOneWidget);

    await tester.tap(find.text('Family'));
    expect(familyTapped, isTrue);
  });
}
