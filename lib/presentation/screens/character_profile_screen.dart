import 'package:everylife/core/money/game_currency.dart';
import 'package:flutter/material.dart';
import 'package:everylife/core/money/money.dart';

import '../../data/services/character_palette_service.dart';
import '../../core/money/currency_formatter.dart';
import '../../domain/world/country_catalog.dart';
import '../../domain/world/city_catalog.dart';
import '../../domain/character/character.dart';
import '../../domain/character/gender.dart';
import '../widgets/character_avatar.dart';
import '../widgets/info_line.dart';
import '../widgets/life_labels.dart' show countryFlag;

class CharacterProfileScreen extends StatelessWidget {
  const CharacterProfileScreen({
    required this.character,
    required this.currentYear,
    this.uiScaleController,
    this.onViewAssets,
    this.occupation,
    super.key,
  });

  final Character character;
  final int currentYear;
  final ValueNotifier<double>? uiScaleController;
  final VoidCallback? onViewAssets;

  /// What the character does (job, school stage, ...), when known.
  final String? occupation;

  String _getCurrencyCode() {
    final countryCode = character.location?.countryCode ?? '';
    final country = CountryCatalog.findByCode(countryCode);
    return GameCurrency.forCountryCurrency(country?.currencyCode);
  }

  String _formatMoney(Money amount) {
    return CurrencyFormatter.format(
      amount,
      currencyCode: _getCurrencyCode(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = uiScaleController;

    if (controller == null) {
      return _buildScaledPage(context, 1.0);
    }

    return ValueListenableBuilder<double>(
      valueListenable: controller,
      builder: (context, zoom, _) {
        return _buildScaledPage(context, zoom);
      },
    );
  }

  Widget _buildScaledPage(
    BuildContext context,
    double zoom,
  ) {
    final mediaQuery = MediaQuery.of(context);

    final scaledMediaQuery = mediaQuery.copyWith(
      textScaler: TextScaler.linear(zoom),
    );

    return MediaQuery(
      data: scaledMediaQuery,
      child: _buildScaffold(
        context,
        zoom,
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    double zoom,
  ) {
    final scheme = Theme.of(context).colorScheme;
    double s(double value) => value * zoom;

    final location = character.location;
    final flag = countryFlag(location?.countryCode);
    final job = occupation;

    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: s(6)),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.primary, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ID strip: title and close button.
                Container(
                  color: scheme.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: s(6),
                    vertical: s(3),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Character Information',
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                        ),
                      ),
                      InkWell(
                        key: const Key('profile-close'),
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Padding(
                          padding: EdgeInsets.all(s(2)),
                          child: Icon(
                            Icons.close,
                            size: s(18),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(s(6)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The whole avatar, never cropped.
                      Container(
                        padding: EdgeInsets.all(s(3)),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: scheme.primary.withValues(alpha: 0.45),
                          ),
                        ),
                        child: _buildAvatar(zoom),
                      ),
                      SizedBox(width: s(7)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (flag.isNotEmpty) ...[
                                  Text(flag, style: TextStyle(fontSize: s(18))),
                                  SizedBox(width: s(3)),
                                ],
                                Expanded(
                                  child: Text(
                                    character.fullName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: s(3)),
                            _sectionTitle(context, 'Basic Information'),
                            SizedBox(height: s(2)),
                            ..._withLines(context, _infoLines(job)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                _dashedDivider(context),
                Padding(
                  padding: EdgeInsets.all(s(6)),
                  child: _buildWealth(context, zoom),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// "◆ TITLE ———": a green diamond, the title, and a line to the edge.
  Widget _sectionTitle(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text('◆', style: TextStyle(fontSize: 8, color: scheme.primary)),
        const SizedBox(width: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Container(
            height: 1.5,
            color: scheme.primary.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }

  /// Puts a thin faded line between the information lines.
  List<Widget> _withLines(BuildContext context, List<Widget> lines) {
    final color =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.18);

    return [
      for (var i = 0; i < lines.length; i++) ...[
        if (i > 0) Container(height: 1, color: color),
        lines[i],
      ],
    ];
  }

  Widget _dashedDivider(BuildContext context) {
    final color = Theme.of(context).dividerColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 8).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (var i = 0; i < count; i++)
              SizedBox(width: 4, height: 1.5, child: ColoredBox(color: color)),
          ],
        );
      },
    );
  }

  List<Widget> _infoLines(String? job) {
    final location = character.location;
    final country = location == null
        ? null
        : CountryCatalog.findByCode(location.countryCode);
    final city = location == null ? null : CityCatalog.findById(location.cityId);

    // "Turkey, Ankara": the city is joined to the country.
    final locationLabel = country == null
        ? null
        : city == null
            ? country.name
            : '${country.name}, ${city.name}';

    return [
      InfoLine(label: 'Age', value: '${character.ageAt(currentYear)}'),
      InfoLine(label: 'Gender', value: character.gender.label),
      if (job != null && job.isNotEmpty)
        InfoLine(label: 'Occupation', value: job),
      if (locationLabel != null)
        InfoLine(label: 'Location', value: locationLabel),
    ];
  }

  Widget _buildAvatar(double zoom) {
    double s(double value) => value * zoom;

    return FutureBuilder<CharacterPaletteService>(
      future: CharacterPaletteService.load(),
      builder: (context, snapshot) {
        final size = s(96);
        final box = SizedBox(width: size, height: size * 1.25);

        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            width: size,
            height: size * 1.25,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final palette = snapshot.data;

        if (snapshot.hasError || palette == null) {
          return box;
        }

        final skinColor = palette.skinColor(character.appearance.skinTone);
        final eyeColor = palette.eyeColor(character.appearance.eyeColor);
        final hairColor = palette.hairColor(character.appearance.hairColor);

        if (skinColor == null || eyeColor == null || hairColor == null) {
          return box;
        }

        return CharacterAvatar(
          character: character,
          currentYear: currentYear,
          size: size,
          skinColor: skinColor,
          eyeColor: eyeColor,
          hairColor: hairColor,
        );
      },
    );
  }

  Widget _buildWealth(BuildContext context, double zoom) {
    double s(double value) => value * zoom;

    final scheme = Theme.of(context).colorScheme;

    Widget line() => Container(
          width: 1,
          height: s(26),
          color: scheme.primary.withValues(alpha: 0.35),
        );

    Widget cell(String label, String value) {
      return Expanded(
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(context, 'WEALTH'),
        SizedBox(height: s(3)),
        Container(
          padding: EdgeInsets.symmetric(vertical: s(4)),
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              cell('Total Assets', _formatMoney(character.totalAssets)),
              line(),
              cell('Debt', _formatMoney(character.debt)),
              line(),
              cell('Net Worth', _formatMoney(character.netWorth)),
            ],
          ),
        ),
        SizedBox(height: s(5)),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: onViewAssets,
            child: const Text('View Assets →'),
          ),
        ),
      ],
    );
  }
}
