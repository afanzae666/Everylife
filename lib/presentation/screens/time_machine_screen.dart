import 'package:flutter/material.dart';

import 'package:everylife/presentation/widgets/page_top_bar.dart';

import '../../core/result/result.dart';
import '../widgets/animated_dialog.dart';
import '../widgets/notice_overlay.dart';

/// Go back to an earlier age of the current life. Only the past can be
/// visited, and everything after the chosen age is undone.
class TimeMachineScreen extends StatefulWidget {
  const TimeMachineScreen({
    required this.zoom,
    required this.readAges,
    required this.onRewind,
    this.headerBuilder,
    super.key,
  });

  final double zoom;

  /// The ages that can be visited, newest first.
  final List<int> Function() readAges;

  final Result<void> Function(int age) onRewind;
  final WidgetBuilder? headerBuilder;

  @override
  State<TimeMachineScreen> createState() => _TimeMachineScreenState();
}

class _TimeMachineScreenState extends State<TimeMachineScreen> {
  double s(double value) => value * widget.zoom;

  Future<void> _travel(int age) async {
    final confirmed = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('time-machine-dialog'),
        title: Text('Go back to age $age?'),
        content: const Text(
          'Everything that happened after that age will be undone. '
          'Your choices can play out differently this time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            key: const Key('time-machine-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('GO BACK'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final result = widget.onRewind(age);

    if (!mounted) {
      return;
    }

    if (result case Failure<void>(:final message)) {
      setState(() {});
      showNotice(context, message, problem: true);
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ages = widget.readAges();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.headerBuilder != null) widget.headerBuilder!(context),
              PageTopBar(title: 'Time Machine', zoom: widget.zoom),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(s(8)),
                      child: Text(
                        ages.isEmpty
                            ? 'Nothing to revisit yet. Live a little more '
                                'and come back.'
                            : 'Pick an age to return to. Only the past can '
                                'be visited.',
                        key: const Key('time-machine-note'),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    for (final age in ages)
                      Card(
                        key: Key('time-machine-age-$age'),
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                          side: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.55),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _travel(age),
                          child: Padding(
                            padding: EdgeInsets.all(s(8)),
                            child: Row(
                              children: [
                                Text('🕰️', style: TextStyle(fontSize: s(22))),
                                SizedBox(width: s(8)),
                                Expanded(
                                  child: Text(
                                    'Age $age',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
