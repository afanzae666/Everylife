import 'package:flutter/material.dart';

import 'package:everylife/presentation/widgets/page_top_bar.dart';

import '../../core/result/result.dart';
import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/career/school_npc.dart';
import '../../domain/world/country_catalog.dart';
import '../../simulation/engine/simulation_engine.dart';
import '../../simulation/career/school_actions.dart';
import '../../simulation/systems/education_system.dart';
import '../../domain/world/city_catalog.dart';
import '../../simulation/school/school_appearance.dart';
import '../widgets/themed_cards.dart';
import '../widgets/info_line.dart';
import '../widgets/npc_avatar.dart';
import 'npc_interaction_screen.dart';
import '../widgets/animated_dialog.dart';
import '../widgets/game_bar.dart';
import '../widgets/id_card_frame.dart';
import '../../simulation/generation/npc_wealth.dart';
import '../widgets/npc_money.dart';

String schoolStageTitle(SchoolStage stage) => switch (stage) {
      SchoolStage.elementary => 'Elementary School',
      SchoolStage.middle => 'Middle School',
      SchoolStage.high => 'High School',
      SchoolStage.university => 'University',
      SchoolStage.none => 'School',
    };

String schoolStageEmoji(SchoolStage stage) => switch (stage) {
      SchoolStage.elementary => '🏫',
      SchoolStage.middle => '🏫',
      SchoolStage.high => '🏫',
      SchoolStage.university => '🎓',
      SchoolStage.none => '🏫',
    };

/// "Grade 3 of 6" (school) or "Year 2 of 4" (university).
String schoolProgressLabel(EducationState education) {
  int at(int total) => (education.yearsInStage + 1).clamp(1, total).toInt();

  return switch (education.stage) {
    SchoolStage.elementary =>
      'Grade ${at(EducationSystem.elementaryYears)} of ${EducationSystem.elementaryYears}',
    SchoolStage.middle =>
      'Grade ${at(EducationSystem.middleYears)} of ${EducationSystem.middleYears}',
    SchoolStage.high =>
      'Grade ${at(EducationSystem.highYears)} of ${EducationSystem.highYears}',
    SchoolStage.university =>
      'Year ${at(EducationSystem.universityYears)} of ${EducationSystem.universityYears}',
    SchoolStage.none => 'Not enrolled',
  };
}

/// The education card while the player studies: the school's name and a
/// grades bar. Tapping it (when [onTap] is set) opens the school page.
class SchoolSummaryCard extends StatelessWidget {
  const SchoolSummaryCard({
    required this.education,
    required this.zoom,
    this.onTap,
    this.showChevron = true,
    super.key,
  });

