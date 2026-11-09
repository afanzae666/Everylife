import 'package:flutter/material.dart';

import 'package:everylife/presentation/widgets/page_top_bar.dart';

import '../../core/result/result.dart';
import '../../domain/career/education_state.dart';
import '../../domain/career/job_catalog.dart';
import '../../domain/career/school_npc.dart';
import '../../domain/character/fertility.dart';
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
import '../widgets/club_widgets.dart';
import '../widgets/life_event_dialogs.dart';
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

    // A promotion earned at the last birthday is announced here too.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await showClubPromotionIfAny(context, engine);

      if (mounted) setState(() {});
    });
  }

  /// Shows what happened as a pop-up (not a bar at the bottom).
  Future<void> _announce(
    Result<String> result, {
    required String title,
    required String emoji,
  }) async {
    final ok = result.isSuccess;

    final text = switch (result) {
      Success<String>(:final value) => value,
      Failure<String>(:final message) => message,
    };

    setState(() {});

    if (ok) {
      widget.onChanged?.call();
    }

    await showTapToCloseOverlay(
      context,
      title: ok ? title : 'Not Now',
      emoji: ok ? emoji : '⏳',
      text: text,
    );

    if (!mounted) return;

    await showClubPromotionIfAny(context, engine);

    if (mounted) setState(() {});
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
                  value: education.club ?? 'None',
                ),
            ],
          ),
      ),
    );
  }

  static const List<(String, String)> _clubGroups = [
    ('sport', 'SPORTS'),
    ('stage', 'STAGE & MUSIC'),
    ('craft', 'ARTS & CRAFTS'),
    ('mind', 'MIND'),
    ('tech', 'TECH'),
    ('social', 'COMMUNITY'),
  ];

  Future<void> _pickClub() async {
    final size = MediaQuery.of(context).size;

    final clubId = await showAnimatedDialog<String>(
      context: context,
      builder: (dialogContext) => ThemedDialog(
        title: 'Pick an Extracurricular',
        child: SizedBox(
          key: const Key('club-picker'),
          width: 320,
          height: size.height * 0.7,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 8),
            children: [
              for (final group in _clubGroups) ...[
                SectionDivider(title: group.$2),
                for (final club in SchoolActions.clubs)
                  if (club.category == group.$1)
                    OptionTile(
                      key: Key('club-${club.id}'),
                      emoji: club.emoji,
                      title: club.name,
                      subtitle: club.blurb,
                      selected: false,
                      onTap: () => Navigator.of(dialogContext).pop(club.id),
                    ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!mounted || clubId == null) {
      return;
    }

    final club = SchoolActions.clubById(clubId);

    await _announce(
      engine.joinClub(clubId),
      title: 'New Club',
      emoji: club?.emoji ?? '🏅',
    );
  }

  /// The club's information, with the buttons to train or leave.
  void _openClub() {
    final education = engine.state.lifeProgress.education;
    final club = SchoolActions.clubByName(education.club);

    if (club == null) return;

    final year = engine.state.clock.currentYear;
    final trained = education.lastTrainYear == year;
    final rank = education.clubRank;
    final theme = Theme.of(context);

    final next = switch (rank) {
      0 => '${club.viceTitle} at ${SchoolActions.viceAt} performance',
      1 => '${club.leadTitle} at ${SchoolActions.leadAt} performance',
      _ => 'Top rank reached',
    };

    showAnimatedDialog<void>(
      context: context,
      builder: (dialogContext) => ThemedDialog(
        title: '${club.emoji}  ${club.name.toUpperCase()}',
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            key: const Key('club-info'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoLine(
                label: 'School',
                value: education.schoolName ?? schoolStageTitle(education.stage),
              ),
              InfoLine(label: 'My role', value: club.titleFor(rank)),
              InfoLine(label: 'Focus', value: club.blurb),
              InfoLine(label: 'Next goal', value: next),
              const SizedBox(height: 8),
              Text(
                '◆ PERFORMANCE · ${education.clubPerformance}/100',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              PipBar(value: education.clubPerformance / 100),
              const SizedBox(height: 14),
              FilledButton(
                key: const Key('club-train'),
                onPressed: trained
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop();
                        _announce(
                          engine.trainClub(),
                          title: 'Practice',
                          emoji: '🏅',
                        );
                      },
                child: Text(trained ? 'TRAINED THIS YEAR' : 'TRAIN'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                key: const Key('club-leave'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _leaveClub();
                },
                child: const Text('LEAVE CLUB'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _leaveClub() async {
    final confirmed = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave the club?'),
        content: const Text(
          'My performance and rank here would be gone. '
          'I could join another club next year.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            key: const Key('leave-club-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('LEAVE'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    await _announce(
      engine.leaveClub(),
      title: 'Left the Club',
      emoji: '🚪',
    );
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

    if (result.isSuccess) {
      widget.onChanged?.call();

      if (mounted) {
        Navigator.of(context).pop();
      }

      return;
    }

    await _announce(result, title: 'School', emoji: '🎒');
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
                      if (SchoolActions.hasClubs(stage) && education.club != null)
                        ClubCard(
                          education: education,
                          zoom: widget.zoom,
                          onTap: _openClub,
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
                        onTap: () => _announce(
                          engine.studyHarder(),
                          title: 'Study Time',
                          emoji: '📚',
                        ),
                      ),
                      if (SchoolActions.hasClubs(stage) && education.club == null)
                        _activity(
                          key: const Key('activity-club'),
                          emoji: '🎭',
                          title: 'Extracurricular',
                          subtitle: education.lastClubYear == year
                              ? 'Done for this year'
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

  /// 'none', 'friend' or 'best friend' for a person from this school.
  String _bondOf(SchoolNpc npc) {
    for (final friend in engine.state.lifeProgress.friends) {
      if (friend.id == npc.id) return friend.bestFriend ? 'best friend' : 'friend';
    }

    return 'none';
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
              traits: NpcTraits.forPerson(
                id: npc.id,
                gender: npc.gender,
                birthYear: npc.birthYear,
                currentYear: state.clock.currentYear,
              ),
              befriendable: npc.role.isStudent,
              bond: _bondOf(npc),
              romanceEligible: npc.role.isStudent,
              romance: state.lifeProgress.love.partnerId == npc.id
                  ? 'partner'
                  : 'none',
              playerHasPartner: state.lifeProgress.love.hasPartner,
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
                                      PipBar(
                                        widthFactor: 0.5,
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
