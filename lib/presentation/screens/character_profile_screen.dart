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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Character Information',
        ),
      ),
      body: SafeArea(
        child: _buildContent(
          context,
          zoom,
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) => value * zoom;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        s(8),
        s(4),
        s(8),
        s(8),
      ),
      children: [
        SizedBox(
          height: s(2),
        ),

        // Avatar tetap berada di luar card.
        Center(
          child: FutureBuilder<CharacterPaletteService>(
            future: CharacterPaletteService.load(),
            builder: (
              context,
              snapshot,
            ) {
              if (snapshot.connectionState != ConnectionState.done) {
                return SizedBox(
                  width: s(144),
                  height: s(180),
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.hasError || snapshot.data == null) {
                return SizedBox(
                  width: s(144),
                  height: s(180),
                );
              }

              final palette = snapshot.data!;

              final skinColor = palette.skinColor(
                character.appearance.skinTone,
              );

              final eyeColor = palette.eyeColor(
                character.appearance.eyeColor,
              );

              final hairColor = palette.hairColor(
                character.appearance.hairColor,
              );

              if (skinColor == null ||
                  eyeColor == null ||
                  hairColor == null) {
                return SizedBox(
                  width: s(84),
                  height: s(84),
                );
              }

              return CharacterAvatar(
                character: character,
                currentYear: currentYear,
                size: s(144),
                skinColor: skinColor,
                eyeColor: eyeColor,
                hairColor: hairColor,
              );
            },
          ),
        ),

        SizedBox(
          height: s(5),
        ),

        Text(
          character.fullName,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(
                fontWeight: FontWeight.w700,
              ),
          textAlign: TextAlign.center,
          softWrap: true,
        ),

        SizedBox(
          height: s(2),
        ),

        SizedBox(
          height: s(5),
        ),

        // =========================================================
        // CARD 1 — CHARACTER INFORMATION
        // =========================================================
        _ResponsiveCard(
          padding: EdgeInsets.fromLTRB(
            s(4),
            s(3),
            s(4),
            s(3),
          ),
          child: _buildBasicInformation(
            context,
            zoom,
          ),
        ),

        SizedBox(
          height: 0,
        ),

        // =========================================================
        // CARD 2 — WEALTH
        // =========================================================
        _ResponsiveCard(
          padding: EdgeInsets.fromLTRB(
            s(4),
            s(3),
            s(4),
            s(3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WEALTH',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
              ),

              SizedBox(
                height: s(4),
              ),

              _WealthRow(
                label: 'Total Assets',
                value: _formatMoney(character.totalAssets),
                zoom: zoom,
              ),

              _WealthRow(
                label: 'Debt',
                value: _formatMoney(character.debt),
                zoom: zoom,
              ),

              _WealthRow(
                label: 'Net Worth',
                value: _formatMoney(character.netWorth),
                zoom: zoom,
              ),

              SizedBox(
                height: s(5),
              ),

              SizedBox(
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onViewAssets,
                    child: const Text(
                      'View Assets →',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInformation(
    BuildContext context,
    double zoom,
  ) {
    double s(double value) => value * zoom;

    final location = character.location;
    final country = location == null
        ? null
        : CountryCatalog.findByCode(location.countryCode);
    final city = location == null ? null : CityCatalog.findById(location.cityId);
    final age = character.ageAt(currentYear);

    // "Turkey, Ankara": the city is joined to the country.
    final locationLabel = country == null
        ? null
        : city == null
            ? country.name
            : '${country.name}, ${city.name}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),

        SizedBox(
          height: s(4),
        ),

        InfoLine(label: 'Age', value: '$age'),
        InfoLine(label: 'Gender', value: character.gender.label),
        if (occupation != null && occupation!.isNotEmpty)
          InfoLine(label: 'Occupation', value: occupation!),
        if (locationLabel != null)
          InfoLine(label: 'Location', value: locationLabel),
      ],
    );
  }

}

class _ResponsiveCard extends StatelessWidget {
  const _ResponsiveCard({
    required this.padding,
    required this.child,
  });

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

class _WealthRow extends StatelessWidget {
  const _WealthRow({
    required this.label,
    required this.value,
    required this.zoom,
  });

  final String label;
  final String value;
  final double zoom;

  @override
  Widget build(
    BuildContext context,
  ) {
    double s(double value) => value * zoom;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: s(2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),

          SizedBox(
            width: s(8),
          ),

          Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
