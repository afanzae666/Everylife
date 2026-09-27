import 'package:flutter/material.dart';

class LifeScreen extends StatelessWidget {
  const LifeScreen({
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
          title: const Text('Life'),
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
                        'Life',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge,
                      ),
                      SizedBox(height: s(2)),
                      Text(
                        'The people and relationships in your life.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                      SizedBox(height: s(8)),
                      const _LifeContainerItem(
                        icon: Icons.family_restroom_outlined,
                        title: 'Family',
                      ),
                      const _LifeContainerItem(
                        icon: Icons.people_outline,
                        title: 'Friends',
                      ),
                      const _LifeContainerItem(
                        icon: Icons.favorite_border,
                        title: 'Partner',
                      ),
                      const _LifeContainerItem(
                        icon: Icons.child_care_outlined,
                        title: 'Children',
                      ),
                      const _LifeContainerItem(
                        icon: Icons.people_alt_outlined,
                        title: 'Relationships',
                      ),
                      const _LifeContainerItem(
                        icon: Icons.account_tree_outlined,
                        title: 'Family History',
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
                        Icons.timeline_outlined,
                        size: s(28),
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                      SizedBox(width: s(8)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Family Tree',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            SizedBox(height: s(2)),
                            Text(
                              'A future home for family records and the family tree.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall,
                            ),
                          ],
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

class _LifeContainerItem extends StatelessWidget {
  const _LifeContainerItem({
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
        'Future life system',
      ),
    );
  }
}
