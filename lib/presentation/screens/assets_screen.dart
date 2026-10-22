import 'package:flutter/material.dart';

import '../../core/money/currency_formatter.dart';
import 'package:everylife/core/money/money.dart';
import '../../domain/character/character.dart';
import '../../domain/character/player_asset.dart';
import '../../domain/world/country_catalog.dart';

class AssetsScreen extends StatelessWidget {
const AssetsScreen({
required this.player,
required this.zoom,
super.key,
});

final Character player;
final double zoom;

static const List<PlayerAssetType> _assetTypes = [
PlayerAssetType.property,
PlayerAssetType.business,
PlayerAssetType.investment,
PlayerAssetType.vehicle,
PlayerAssetType.valuable,
PlayerAssetType.other,
];

String _getCurrencyCode() {
final countryCode = player.location?.countryCode ?? '';
final country = CountryCatalog.findByCode(countryCode);

return country?.currencyCode ?? 'USD';

}

String _formatMoney(Money amount) {
return CurrencyFormatter.format(
amount,
currencyCode: _getCurrencyCode(),
);
}

String _categoryLabel(PlayerAssetType type) {
switch (type) {
case PlayerAssetType.property:
return 'Property';
case PlayerAssetType.business:
return 'Businesses';
case PlayerAssetType.investment:
return 'Investments';
case PlayerAssetType.vehicle:
return 'Vehicles';
case PlayerAssetType.valuable:
return 'Valuables';
case PlayerAssetType.other:
return 'Other Assets';
}
}

IconData _categoryIcon(PlayerAssetType type) {
switch (type) {
case PlayerAssetType.property:
return Icons.home_outlined;
case PlayerAssetType.business:
return Icons.business_outlined;
case PlayerAssetType.investment:
return Icons.trending_up;
case PlayerAssetType.vehicle:
return Icons.directions_car_outlined;
case PlayerAssetType.valuable:
return Icons.diamond_outlined;
case PlayerAssetType.other:
return Icons.inventory_2_outlined;
}
}

List<PlayerAsset> _assetsOfType(PlayerAssetType type) {
return player.assets
.where((asset) => asset.type == type)
.toList(growable: false);
}

Money _totalValueOf(List<PlayerAsset> assets) {
var total = const Money.zero();

for (final asset in assets) {
  total = total + asset.value;
}

return total;

}

@override
Widget build(BuildContext context) {
double s(double value) => value * zoom;

final cashValue = _formatMoney(player.money);
final totalAssetsValue = _formatMoney(player.totalAssets);
final debtValue = _formatMoney(player.debt);

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
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: s(1)),
          Text(
            'Everything your character owns.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: s(4)),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(s(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Financial Overview',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: s(3)),
                  _AssetRow(
                    label: 'Total Assets',
                    value: totalAssetsValue,
                    zoom: zoom,
                    emphasized: true,
                  ),
                  _AssetRow(
                    label: 'Cash',
                    value: cashValue,
                    zoom: zoom,
                  ),
                  _AssetRow(
                    label: 'Debt',
                    value: debtValue,
                    zoom: zoom,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: s(3)),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(s(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asset Categories',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: s(3)),
                  for (final type in _assetTypes)
                    _AssetRow(
                      label: _categoryLabel(type),
                      value: _assetsOfType(type).isEmpty
                          ? 'None'
                          : _formatMoney(
                              _totalValueOf(_assetsOfType(type)),
                            ),
                      zoom: zoom,
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: s(3)),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(s(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Owned Items',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: s(2)),
                  if (player.assets.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: s(6),
                      ),
                      child: Center(
                        child: Text(
                          'You do not own any assets yet.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ),
                    )
                  else
                    for (final asset in player.assets)
                      _OwnedAssetTile(
                        asset: asset,
                        categoryLabel: _categoryLabel(asset.type),
                        icon: _categoryIcon(asset.type),
                        formattedValue: _formatMoney(asset.value),
                        zoom: zoom,
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
this.emphasized = false,
});

final String label;
final String value;
final double zoom;
final bool emphasized;

@override
Widget build(BuildContext context) {
double s(double value) => value * zoom;

final baseStyle = Theme.of(context).textTheme.bodySmall;

return Padding(
  padding: EdgeInsets.symmetric(
    vertical: s(1),
  ),
  child: Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: emphasized
              ? baseStyle?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : baseStyle,
        ),
      ),
      SizedBox(width: s(6)),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          overflow: TextOverflow.ellipsis,
          style: baseStyle?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  ),
);

}
}

class _OwnedAssetTile extends StatelessWidget {
const _OwnedAssetTile({
required this.asset,
required this.categoryLabel,
required this.icon,
required this.formattedValue,
required this.zoom,
});

final PlayerAsset asset;
final String categoryLabel;
final IconData icon;
final String formattedValue;
final double zoom;

@override
Widget build(BuildContext context) {
double s(double value) => value * zoom;

return ListTile(
  dense: true,
  contentPadding: EdgeInsets.zero,
  leading: Icon(
    icon,
    size: s(22),
  ),
  title: Text(
    asset.name,
    style: Theme.of(context).textTheme.bodyMedium,
  ),
  subtitle: Text(categoryLabel),
  trailing: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: s(130),
    ),
    child: Text(
      formattedValue,
      textAlign: TextAlign.end,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    ),
  ),
);

}
}
