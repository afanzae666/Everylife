import 'package:flutter/material.dart';

import '../../domain/character/character.dart';
import '../../domain/character/gender.dart';
import '../../domain/character/life_stage.dart';

class CharacterProfileScreen
    extends StatelessWidget {
  const CharacterProfileScreen({
    required this.character,
    required this.currentYear,
    this.uiScaleController,
    super.key,
  });

  final Character character;
  final int currentYear;
  final ValueNotifier<double>?
      uiScaleController;

  @override
  Widget build(BuildContext context) {
    final controller =
        uiScaleController;

    if (controller == null) {
      return _buildScaledPage(
        context,
        1.0,
      );
    }

    return ValueListenableBuilder<double>(
      valueListenable: controller,
      builder: (
        context,
        zoom,
        _,
      ) {
        return _buildScaledPage(
          context,
          zoom,
        );
      },
    );
  }

  Widget _buildScaledPage(
    BuildContext context,
    double zoom,
  ) {
    final mediaQuery =
        MediaQuery.of(context);

    final scaledMediaQuery =
        mediaQuery.copyWith(
      textScaler:
          TextScaler.linear(zoom),
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
          'Character',
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
    double s(double value) =>
        value * zoom;

    final age = character.ageAt(
      currentYear,
    );

    final lifeStage =
        character.lifeStageAt(
      currentYear,
    );

    return ListView(
      padding: EdgeInsets.fromLTRB(
        s(8),
        s(4),
        s(8),
        s(12),
      ),
      children: [
        SizedBox(
          height: s(2),
        ),
        Center(
          child: CircleAvatar(
            radius: s(48),
            child: Icon(
              character.gender == Gender.male
                  ? Icons.person
                  : Icons.person_outline,
              size: s(52),
            ),
          ),
        ),
        SizedBox(
          height: s(5),
        ),
        Center(
          child: Padding(
            padding:
                EdgeInsets.symmetric(
              horizontal: s(8),
            ),
            child: Text(
              character.fullName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge,
              textAlign:
                  TextAlign.center,
              softWrap: true,
            ),
          ),
        ),
        SizedBox(
          height: s(6),
        ),
        _ResponsiveCard(
          padding: EdgeInsets.fromLTRB(
            s(8),
            s(7),
            s(8),
            s(7),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Identity',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall,
              ),
              SizedBox(
                height: s(3),
              ),
              _InfoRow(
                label: 'First Name',
                value:
                    character.resolvedFirstName,
                zoom: zoom,
              ),
              _InfoRow(
                label:
                    'Last Name / Family Name',
                value:
                    character.resolvedLastName,
                zoom: zoom,
              ),
              _InfoRow(
                label: 'Full Name',
                value: character.fullName,
                zoom: zoom,
              ),
            ],
          ),
        ),
        SizedBox(
          height: s(4),
        ),
        _ResponsiveCard(
          padding: EdgeInsets.fromLTRB(
            s(8),
            s(7),
            s(8),
            s(7),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Information',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall,
              ),
              SizedBox(
                height: s(3),
              ),
              _InfoRow(
                label: 'Gender',
                value:
                    character.gender.label,
                zoom: zoom,
              ),
              _InfoRow(
                label: 'Birth Year',
                value:
                    '${character.birthYear}',
                zoom: zoom,
              ),
              _InfoRow(
                label: 'Age',
                value: '$age',
                zoom: zoom,
              ),
              _InfoRow(
                label: 'Year',
                value:
                    '$currentYear',
                zoom: zoom,
              ),
              _InfoRow(
                label: 'Life Stage',
                value:
                    _formatLifeStage(
                  lifeStage,
                ),
                zoom: zoom,
              ),
              _InfoRow(
                label: 'Money',
                value:
                    character.money.toString(),
                zoom: zoom,
              ),
            ],
          ),
        ),
        SizedBox(
          height: s(4),
        ),
        _ResponsiveCard(
          padding: EdgeInsets.fromLTRB(
            s(8),
            s(7),
            s(8),
            s(7),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Character Information',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall,
              ),
              SizedBox(
                height: s(2),
              ),
              Text(
                'This profile will become the '
                'home for additional character '
                'information as the life '
                'simulation expands.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall,
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatLifeStage(
    LifeStage stage,
  ) {
    switch (stage) {
      case LifeStage.infant:
        return 'Infant';
      case LifeStage.toddler:
        return 'Toddler';
      case LifeStage.child:
        return 'Child';
      case LifeStage.teen:
        return 'Teen';
      case LifeStage.youngAdult:
        return 'Young Adult';
      case LifeStage.adult:
        return 'Adult';
      case LifeStage.senior:
        return 'Senior';
    }
  }
}

class _ResponsiveCard
    extends StatelessWidget {
  const _ResponsiveCard({
    required this.padding,
    required this.child,
  });

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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

class _InfoRow
    extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.zoom,
  });

  final String label;
  final String value;
  final double zoom;

  @override
  Widget build(BuildContext context) {
    double s(double value) =>
        value * zoom;

    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final narrow =
            constraints.maxWidth <
                s(280);

        if (narrow) {
          return Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: s(2),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                  softWrap: true,
                ),
                SizedBox(
                  height: s(1),
                ),
                Padding(
                  padding:
                      EdgeInsets.only(
                    left: s(4),
                  ),
                  child: Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(
                          fontWeight:
                              FontWeight.w600,
                        ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding:
              EdgeInsets.symmetric(
            vertical: s(1),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall,
                  softWrap: true,
                ),
              ),
              SizedBox(
                width: s(8),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  textAlign:
                      TextAlign.end,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(
                        fontWeight:
                            FontWeight.w600,
                      ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
