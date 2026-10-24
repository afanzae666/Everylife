import 'package:flutter/material.dart';

import '../../core/money/currency_formatter.dart';
import '../../core/money/money.dart';
import '../../data/services/character_palette_service.dart';
import '../../domain/character/character.dart';
import '../../domain/character/character_stats.dart';
import '../../domain/character/appearance.dart';
import '../../domain/family/family_household.dart';
import '../../domain/family/parent_npc.dart';
import '../widgets/character_avatar.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({
    required this.household,
    required this.currentYear,
    required this.zoom,
    required this.currencyCode,
    super.key,
  });

  final FamilyHousehold? household;
  final int currentYear;
  final double zoom;
  final String currencyCode;

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  late final Future<CharacterPaletteService> _paletteFuture;

  @override
  void initState() {
    super.initState();
    _paletteFuture = CharacterPaletteService.load();
  }

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * widget.zoom;
    final household = widget.household;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.zoom),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Family')),
        body: SafeArea(
          child: household == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Family information is not available in this save.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.all(s(12)),
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(s(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Parents',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            SizedBox(height: s(4)),
                            Text(
                              'Meet the family members present in your starting life.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            SizedBox(height: s(10)),
                            if (household.parents.isEmpty)
                              const Text('No parent records are available.')
                            else
                              ...household.parents.map(
                                (parent) => Padding(
                                  padding: EdgeInsets.only(bottom: s(8)),
                                  child: _ParentCard(
                                    parent: parent,
                                    currentYear: widget.currentYear,
                                    zoom: widget.zoom,
                                    paletteFuture: _paletteFuture,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: s(8)),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: EdgeInsets.all(s(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Household',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: s(6)),
                            _InfoRow(
                              label: 'Housing',
                              value: _housingLabel(household.housingStatus),
                            ),
                            _InfoRow(
                              label: 'Household savings',
                              value: _money(household.cashSavings),
                            ),
                            _InfoRow(
                              label: 'Annual income',
                              value: _money(household.annualIncome),
                            ),
                            _InfoRow(
                              label: 'Annual living costs',
                              value: _money(household.annualLivingCosts),
                            ),
                            _InfoRow(
                              label: 'Family assets',
                              value: _money(household.totalAssetValue),
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

  String _money(Money amount) => CurrencyFormatter.format(
        amount,
        currencyCode: widget.currencyCode,
      );

  String _housingLabel(HousingStatus status) => switch (status) {
        HousingStatus.rented => 'Rented',
        HousingStatus.familyOwned => 'Family-owned',
        HousingStatus.ownedWithMortgage => 'Owned with mortgage',
        HousingStatus.temporary => 'Temporary housing',
        HousingStatus.providedByOthers => 'Provided by others',
        HousingStatus.homeless => 'Homeless',
      };
}

class _ParentCard extends StatelessWidget {
  const _ParentCard({
    required this.parent,
    required this.currentYear,
    required this.zoom,
    required this.paletteFuture,
  });

  final ParentNpc parent;
  final int currentYear;
  final double zoom;
  final Future<CharacterPaletteService> paletteFuture;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;
    final age = currentYear - parent.birthYear;
    final occupation = parent.occupation?.trim();
    final employment = _employmentLabel(parent.employmentStatus);
    final character = Character(
      id: parent.id,
      name: parent.fullName,
      firstName: parent.firstName,
      lastName: parent.lastName,
      gender: parent.gender,
      birthYear: parent.birthYear,
      stats: const CharacterStats(),
      money: const Money.zero(),
      appearance: _safeAppearance(parent.appearance),
    );

    return Container(
      padding: EdgeInsets.all(s(8)),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(s(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<CharacterPaletteService>(
            future: paletteFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox(width: s(76), height: s(92));
              }
              final palette = snapshot.data!;
              final skin = palette.skinColor(character.appearance.skinTone) ??
                  palette.skinColor('medium')!;
              final eyes = palette.eyeColor(character.appearance.eyeColor) ??
                  palette.eyeColor('dark_brown')!;
              final hair = palette.hairColor(character.appearance.hairColor) ??
                  palette.hairColor('dark_brown')!;
              return CharacterAvatar(
                character: character,
                currentYear: currentYear,
                size: s(72),
                skinColor: skin,
                eyeColor: eyes,
                hairColor: hair,
              );
            },
          ),
          SizedBox(width: s(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parent.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: s(2)),
                Text('${parent.role == FamilyRole.father ? 'Father' : parent.role == FamilyRole.mother ? 'Mother' : 'Guardian'} · Age $age'),
                SizedBox(height: s(4)),
                Text(occupation == null || occupation.isEmpty
                    ? employment
                    : '$employment · $occupation'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  CharacterAppearance _safeAppearance(CharacterAppearance appearance) {
    return appearance.copyWith(
      skinTone: appearance.skinTone == 'default' ? 'medium' : appearance.skinTone,
      hairColor: appearance.hairColor == 'default' ? 'dark_brown' : appearance.hairColor,
      eyeColor: appearance.eyeColor == 'default' ? 'dark_brown' : appearance.eyeColor,
      hair: appearance.hair == 'default' ? 'male_hair_01' : appearance.hair,
      eyebrows: appearance.eyebrows == 'default' ? 'straight' : appearance.eyebrows,
    );
  }

  String _employmentLabel(EmploymentStatus status) => switch (status) {
        EmploymentStatus.employed => 'Employed',
        EmploymentStatus.selfEmployed => 'Self-employed',
        EmploymentStatus.unemployed => 'Unemployed',
        EmploymentStatus.retired => 'Retired',
        EmploymentStatus.homemaker => 'Homemaker',
        EmploymentStatus.unableToWork => 'Unable to work',
      };
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
