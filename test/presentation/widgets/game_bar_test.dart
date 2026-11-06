import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/presentation/widgets/game_bar.dart';

void main() {
  testWidgets('GameBar is half as wide as its space and keeps its value', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200,
            child: GameBar(value: 0.4, barKey: Key('bar')),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('bar'))).width, 100);
    expect(
      tester.widget<LinearProgressIndicator>(find.byKey(const Key('bar'))).value,
      0.4,
    );
  });
}
