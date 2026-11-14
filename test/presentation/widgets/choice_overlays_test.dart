import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:everylife/presentation/widgets/animated_dialog.dart';
import 'package:everylife/presentation/widgets/notice_overlay.dart';
import 'package:everylife/presentation/widgets/themed_cards.dart';

Future<void> _pumpApp(
  WidgetTester tester,
  Future<void> Function(BuildContext context) onOpen,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            key: const Key('open'),
            onPressed: () => onOpen(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.byKey(const Key('open')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a choice stays until it is made', (tester) async {
    await _pumpApp(
      tester,
      (context) => showAnimatedDialog<bool>(
        context: context,
        builder: (dialogContext) => ThemedDialog(
          closable: false,
          title: 'NEW FRIEND?',
          child: Row(
            children: [
              TextButton(
                key: const Key('yes'),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('YES'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('NEW FRIEND?'), findsOneWidget);
    expect(find.byTooltip('Close'), findsNothing);

    // A tap anywhere outside does nothing.
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('NEW FRIEND?'), findsOneWidget);

    // Neither does the back button.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('NEW FRIEND?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('yes')));
    await tester.pumpAndSettle();

    expect(find.text('NEW FRIEND?'), findsNothing);
  });

  testWidgets('an animated dialog ignores a stray tap by default', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      (context) => showAnimatedDialog<void>(
        context: context,
        builder: (_) => const Dialog(child: Text('A CHOICE')),
      ),
    );

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('A CHOICE'), findsOneWidget);
  });

  testWidgets('information can still opt in to closing on a tap', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      (context) => showAnimatedDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => const Dialog(child: Text('JUST INFO')),
      ),
    );

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.text('JUST INFO'), findsNothing);
  });

  testWidgets('a notice is an overlay that closes on a tap', (tester) async {
    await _pumpApp(
      tester,
      (context) => showNotice(context, 'You are in!'),
    );

    expect(find.byKey(const Key('notice-overlay')), findsOneWidget);
    expect(find.text('You are in!'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('notice-overlay')), findsNothing);
  });

  testWidgets('a problem notice says it was not possible', (tester) async {
    await _pumpApp(
      tester,
      (context) => showNotice(context, 'I need a diploma.', problem: true),
    );

    expect(find.text('Not Possible'), findsOneWidget);
  });
}
