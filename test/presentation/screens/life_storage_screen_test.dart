import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/core/result/result.dart';
import 'package:everylife/data/repositories/save_repository.dart';
import 'package:everylife/domain/character/character.dart';
import 'package:everylife/domain/time/simulation_clock.dart';
import 'package:everylife/domain/world/world_state.dart';
import 'package:everylife/presentation/screens/life_storage_screen.dart';

SaveData _life(String first, String last) {
  return SaveData(
    state: WorldState(
      clock: const SimulationClock(currentYear: 2040),
      player: Character.create(
        id: 'p-$first',
        firstName: first,
        lastName: last,
        birthYear: 2026,
      ),
      events: const [],
    ),
    randomState: 1,
    nextTickId: 1,
  );
}

void main() {
  group('LifeStorageScreen', () {
    late Map<SaveSlot, SaveData?> store;
    late List<SaveSlot> loaded;
    late List<SaveSlot> deleted;

    setUp(() {
      store = {
        SaveSlot.slot1: _life('Alice', 'Smith'),
        SaveSlot.slot3: _life('Bob', 'Jones'),
      };
      loaded = [];
      deleted = [];
    });

    Future<void> openScreen(
      WidgetTester tester, {
      SaveSlot? activeSlot,
      bool isFull = false,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LifeStorageScreen(
            zoom: 1,
            activeSlot: activeSlot,
            isFull: isFull,
            onRead: (slot) async => store[slot],
            onLoad: (slot) async {
              loaded.add(slot);
              return const Success(null);
            },
            onDelete: (slot) async {
              deleted.add(slot);
              store.remove(slot);
              return const Success(null);
            },
            onGameStateChanged: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('lists every life with its name and empty slots', (
      tester,
    ) async {
      await openScreen(tester);

      expect(find.text('Life Storage'), findsOneWidget);
      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('Bob Jones'), findsOneWidget);
      expect(find.text('Slot 2: empty'), findsOneWidget);
      expect(find.textContaining('2 / 10'), findsOneWidget);
    });

    testWidgets('tapping a life asks before continuing it', (tester) async {
      await openScreen(tester, activeSlot: SaveSlot.slot1);

      await tester.tap(find.byKey(const Key('life-slot-slot3')));
      await tester.pumpAndSettle();

      expect(find.text('Continue this life?'), findsOneWidget);
      expect(loaded, isEmpty);

      await tester.tap(find.byKey(const Key('continue-life-confirm')));
      await tester.pumpAndSettle();

      expect(loaded, [SaveSlot.slot3]);
    });

    testWidgets('cancelling the overlay keeps the current life', (
      tester,
    ) async {
      await openScreen(tester, activeSlot: SaveSlot.slot1);

      await tester.tap(find.byKey(const Key('life-slot-slot3')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      expect(loaded, isEmpty);
      expect(find.text('Life Storage'), findsOneWidget);
    });

    testWidgets('deleting a life frees its slot after confirming', (
      tester,
    ) async {
      await openScreen(tester, activeSlot: SaveSlot.slot1);

      await tester.tap(find.byTooltip('Delete').last);
      await tester.pumpAndSettle();

      expect(find.text('Delete this life?'), findsOneWidget);

      await tester.tap(find.byKey(const Key('delete-life-confirm')));
      await tester.pumpAndSettle();

      expect(deleted, [SaveSlot.slot3]);
      expect(find.text('Bob Jones'), findsNothing);
      expect(find.text('Slot 3: empty'), findsOneWidget);
    });

    testWidgets('shows a notice when storage is full', (tester) async {
      await openScreen(tester, isFull: true);

      expect(
        find.byKey(const Key('life-storage-full-banner')),
        findsOneWidget,
      );
    });
  });
}
