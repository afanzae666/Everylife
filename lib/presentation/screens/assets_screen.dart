import 'package:everylife/presentation/widgets/page_top_bar.dart';
import 'package:everylife/core/money/game_currency.dart';
import 'package:flutter/material.dart';

import '../../core/money/currency_formatter.dart';
import 'package:everylife/core/money/money.dart';
import '../../domain/character/character.dart';
import '../../domain/career/career_state.dart';
import '../../domain/character/player_asset.dart';
import '../../domain/world/country_catalog.dart';
import '../../simulation/economy/expense_breakdown.dart';
import '../widgets/animated_dialog.dart';
import '../widgets/id_card_frame.dart';
import '../widgets/info_line.dart';
import '../widgets/themed_cards.dart';

class AssetsScreen extends StatelessWidget {
const AssetsScreen({
required this.player,
required this.career,
required this.annualIncome,
required this.zoom,
this.expenses,
this.partTimeIncome = const Money.zero(),
this.benefitIncome = const Money.zero(),
this.headerBuilder,
super.key,
});

final Character player;
final CareerState career;
final Money annualIncome;
final double zoom;

/// Yearly spending, shown in the finance overlay (null: not shown).
final ExpenseBreakdown? expenses;

/// Yearly pay of a part-time job.
final Money partTimeIncome;

/// Yearly benefit of an adult without work.
final Money benefitIncome;

/// Builds the character card shown at the top of the page.
final WidgetBuilder? headerBuilder;

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

return GameCurrency.forCountryCurrency(country?.currencyCode);

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

void _showFinance(BuildContext context) {
  final careerStatus = career.retired
      ? 'Retired'
      : career.hasJob
          ? 'Employed'
          : 'Not employed';

  final spending = expenses;
  final totalIncome = Money.fromMinorUnits(
    annualIncome.minorUnits +
        partTimeIncome.minorUnits +
        benefitIncome.minorUnits,
  );
  final balance = totalIncome.minorUnits - (spending?.total ?? 0);

  showAnimatedDialog<void>(
    context: context,
      barrierDismissible: true,
    builder: (dialogContext) => IdCardFrame(
      key: const Key('finance-overlay'),
      title: 'FINANCIAL INFORMATION',
      onClose: () => Navigator.of(dialogContext).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('💰', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Personal Finance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          _financeSection(context, 'INCOME'),
          ..._ruledFinanceLines(context, [
            InfoLine(label: 'Employment', value: careerStatus),
            if (annualIncome.minorUnits > 0)
              InfoLine(
                label: career.retired ? 'Annual pension' : 'Annual salary',
                value: _formatMoney(annualIncome),
              ),
            if (partTimeIncome.minorUnits > 0)
              InfoLine(
                label: 'Part-time pay',
                value: _formatMoney(partTimeIncome),
              ),
            if (benefitIncome.minorUnits > 0)
              InfoLine(
                label: 'Unemployment benefit',
                value: _formatMoney(benefitIncome),
              ),
            InfoLine(label: 'Total income', value: _formatMoney(totalIncome)),
          ]),
          if (spending != null) ...[
            _financeSection(context, 'EXPENSES PER YEAR'),
            ..._ruledFinanceLines(context, [
              if (spending.coveredByFamily)
                const InfoLine(
                  label: '🏠 Living costs',
                  value: 'Paid by my family',
                ),
              for (final line in spending.lines)
                InfoLine(
                  label: '${line.emoji} ${line.label}',
                  value: _formatMoney(Money.fromMinorUnits(line.amount)),
                ),
              if (spending.interest > 0)
                InfoLine(
                  label: '📈 Debt interest',
                  value: _formatMoney(Money.fromMinorUnits(spending.interest)),
                ),
              InfoLine(
                label: 'Total expenses',
                value: _formatMoney(Money.fromMinorUnits(spending.total)),
              ),
              InfoLine(
                label: balance >= 0 ? 'Left over per year' : 'Short per year',
                value: _formatMoney(Money.fromMinorUnits(balance.abs())),
              ),
            ]),
          ],
          _financeSection(context, 'WEALTH'),
          ..._ruledFinanceLines(context, [
            InfoLine(label: 'Cash', value: _formatMoney(player.money)),
            InfoLine(
              label: 'Owned assets',
              value: _formatMoney(player.totalAssets - player.money),
            ),
            InfoLine(label: 'Total assets', value: _formatMoney(player.totalAssets)),
            InfoLine(label: 'Outstanding debt', value: _formatMoney(player.debt)),
            InfoLine(label: 'Net worth', value: _formatMoney(player.netWorth)),
          ]),
        ],
      ),
    ),
  );
}

Widget _financeSection(BuildContext context, String title) => Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: SectionDivider(title: title),
    );

List<Widget> _ruledFinanceLines(BuildContext context, List<Widget> lines) => [
      for (var i = 0; i < lines.length; i++) ...[
        if (i > 0)
          Divider(
            height: 10,
            thickness: 1,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
          ),
        lines[i],
      ],
    ];

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
          PageTopBar(title: 'Assets', zoom: zoom),
          Expanded(
            child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ActionCard(
            key: const Key('finance-card'),
            zoom: zoom,
            emoji: '💰',
            title: 'Finance',
            subtitle: 'View your financial situation',
            onTap: () => _showFinance(context),
          ),
          SizedBox(height: 0),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(s(4)),
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
          SizedBox(height: 0),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(s(4)),
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
          style: baseStyle,
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
