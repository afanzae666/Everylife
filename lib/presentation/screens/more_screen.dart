import 'package:everylife/presentation/widgets/page_top_bar.dart';
import 'package:everylife/presentation/widgets/themed_cards.dart';
import 'package:flutter/material.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({
    required this.zoom,
    this.headerBuilder,
    this.onTimeMachine,
    this.showBirthControl = false,
    this.birthControlOn = false,
    this.onBirthControl,
    super.key,
  });

  /// Shown for an adult female character.
  final bool showBirthControl;
  final bool birthControlOn;

  /// Turns birth control on or off. Returns the state that is now saved.
  final bool Function({required bool on})? onBirthControl;

  final double zoom;

  /// Builds the character card shown at the top of the page.
  final WidgetBuilder? headerBuilder;

  /// Opens the Time Machine (go back to an earlier age).
  final VoidCallback? onTimeMachine;

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  late bool _birthControl = widget.birthControlOn;

  @override
  Widget build(BuildContext context) {
    final zoom = widget.zoom;
    final headerBuilder = widget.headerBuilder;
    final onTimeMachine = widget.onTimeMachine;

    double s(double value) => value * zoom;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (headerBuilder != null) headerBuilder(context),
              PageTopBar(title: 'More', zoom: zoom),
              Expanded(
                child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ActionCard(
                key: const Key('time-machine-card'),
                zoom: zoom,
                emoji: '⏳',
                title: 'Time Machine',
                subtitle: 'Go back to an earlier age',
                onTap: onTimeMachine,
              ),
              if (widget.showBirthControl)
                ActionCard(
                  key: const Key('birth-control-card'),
                  zoom: zoom,
                  emoji: '💊',
                  title: 'Birth Control',
                  subtitle: _birthControl
                      ? 'Enabled · Greatly lowers the chance of pregnancy'
                      : 'Disabled · Greatly lowers the chance of pregnancy',
                  onTap: () {
                    final requested = !_birthControl;
                    final saved = widget.onBirthControl?.call(on: requested) ??
                        requested;
                    setState(() => _birthControl = saved);
                  },
                ),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(s(4)),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'More',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                      SizedBox(height: s(1)),
                      Text(
                        'Additional features for EveryLife.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                      SizedBox(height: s(4)),
                      const _MoreItem(
                        icon: Icons.sports_esports_outlined,
                        title: 'Activities',
                      ),
                      const _MoreItem(
                        icon: Icons.palette_outlined,
                        title: 'Hobbies',
                      ),
                      const _MoreItem(
                        icon: Icons.flight_takeoff_outlined,
                        title: 'Travel',
                      ),
                      const _MoreItem(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Other Features',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 0),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(s(4)),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.construction_outlined,
                        size: s(28),
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                      SizedBox(width: s(6)),
                      Expanded(
                        child: Text(
                          'This page is a foundation for future EveryLife systems.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ),
                    ],
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

class _MoreItem extends StatelessWidget {
  const _MoreItem({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: const Text('Future feature'),
    );
  }
}
