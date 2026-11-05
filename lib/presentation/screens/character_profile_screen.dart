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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: scheme.primary.withValues(alpha: 0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.28),
              blurRadius: 28,
              spreadRadius: 1,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildHeader(context, zoom),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(s(6), s(6), s(6), s(8)),
                children: [
                  _buildBasicInformation(context, zoom),
                  SizedBox(height: s(5)),
                  _buildWealth(context, zoom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Green gradient banner: title, close button, avatar in a glowing ring,
  /// name with flag and an occupation chip.
  Widget _buildHeader(BuildContext context, double zoom) {
    double s(double value) => value * zoom;

    final scheme = Theme.of(context).colorScheme;
    final location = character.location;
    final flag = countryFlag(location?.countryCode);
    final job = occupation;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(Colors.black.withValues(alpha: 0.35), scheme.primary),
            scheme.primary,
          ],
        ),
      ),
      padding: EdgeInsets.fromLTRB(s(6), s(4), s(6), s(6)),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: s(22)),
              Expanded(
                child: Text(
                  'Character Information',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                ),
              ),
              InkWell(
                key: const Key('profile-close'),
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).maybePop(),
                child: Container(
                  width: s(22),
                  height: s(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: Icon(Icons.close, size: s(14), color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: s(3)),
          Container(
            padding: EdgeInsets.all(s(3)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.35),
                  blurRadius: 22,
                ),
              ],
            ),
            child: ClipOval(child: _buildAvatar(zoom)),
          ),
          SizedBox(height: s(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (flag.isNotEmpty) ...[
                Text(flag, style: TextStyle(fontSize: s(20))),
                SizedBox(width: s(4)),
              ],
              Flexible(
                child: Text(
                  character.fullName,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          if (job != null && job.isNotEmpty) ...[
            SizedBox(height: s(3)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: s(8), vertical: s(2)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
              ),
              child: Text(
                job,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(double zoom) {
    double s(double value) => value * zoom;

    return FutureBuilder<CharacterPaletteService>(
      future: CharacterPaletteService.load(),
      builder: (context, snapshot) {
        final box = s(104);

        if (snapshot.connectionState != ConnectionState.done) {
          return SizedBox(
            width: box,
            height: box,
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
          return SizedBox(width: box, height: box);
        }

        final skinColor = palette.skinColor(character.appearance.skinTone);
        final eyeColor = palette.eyeColor(character.appearance.eyeColor);
        final hairColor = palette.hairColor(character.appearance.hairColor);

        if (skinColor == null || eyeColor == null || hairColor == null) {
          return SizedBox(width: box, height: box);
        }

        return SizedBox(
          width: box,
          height: box,
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            child: CharacterAvatar(
              character: character,
              currentYear: currentYear,
              size: s(144),
              skinColor: skinColor,
              eyeColor: eyeColor,
              hairColor: hairColor,
            ),
          ),
        );
      },
    );
  }

  Widget _section(BuildContext context, double zoom, String title, Widget child) {
    double s(double value) => value * zoom;

    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(s(5)),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: scheme.primary,
                ),
          ),
          SizedBox(height: s(3)),
          child,
        ],
      ),
    );
  }

  Widget _buildWealth(BuildContext context, double zoom) {
    double s(double value) => value * zoom;

    Widget tile(String emoji, String label, String value) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: s(4), horizontal: s(2)),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: TextStyle(fontSize: s(18))),
              SizedBox(height: s(1)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: s(1)),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _section(
      context,
      zoom,
      'WEALTH',
      Column(
        children: [
          Row(
            children: [
              tile('💰', 'Total Assets', _formatMoney(character.totalAssets)),
              SizedBox(width: s(3)),
              tile('💳', 'Debt', _formatMoney(character.debt)),
              SizedBox(width: s(3)),
              tile('📈', 'Net Worth', _formatMoney(character.netWorth)),
            ],
          ),
          SizedBox(height: s(4)),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: onViewAssets,
              child: const Text('View Assets →'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformation(
    BuildContext context,
    double zoom,
  ) {
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

    return _section(
      context,
      zoom,
      'Basic Information',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoLine(label: 'Age', value: '$age'),
          InfoLine(label: 'Gender', value: character.gender.label),
          if (occupation != null && occupation!.isNotEmpty)
            InfoLine(label: 'Occupation', value: occupation!),
          if (locationLabel != null)
            InfoLine(label: 'Location', value: locationLabel),
        ],
      ),
    );
  }
}
