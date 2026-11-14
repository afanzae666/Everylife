import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/career/career_state.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/player_asset.dart';
import 'package:everylife/presentation/screens/assets_screen.dart';
import 'package:everylife/presentation/widgets/themed_cards.dart';
import 'package:everylife/simulation/economy/expense_breakdown.dart';

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
          partTimeIncome: const Money.fromMinorUnits(200000),
          expenses: ExpenseBreakdown(
            lines: ExpenseBreakdown.split(1000000),
            interest: 4500,
            coveredByFamily: false,
          ),
          zoom: 1,
        ),
      ),
    );

    final financeCard = find.byKey(const Key('finance-card'));
    expect(financeCard, findsOneWidget);
    expect(find.byType(ActionCard), findsOneWidget);
    expect(find.text('Financial Overview'), findsNothing);
    expect(
      tester.getTopLeft(financeCard).dy,
      lessThan(tester.getTopLeft(find.text('Asset Categories')).dy),
    );
    await tester.ensureVisible(financeCard);

    await tester.tap(financeCard);
    await tester.pumpAndSettle();

    final financeOverlay = find.byKey(const Key('finance-overlay'));
    expect(financeOverlay, findsOneWidget);
    expect(find.text('FINANCIAL INFORMATION'), findsOneWidget);
    expect(find.text('Personal Finance'), findsOneWidget);
    expect(find.text('INCOME'), findsOneWidget);
    expect(find.text('EXPENSES PER YEAR'), findsOneWidget);
    expect(find.text('WEALTH'), findsOneWidget);
    expect(find.textContaining('Part-time pay:'), findsOneWidget);
    expect(find.textContaining('Housing:'), findsOneWidget);
    expect(find.textContaining('Food:'), findsOneWidget);
    expect(find.textContaining('Transport:'), findsOneWidget);
    expect(find.textContaining('Utilities:'), findsOneWidget);
    expect(find.textContaining('Healthcare:'), findsOneWidget);
    expect(find.textContaining('Leisure & other:'), findsOneWidget);
    expect(find.textContaining('Debt interest:'), findsOneWidget);
    expect(find.textContaining('Total expenses:'), findsOneWidget);
    expect(find.textContaining('Left over per year:'), findsOneWidget);
    expect(find.textContaining('Employment: Employed'), findsOneWidget);
    expect(find.textContaining('Annual salary:'), findsOneWidget);
    expect(find.textContaining('Cash:'), findsOneWidget);
    expect(find.textContaining('Owned assets:'), findsOneWidget);
    expect(find.textContaining('Total assets:'), findsOneWidget);
    expect(find.textContaining('Outstanding debt:'), findsOneWidget);
    expect(find.textContaining('Net worth:'), findsOneWidget);

    final closeButton = find.descendant(
      of: financeOverlay,
      matching: find.byIcon(Icons.close),
    );
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();
    expect(financeOverlay, findsNothing);
  });
}
