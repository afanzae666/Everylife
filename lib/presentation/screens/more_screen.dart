import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    required this.zoom,
    super.key,
  });

  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(zoom),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('More'),
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              s(12),
              s(8),
              s(12),
              s(16),
            ),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(s(10)),
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
                      SizedBox(height: s(2)),
                      Text(
                        'Additional features for EveryLife.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                      SizedBox(height: s(8)),
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
              SizedBox(height: s(8)),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(s(10)),
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
                      SizedBox(width: s(8)),
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
      subtitle: const Text(
        'Future feature',
      ),
    );
  }
}
