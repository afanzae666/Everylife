import 'package:flutter/material.dart';

import '../../domain/career/major_catalog.dart';
import 'animated_dialog.dart';
import 'themed_cards.dart';

/// One major in the picker, with what it costs this player.
class UniversityMajorOption {
  const UniversityMajorOption({
    required this.major,
    required this.tuitionLabel,
    this.blocker,
  });

  final MajorDefinition major;

  /// Yearly tuition, already formatted in the player's currency.
  final String tuitionLabel;

  /// Why the player cannot apply, or null when they can.
  final String? blocker;
}

/// The big university overlay. It never closes on its own after a choice:
/// first the kind of institution, then the major, then a summary with the
/// apply button. Returns the id of the major the player applies for, or null
/// when the overlay is closed.
Future<String?> showUniversityPicker(
  BuildContext context, {
  required List<UniversityMajorOption> options,
  required int grades,
  required int intelligence,
  required int chance,
  required int year,
}) {
  final size = MediaQuery.of(context).size;
  final width = (size.width - 44).clamp(280.0, 600.0).toDouble();

  return showAnimatedDialog<String>(
    context: context,
    builder: (dialogContext) => ThemedDialog(
      title: 'University',
      child: SizedBox(
        key: const Key('university-picker'),
        width: width,
        child: UniversityPickerBody(
          height: size.height * 0.72,
          options: options,
          grades: grades,
          intelligence: intelligence,
          chance: chance,
          year: year,
          onApply: (majorId) => Navigator.of(dialogContext).pop(majorId),
        ),
      ),
    ),
  );
}

/// The three steps of the overlay. Kept apart from the dialog so it can be
/// tested on its own.
class UniversityPickerBody extends StatefulWidget {
  const UniversityPickerBody({
    super.key,
    required this.height,
    required this.options,
    required this.grades,
    required this.intelligence,
    required this.chance,
    required this.year,
    required this.onApply,
  });

  /// Height of the major list and the summary. The first step only takes
  /// the room it needs.
  final double height;
  final List<UniversityMajorOption> options;
  final int grades;
  final int intelligence;
  final int chance;
  final int year;
  final ValueChanged<String> onApply;

  @override
  State<UniversityPickerBody> createState() => _UniversityPickerBodyState();
}

class _UniversityPickerBodyState extends State<UniversityPickerBody> {
  static const List<String> _intros = [
    'The last bell of high school rang a while ago, and the quiet after it '
        'is louder than I expected. A stack of glossy brochures sits on my '
        'desk, each one promising to turn me into somebody. Everyone has '
        'advice. Today I get to decide what I want.',
    'Campus tours, open days, free tote bags. Every university swears it is '
        'the place where my life really begins. All I have to do is choose '
        'a door and walk through it.',
    'My friends are already arguing about it in the group chat. I mute it, '
        'stare at the ceiling and ask the one question no brochure can '
        'answer: what do I want to be doing in ten years?',
    'The application page is open and the cursor keeps blinking. Somewhere '
        'out there is a lecture hall with a seat that could be mine. Time to '
        'find it.',
    'My parents pretend not to hover. The kettle has boiled three times. '
        'The future is a form with exactly one blank that matters, and I '
        'have to fill it in myself.',
  ];

  String get _gradesLine {
    if (widget.grades >= 80) {
      return 'My grades are strong, so I can aim high.';
    }

    if (widget.grades >= 60) {
      return 'My grades are decent, and I have real options.';
    }

    return 'My grades are not great, but nobody ever got in by not trying.';
  }

  InstitutionType? _type;
  UniversityMajorOption? _picked;

  void _back() {
    setState(() {
      if (_picked != null) {
        _picked = null;
      } else {
        _type = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_picked != null) {
      return SizedBox(height: widget.height, child: _detail(context, _picked!));
    }

    if (_type != null) {
      return SizedBox(height: widget.height, child: _majorList(context, _type!));
    }

    return _intro(context);
  }

  Widget _intro(BuildContext context) {
    final theme = Theme.of(context);
    final generalCount = widget.options
        .where((o) => o.major.institution == InstitutionType.general)
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: Text('🎓', style: TextStyle(fontSize: 44))),
          const SizedBox(height: 8),
          Text(
            '${_intros[widget.year % _intros.length]}\n\n$_gradesLine',
            key: const Key('university-intro'),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          const SectionDivider(title: 'WHERE TO STUDY'),
          OptionTile(
            key: const Key('institution-general'),
            emoji: '🏛️',
            title: InstitutionType.general.label,
            subtitle: 'One big campus with $generalCount majors: business, '
                'engineering, law, design and more.',
            selected: false,
            onTap: () => setState(() => _type = InstitutionType.general),
          ),
          OptionTile(
            key: const Key('institution-specialized'),
            emoji: '🩺',
            title: InstitutionType.specialized.label,
            subtitle: 'Professional schools built around one career, such as '
                'medicine, nursing or aviation. Opening soon.',
            selected: false,
            onTap: () => setState(() => _type = InstitutionType.specialized),
          ),
        ],
      ),
    );
  }

  Widget _majorList(BuildContext context, InstitutionType type) {
    final theme = Theme.of(context);
    final shown = [
      for (final option in widget.options)
        if (option.major.institution == type) option,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              SectionDivider(title: type.label.toUpperCase()),
              if (shown.isEmpty)
                Padding(
                  key: const Key('no-programs'),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'The first professional schools are still being built. '
                    'Come back later, or pick the General University.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              for (final option in shown)
                OptionTile(
                  key: Key('major-${option.major.id}'),
                  emoji: option.major.emoji,
                  title: option.major.name,
                  subtitle: '${option.major.blurb}\n'
                      '${option.major.years} years · '
                      '${option.tuitionLabel} a year'
                      '${option.blocker == null ? '' : '\n🔒 ${option.blocker}'}',
                  selected: false,
                  onTap: () => setState(() => _picked = option),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: TextButton(
            key: const Key('university-back'),
            onPressed: _back,
            child: const Text('BACK'),
          ),
        ),
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
              row('Where', major.institution.label),
              row('Duration', '${major.years} years'),
              row('Tuition', '${option.tuitionLabel} a year'),
              row('Grades needed',
                  '${major.minGrades}+ (you: ${widget.grades})'),
              row('Intelligence needed',
                  '${major.minIntelligence}+ (you: ${widget.intelligence})'),
              row('Chance of getting in',
                  option.blocker == null ? '${widget.chance}%' : 'Not yet'),
              const Divider(height: 1),
              if (option.blocker != null)
                Padding(
                  key: const Key('major-blocker'),
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    '🔒 ${option.blocker}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                key: const Key('apply-major'),
                onPressed:
                    option.blocker == null ? () => widget.onApply(major.id) : null,
                child: const Text('APPLY'),
              ),
              TextButton(
                key: const Key('university-back'),
                onPressed: _back,
                child: const Text('BACK'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
