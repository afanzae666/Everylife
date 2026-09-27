import 'package:flutter/material.dart';

class AssetsScreen extends StatelessWidget {
  const AssetsScreen({
    required this.player,
    required this.zoom,
    super.key,
  });

  final dynamic player;
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
          title: const Text('Assets'),
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
              Text(
                'Assets',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),
              SizedBox(height: s(1)),
              Text(
                'Everything your character owns.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
              ),
              SizedBox(height: s(4)),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(s(8)),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Assets',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall,
                      ),
                      SizedBox(height: s(3)),
                      _AssetRow(
                        label: 'Cash',
                        value: player.money.toString(),
                        zoom: zoom,
                      ),
                      _AssetRow(
                        label: 'Property',
                        value: 'None',
                        zoom: zoom,
                      ),
                      _AssetRow(
                        label: 'Businesses',
                        value: 'None',
                        zoom: zoom,
                      ),
                      _AssetRow(
                        label: 'Investments',
                        value: 'None',
                        zoom: zoom,
                      ),
                      _AssetRow(
                        label: 'Vehicles',
                        value: 'None',
                        zoom: zoom,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: s(2)),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: EdgeInsets.all(s(8)),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Future Asset Categories',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall,
                      ),
                      SizedBox(height: s(2)),
                      const _FutureAssetItem(
                        icon: Icons.home_outlined,
                        title: 'Houses',
                      ),
                      const _FutureAssetItem(
                        icon: Icons.directions_car_outlined,
                        title: 'Vehicles',
                      ),
                      const _FutureAssetItem(
                        icon: Icons.business_outlined,
                        title: 'Companies',
                      ),
                      const _FutureAssetItem(
                        icon: Icons.trending_up,
                        title: 'Investments',
                      ),
                      const _FutureAssetItem(
                        icon: Icons.inventory_2_outlined,
                        title: 'Other Assets',
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

class _AssetRow extends StatelessWidget {
  const _AssetRow({
    required this.label,
    required this.value,
    required this.zoom,
  });

  final String label;
  final String value;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: s(1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ),
          SizedBox(width: s(6)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FutureAssetItem extends StatelessWidget {
  const _FutureAssetItem({
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
        'Future asset system',
      ),
    );
  }
}
