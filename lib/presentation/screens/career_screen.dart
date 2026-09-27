import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CareerScreen extends StatelessWidget {
  const CareerScreen({
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
          title: const Text('Career'),
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
              _SectionCard(
                zoom: zoom,
                icon: 'assets/icons/education.svg',
                title: 'Education',
                subtitle:
                    'Education and learning will live here.',
                children: const [
                  _ContainerItem(
                    icon: Icons.school_outlined,
                    title: 'School',
                    subtitle: 'Future education system',
                  ),
                  _ContainerItem(
                    icon: Icons.school,
                    title: 'High School',
                    subtitle: 'Future education system',
                  ),
                  _ContainerItem(
                    icon: Icons.account_balance_outlined,
                    title: 'University',
                    subtitle: 'Future education system',
                  ),
                  _ContainerItem(
                    icon: Icons.menu_book_outlined,
                    title: 'Other Education',
                    subtitle: 'Future education system',
                  ),
                ],
              ),
              SizedBox(height: s(8)),
              _SectionCard(
                zoom: zoom,
                icon: null,
                materialIcon: Icons.work_outline,
                title: 'Career',
                subtitle:
                    'Work and career systems will live here.',
                children: const [
                  _ContainerItem(
                    icon: Icons.work_outline,
                    title: 'Jobs',
                    subtitle: 'Future job system',
                  ),
                  _ContainerItem(
                    icon: Icons.business_outlined,
                    title: 'Business',
                    subtitle: 'Future business system',
                  ),
                  _ContainerItem(
                    icon: Icons.history,
                    title: 'Career History',
                    subtitle: 'Future career history',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.zoom,
    required this.title,
    required this.subtitle,
    required this.children,
    this.icon,
    this.materialIcon,
  });

  final double zoom;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final String? icon;
  final IconData? materialIcon;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(s(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null)
                  SizedBox(
                    width: s(34),
                    height: s(34),
                    child: SvgPicture.asset(
                      icon!,
                      colorFilter: ColorFilter.mode(
                        colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  )
                else
                  Icon(
                    materialIcon,
                    size: s(30),
                    color: colorScheme.primary,
                  ),
                SizedBox(width: s(8)),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium,
                      ),
                      SizedBox(height: s(1)),
                      Text(
                        subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: s(8)),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ContainerItem extends StatelessWidget {
  const _ContainerItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
