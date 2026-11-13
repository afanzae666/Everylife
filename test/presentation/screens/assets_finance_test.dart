import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/career/career_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/player_asset.dart';
import 'package:everylife/presentation/screens/assets_screen.dart';
import 'package:everylife/presentation/widgets/themed_cards.dart';

void main() {
  testWidgets('Finance card opens the financial information overlay', (
    tester,
  ) async {
    final player = Character.create(
      id: 'finance-test-player',
      firstName: 'Alex',
      lastName: 'Morgan',
      birthYear: 2000,
    ).copyWith(
      money: const Money.fromMinorUnits(125000),
      assets: const <PlayerAsset>[
        PlayerAsset(
          id: 'finance-house',
          name: 'House',
          type: PlayerAssetType.property,
          value: Money.fromMinorUnits(250000),
        ),
      ],
      debt: const Money.fromMinorUnits(75000),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AssetsScreen(
          player: player,
          career: const CareerState(
            jobId: 'cashier',
            salaryBase: 1000000,
          ),
          annualIncome: const Money.fromMinorUnits(1000000),
          zoom: 1,
        ),
      ),
    );

    final financeCard = find.byKey(const Key('finance-card'));
    expect(financeCard, findsOneWidget);
    expect(find.byType(ActionCard), findsOneWidget);
    await tester.ensureVisible(financeCard);

    await tester.tap(financeCard);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('finance-overlay')), findsOneWidget);
    expect(find.text('FINANCIAL INFORMATION'), findsOneWidget);
    expect(find.text('Personal Finance'), findsOneWidget);
    expect(find.textContaining('Employment: Employed'), findsOneWidget);
    expect(find.textContaining('Annual salary:'), findsOneWidget);
    expect(find.textContaining('Cash:'), findsOneWidget);
    expect(find.textContaining('Owned assets:'), findsOneWidget);
    expect(find.textContaining('Total assets:'), findsOneWidget);
    expect(find.textContaining('Outstanding debt:'), findsOneWidget);
    expect(find.textContaining('Net worth:'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('finance-overlay')), findsNothing);
  });
}
