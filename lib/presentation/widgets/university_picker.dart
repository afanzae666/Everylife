import 'package:flutter/material.dart';

import '../../domain/career/major_catalog.dart';
import '../../domain/career/tuition_funding.dart';
import 'animated_dialog.dart';
import 'life_event_dialogs.dart';
import 'themed_cards.dart';

/// One major in the picker, with what it costs this player.
class UniversityMajorOption {
  const UniversityMajorOption({
    required this.major,
    required this.tuitionLabel,
    required this.prompt,
  });

  final MajorDefinition major;

  /// Total tuition, already formatted in the player's currency.
  final String tuitionLabel;

  /// The line that asks how to pay.
  final String prompt;
}

/// The major and the way of paying the player settled on.
class UniversityChoice {
  const UniversityChoice(this.majorId, this.funding);

  final String majorId;
  final TuitionFunding funding;
}

/// Asks whether a way of paying works for a major.
typedef TuitionAsker = TuitionAnswer Function(
  String majorId,
  TuitionFunding funding,
);

/// The big university overlay: one list of majors, then a page for the
/// major with the four ways to pay. Returns the choice, or null when the
/// overlay is closed.
Future<UniversityChoice?> showUniversityPicker(
  BuildContext context, {
  required List<UniversityMajorOption> options,
  required TuitionAsker ask,
  String? sportsClub,
}) {
  final size = MediaQuery.of(context).size;
  final width = (size.width - 44).clamp(280.0, 600.0).toDouble();

  return showAnimatedDialog<UniversityChoice>(
    context: context,
    builder: (dialogContext) => ThemedDialog(
      title: 'University',
      child: SizedBox(
        key: const Key('university-picker'),
        width: width,
        child: UniversityPickerBody(
          height: size.height * 0.72,
          options: options,
          ask: ask,
          sportsClub: sportsClub,
          onChoose: (choice) => Navigator.of(dialogContext).pop(choice),
        ),
      ),
    ),
  );
}

/// The two pages of the overlay, kept apart from the dialog for testing.
class UniversityPickerBody extends StatefulWidget {
  const UniversityPickerBody({
    super.key,
    required this.height,
    required this.options,
    required this.ask,
    required this.onChoose,
    this.sportsClub,
  });

  final double height;
  final List<UniversityMajorOption> options;
  final TuitionAsker ask;
  final ValueChanged<UniversityChoice> onChoose;

  /// The sport club that recruited the player, if one did. Only then is the
  /// sports scholarship offered.
  final String? sportsClub;

  @override
  State<UniversityPickerBody> createState() => _UniversityPickerBodyState();
}

class _UniversityPickerBodyState extends State<UniversityPickerBody> {
  UniversityMajorOption? _picked;

  /// Ways of paying that were turned down, as `majorId|funding`.
  final Set<String> _refused = {};

  String _key(UniversityMajorOption option, TuitionFunding funding) =>
      '${option.major.id}|${funding.name}';

  Future<void> _tryFunding(
    UniversityMajorOption option,
    TuitionFunding funding,
  ) async {
    final answer = widget.ask(option.major.id, funding);

    if (answer.approved) {
      widget.onChoose(UniversityChoice(option.major.id, funding));

      return;
    }

    // Hide it first, so the choices are already without it when the scene
    // closes.
    setState(() => _refused.add(_key(option, funding)));

    await showTapToCloseOverlay(
      context,
      dialogKey: const Key('funding-refused'),
      emoji: funding.emoji,
      title: answer.title,
      text: answer.text ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final picked = _picked;

    return SizedBox(
      height: widget.height,
      child: picked == null ? _list(context) : _detail(context, picked),
    );
  }

  Widget _list(BuildContext context) {
    final theme = Theme.of(context);

    Iterable<Widget> section(String title, InstitutionType type) sync* {
      final shown = [
        for (final option in widget.options)
          if (option.major.institution == type) option,
      ];

      if (shown.isEmpty) return;

      yield SectionDivider(title: title);

      for (final option in shown) {
        yield OptionTile(
          key: Key('major-${option.major.id}'),
          emoji: option.major.emoji,
          title: option.major.name,
          subtitle: '${option.major.blurb}\n'
              '${option.major.years} years · ${option.tuitionLabel}',
          selected: false,
          onTap: () => setState(() => _picked = option),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Pick what you want to study.',
          key: const Key('university-intro'),
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        ...section('GENERAL UNIVERSITY', InstitutionType.general),
        ...section('PROFESSIONAL SCHOOLS', InstitutionType.specialized),
      ],
    );
  }

  Widget _detail(BuildContext context, UniversityMajorOption option) {
    final theme = Theme.of(context);
    final major = option.major;

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: Text(label)),
              Expanded(
                flex: 6,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );

    final subtitles = <TuitionFunding, String>{
      for (final funding in TuitionFunding.values) funding: funding.hint,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Center(
                child: Text(major.emoji, style: const TextStyle(fontSize: 44)),
              ),
              const SizedBox(height: 6),
              Text(
                major.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                major.blurb,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              row('Where', major.campusName ?? major.institution.label),
              row('Duration', '${major.years} years'),
              row('Total tuition', option.tuitionLabel),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  option.prompt,
                  key: const Key('funding-prompt'),
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SectionDivider(title: 'HOW TO PAY'),
              for (final funding in TuitionFunding.values)
                if (funding != TuitionFunding.sports ||
                    widget.sportsClub != null)
                  if (!_refused.contains(_key(option, funding)))
                  OptionTile(
                    key: Key('funding-${funding.name}'),
                    emoji: funding.emoji,
                    title: funding.label,
                    subtitle: funding == TuitionFunding.sports
                        ? 'The ${widget.sportsClub} coaches want me on their '
                            'team. A full ride, as long as I keep playing.'
                        : subtitles[funding],
                    selected: false,
                    onTap: () => _tryFunding(option, funding),
                  ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: TextButton(
            key: const Key('university-back'),
            onPressed: () => setState(() => _picked = null),
            child: const Text('BACK'),
          ),
        ),
      ],
    );
  }
}