  final EducationState education;
  final double zoom;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);
    final stage = education.stage;

    final primary = theme.colorScheme.primary;

    return AccentCard(
      key: const Key('school-card'),
      zoom: zoom,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(s(8), s(6), s(8), s(7)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(s(5)),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(s(10)),
                      border: Border.all(color: primary, width: 1.5),
                    ),
                    child: Text(
                      schoolStageEmoji(stage),
                      style: TextStyle(fontSize: s(22)),
                    ),
                  ),
                  SizedBox(width: s(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          schoolStageTitle(stage),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (education.schoolName != null)
                          Text(
                            education.schoolName!,
                            key: const Key('school-name'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: s(7),
                      vertical: s(2),
                    ),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(s(10)),
                    ),
                    child: Text(
                      schoolProgressLabel(education),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (onTap != null && showChevron) ...[
                    SizedBox(width: s(6)),
                    ChevronBadge(zoom: zoom),
                  ],
                ],
              ),
              SizedBox(height: s(7)),
              Row(
                children: [
                  Text(
                    '◆ GRADES',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${education.grades}/100',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: s(3)),
              PipBar(
                barKey: const Key('grades-bar'),
                value: education.grades / 100,
                height: s(8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Everything about the school the player attends: activities, classmates
/// and faculty.
class SchoolScreen extends StatefulWidget {
  const SchoolScreen({
    required this.engine,
    required this.zoom,
    this.onChanged,
    this.headerBuilder,
    super.key,
  });

  final SimulationEngine engine;
  final double zoom;
  final Future<void> Function()? onChanged;
  final WidgetBuilder? headerBuilder;

  @override
  State<SchoolScreen> createState() => _SchoolScreenState();
}

class _SchoolScreenState extends State<SchoolScreen> {
  SimulationEngine get engine => widget.engine;

  double s(double value) => value * widget.zoom;

  @override
  void initState() {
    super.initState();
    engine.ensureSchool();
  }

  void _say(Result<String> result) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final text = switch (result) {
      Success<String>(:final value) => value,
      Failure<String>(:final message) => message,
    };

    messenger.showSnackBar(SnackBar(content: Text(text)));
    setState(() {});

    if (result.isSuccess) {
      widget.onChanged?.call();
    }
  }

  void _showSchoolInfo() {
    final state = engine.state;
    final education = state.lifeProgress.education;
    final stage = education.stage;
    final location = state.player.location;
    final country =
        location == null ? null : CountryCatalog.findByCode(location.countryCode);
    final city =
        location == null ? null : CityCatalog.findById(location.cityId);
    final head = education.faculty
        .where((npc) => npc.role == SchoolRole.principal || npc.role == SchoolRole.dean)
        .toList();
    final year = state.clock.currentYear;
    final theme = Theme.of(context);

    final place = country == null
        ? null
        : city == null
            ? country.name
            : '${country.name}, ${city.name}';

    showAnimatedDialog<void>(
      context: context,
      builder: (dialogContext) => IdCardFrame(
        key: const Key('school-info'),
        title: 'SCHOOL INFORMATION',
        onClose: () => Navigator.of(dialogContext).pop(),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(schoolStageEmoji(stage),
                      style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      education.schoolName ?? schoolStageTitle(stage),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              InfoLine(label: 'Type', value: schoolStageTitle(stage)),
              if (place != null) InfoLine(label: 'Location', value: place),
              InfoLine(
                label: stage == SchoolStage.university ? 'Year' : 'Grade',
                value: schoolProgressLabel(education)
                    .replaceFirst(RegExp(r'^(Grade|Year) '), ''),
              ),
              InfoLine(label: 'Grades', value: '${education.grades}/100'),
              if (head.isNotEmpty)
                InfoLine(
                  label: head.first.role == SchoolRole.dean ? 'Dean' : 'Principal',
                  value: head.first.fullName,
                ),
              InfoLine(
                label: stage == SchoolStage.university ? 'Professors' : 'Teachers',
                value: '${education.faculty.where((n) => n.role != SchoolRole.principal && n.role != SchoolRole.dean).length}',
              ),
              InfoLine(label: 'Classmates', value: '${education.classmates.length}'),
              if (SchoolActions.hasClubs(stage))
                InfoLine(
                  label: 'Extracurricular',
                  value: education.club != null && education.lastClubYear == year
                      ? education.club!
                      : 'None',
                ),
            ],
          ),
      ),
    );
  }

  Future<void> _pickClub() async {
    final clubId = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Pick an extracurricular',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            for (final club in SchoolActions.clubs)
              ListTile(
                key: Key('club-${club.id}'),
                leading: Text(club.emoji, style: const TextStyle(fontSize: 24)),
                title: Text(club.name),
                subtitle: Text(club.blurb),
                onTap: () => Navigator.of(sheetContext).pop(club.id),
              ),
          ],
        ),
      ),
    );

    if (!mounted || clubId == null) {
      return;
    }

    _say(engine.joinClub(clubId));
  }

  Future<void> _leaveSchool() async {
    final confirmed = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave school?'),
        content: const Text('I would walk away from my studies for now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            key: const Key('leave-school-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('LEAVE'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final result = engine.dropOutOfSchool();
    _say(result);

    if (result.isSuccess && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _openPeople({required bool faculty}) {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => SchoolPeopleScreen(
              engine: engine,
              zoom: widget.zoom,
              faculty: faculty,
              onChanged: widget.onChanged,
              headerBuilder: widget.headerBuilder,
            ),
          ),
        )
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  Widget _activity({
    required Key key,
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return AccentCard(
      key: key,
      zoom: widget.zoom,
      child: InteractionRow(
        emoji: emoji,
        title: title,
        description: subtitle,
        onPressed: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final education = engine.state.lifeProgress.education;
    final stage = education.stage;
    final year = engine.state.clock.currentYear;
    final isUniversity = stage == SchoolStage.university;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.headerBuilder != null) widget.headerBuilder!(context),
              PageTopBar(
                title: education.isStudent ? schoolStageTitle(stage) : 'School',
                zoom: widget.zoom,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (!education.isStudent)
                      Padding(
                        padding: EdgeInsets.all(s(8)),
                        child: const Text('I am not in school right now.'),
                      )
                    else ...[
                      SchoolSummaryCard(
                        education: education,
                        zoom: widget.zoom,
                        onTap: _showSchoolInfo,
                        showChevron: false,
                      ),
                      SectionDivider(
                        title: 'ACTIVITIES',
                        zoom: widget.zoom,
                      ),
                      _activity(
                        key: const Key('activity-study'),
                        emoji: '📚',
                        title: 'Study Harder',
                        subtitle: education.lastStudyYear == year
                            ? 'Done for this year'
                            : 'Raise your grades',
                        onTap: () => _say(engine.studyHarder()),
                      ),
                      if (SchoolActions.hasClubs(stage))
                        _activity(
                          key: const Key('activity-club'),
                          emoji: '🎭',
                          title: 'Extracurricular',
                          subtitle: education.lastClubYear == year &&
                                  education.club != null
                              ? 'This year: ${education.club}'
                              : 'Join a club',
                          onTap: _pickClub,
                        ),
                      _activity(
                        key: const Key('activity-classmates'),
                        emoji: '🧑‍🎓',
                        title: 'Classmates',
                        subtitle: '${education.classmates.length} people',
                        onTap: () => _openPeople(faculty: false),
                      ),
                      _activity(
                        key: const Key('activity-faculty'),
                        emoji: isUniversity ? '👨‍🏫' : '🧑‍🏫',
                        title: 'Faculty',
                        subtitle: isUniversity
                            ? 'Professors and the dean'
                            : 'Teachers and the principal',
                        onTap: () => _openPeople(faculty: true),
                      ),
                      if (stage == SchoolStage.high || isUniversity)
                        _activity(
                          key: const Key('activity-leave'),
                          emoji: '🚪',
                          title: 'Leave School',
                          subtitle: 'Walk away from your studies',
                          onTap: _leaveSchool,
                        ),
                    ],
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

/// Classmates or faculty of the player's school.
class SchoolPeopleScreen extends StatefulWidget {
  const SchoolPeopleScreen({
    required this.engine,
    required this.zoom,
    required this.faculty,
    this.onChanged,
    this.headerBuilder,
    super.key,
  });

  final SimulationEngine engine;
  final double zoom;
  final bool faculty;
  final Future<void> Function()? onChanged;
  final WidgetBuilder? headerBuilder;

  @override
  State<SchoolPeopleScreen> createState() => _SchoolPeopleScreenState();
}

class _SchoolPeopleScreenState extends State<SchoolPeopleScreen> {
  SimulationEngine get engine => widget.engine;

  double s(double value) => value * widget.zoom;

  static String _occupationOf(SchoolNpc npc) {
    final finance = npc.finance;
    final job = finance?.jobId == null ? null : JobCatalog.byId(finance!.jobId!);

    if (job != null) {
      return job.titleAt(finance!.rank);
    }

    return switch (npc.role) {
      SchoolRole.classmate => 'Student',
      SchoolRole.teacher => 'Teacher',
      SchoolRole.principal => 'Principal',
      SchoolRole.professor => 'Professor',
      SchoolRole.dean => 'Dean',
    };
  }

  void _open(SchoolNpc npc) {
    final state = engine.state;
    final country = CountryCatalog.findByCode(npc.countryCode);

    Navigator.of(context)
        .push<void>(
          MaterialPageRoute<void>(
            builder: (_) => NpcInteractionScreen(
              npcId: npc.id,
              name: npc.fullName,
              relationship: npc.role.label,
              relationshipPercent: npc.relationshipPercent,
              playerAge: state.player.ageAt(state.clock.currentYear),
              currentYear: state.clock.currentYear,
              birthYear: npc.birthYear,
              netWorth: npcMoneyLabel(
                NpcWealth.forSchoolNpc(npc),
                npc.countryCode,
              ),
              countryCode: npc.countryCode,
              zoom: widget.zoom,
              headerBuilder: widget.headerBuilder,
              details: [
                MapEntry('Gender', npc.gender.name == 'male' ? 'Male' : 'Female'),
                MapEntry('Occupation', _occupationOf(npc)),
                MapEntry('Location', country?.name ?? npc.countryCode),
              ],
              avatar: NpcAvatar(
                character: SchoolAppearance.characterFor(npc),
                currentYear: state.clock.currentYear,
                size: 112,
              ),
              onInteraction: ({required npcId, required action}) {
                final result = engine.interactWithNpc(
                  npcId: npcId,
                  action: action,
                );

                if (result.isSuccess) {
                  widget.onChanged?.call();
                }

                return result;
              },
            ),
          ),
        )
        .then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final education = engine.state.lifeProgress.education;
    final people = (widget.faculty ? education.faculty : education.classmates)
        .toList(growable: false);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(widget.zoom),
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.headerBuilder != null) widget.headerBuilder!(context),
              PageTopBar(
                title: widget.faculty ? 'Faculty' : 'Classmates',
                zoom: widget.zoom,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final npc in people)
                      AccentCard(
                        key: Key('school-npc-${npc.id}'),
                        zoom: widget.zoom,
                        child: InkWell(
                          onTap: () => _open(npc),
                          child: Padding(
                            padding: EdgeInsets.all(s(3)),
                            child: Row(
                              children: [
                                NpcAvatar(
                                  character:
                                      SchoolAppearance.characterFor(npc),
                                  currentYear: engine.state.clock.currentYear,
                                  size: s(56),
                                ),
                                SizedBox(width: s(6)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              npc.fullName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: s(4)),
                                          Text(
                                            '(${npc.role.label.toUpperCase()})',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: s(3)),
                                      GameBar(
                                        value:
                                            npc.relationshipPercent.abs() / 100,
                                      ),
                                      SizedBox(height: s(1)),
                                      Text(
                                        'Relationship · ${npc.relationshipPercent}%',
                                        style: theme.textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                ChevronBadge(zoom: widget.zoom),
                              ],
                            ),
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
