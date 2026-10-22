
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/money/money.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/character/player_asset.dart';
import 'package:everylife/presentation/screens/character_profile_screen.dart';

void main() {
  testWidgets(
    'displays total assets, debt, and net worth correctly',
    (tester) async {
      final character = Character.create(
        id: 'profile-financial-test',
        firstName: 'Alex',
        lastName: 'Morgan',
        birthYear: 2000,
      ).copyWith(
        money: const Money.fromMinorUnits(125000),
        assets: const <PlayerAsset>[
          PlayerAsset(
            id: 'house-1',
            name: 'House',
            type: PlayerAssetType.property,
            value: Money.fromMinorUnits(250000),
          ),
        ],
        debt: const Money.fromMinorUnits(75000),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CharacterProfileScreen(
            character: character,
            currentYear: 2026,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Total Assets = cash + owned assets = $3,750.
      expect(
        character.totalAssets,
        const Money.fromMinorUnits(375000),
      );

      // Debt remains separate from total assets.
      expect(
        character.debt,
        const Money.fromMinorUnits(75000),
      );

      // Net Worth = total assets - debt = $3,000.
      expect(
        character.netWorth,
        const Money.fromMinorUnits(300000),
      );

      expect(find.text('Total Assets'), findsOneWidget);
      expect(find.text('Debt'), findsOneWidget);
      expect(find.text('Net Worth'), findsOneWidget);

      expect(find.text('\$3,750'), findsOneWidget);
      expect(find.text('\$750'), findsOneWidget);
      expect(find.text('\$3,000'), findsOneWidget);
    },
  );
}
