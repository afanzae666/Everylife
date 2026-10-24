import 'package:flutter/material.dart';

class LifeScreen extends StatelessWidget {
  const LifeScreen({
    required this.zoom,
    this.onFamilyTap,
    super.key,
  });

  final double zoom;
  final VoidCallback? onFamilyTap;

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
              s(8),
              s(6),
              s(8),
              s(12),
            ),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(s(8)),
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
                      SizedBox(height: s(1)),
                      Text(
                        'The people and relationships in your life.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                      SizedBox(height: s(4)),
                      _LifeContainerItem(
                        icon: Icons.family_restroom_outlined,
                        title: 'Family',
                        onTap: onFamilyTap,
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
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        onTap == null ? 'Future life system' : 'View family members',
      ),
    );
  }
}
