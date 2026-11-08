import 'package:flutter/material.dart';

import '../../domain/career/education_state.dart';
import '../../simulation/career/school_actions.dart';
import '../../simulation/engine/simulation_engine.dart';
import '../../simulation/narrative/school_narratives.dart';
import 'life_event_dialogs.dart';
import 'themed_cards.dart';

/// The player's club, shown under the education card: its name, the player's
/// role and a performance bar. Tap it to open the club's information.
class ClubCard extends StatelessWidget {
  const ClubCard({
    required this.education,
    required this.zoom,
    required this.onTap,
    super.key,
  });

  final EducationState education;
  final double zoom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * zoom;

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final club = SchoolActions.clubByName(education.club);

    if (club == null) return const SizedBox.shrink();

    return AccentCard(
      key: const Key('club-card'),
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
                    child: Text(club.emoji, style: TextStyle(fontSize: s(22))),
                  ),
                  SizedBox(width: s(8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          club.blurb,
                          style: theme.textTheme.bodySmall,
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
                      color: education.clubRank > 0
                          ? primary
                          : primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(s(10)),
                      border: Border.all(color: primary.withValues(alpha: 0.7)),
                    ),
                    child: Text(
                      club.titleFor(education.clubRank).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: education.clubRank > 0
                            ? theme.colorScheme.onPrimary
                            : null,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(width: s(6)),
                  ChevronBadge(zoom: zoom),
                ],
              ),
              SizedBox(height: s(7)),
              Row(
                children: [
                  Text(
                    '◆ PERFORMANCE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${education.clubPerformance}/100',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: s(3)),
              PipBar(
                barKey: const Key('club-performance-bar'),
                value: education.clubPerformance / 100,
                height: s(8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tells the player about a club promotion they have not seen yet, then marks
/// it as seen. Does nothing when there is none.
Future<void> showClubPromotionIfAny(
  BuildContext context,
  SimulationEngine engine,
) async {
  final rank = engine.clubPromotion;

  if (rank == null) return;

  final education = engine.state.lifeProgress.education;
  final club = SchoolActions.clubByName(education.club);

  engine.acknowledgeClubPromotion();

  if (club == null) return;

  final title = club.titleFor(rank);
  final text = SchoolNarratives.promotion(
    clubName: club.name,
    title: title,
    rank: rank,
    school: education.schoolName ?? 'school',
  );

  await showTapToCloseOverlay(
    context,
    dialogKey: const Key('club-promotion'),
    title: rank == 2 ? 'NEW ${title.toUpperCase()}!' : 'PROMOTION!',
    emoji: rank == 2 ? '👑' : '🎖️',
    text: text,
    body: Builder(
      builder: (bodyContext) {
        final theme = Theme.of(bodyContext);
        final primary = theme.colorScheme.primary;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(text, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${club.emoji}  ${title.toUpperCase()}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
