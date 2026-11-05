import 'package:everylife/presentation/widgets/page_top_bar.dart';
import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    required this.zoom,
    this.headerBuilder,
    this.onTimeMachine,
    super.key,
  });

  final double zoom;

  /// Builds the character card shown at the top of the page.
  final WidgetBuilder? headerBuilder;

  /// Opens the Time Machine (go back to an earlier age).
  final VoidCallback? onTimeMachine;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (headerBuilder != null) headerBuilder!(context),
              PageTopBar(title: 'More', zoom: zoom),
              Expanded(
                child: ListView(
            padding: EdgeInsets.zero,
            children: [
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
                      _MoreItem(
                        key: const Key('more-time-machine'),
                        icon: Icons.history_toggle_off,
                        title: 'Time Machine',
                        subtitle: 'Go back to an earlier age',
                        onTap: onTimeMachine,
                      ),
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
    this.subtitle = 'Future feature',
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
