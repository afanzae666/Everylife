
import '../../core/random/seeded_random.dart';
import '../../domain/character/starting_background.dart';
import '../../domain/event/simulation_event.dart';

class StartingLifeEventGenerator {
  const StartingLifeEventGenerator._();

  static const Map<StartingBackgroundTier, List<_EventTemplate>>
      _templates = {
    StartingBackgroundTier.struggling: [
      _EventTemplate(
        title: 'A Difficult Beginning',
        description:
            'Your early life begins with limited financial resources.',
      ),
      _EventTemplate(
        title: 'Making Ends Meet',
        description:
            'Your household must be careful with its limited resources.',
      ),
      _EventTemplate(
        title: 'A Modest Start',
        description:
            'Your early years begin without much financial security.',
      ),
    ],
    StartingBackgroundTier.workingClass: [
      _EventTemplate(
        title: 'A Working Household',
        description:
            'Your early life begins in a household built around hard work.',
      ),
      _EventTemplate(
        title: 'A Practical Start',
        description:
            'Your household focuses on meeting everyday needs and building stability.',
      ),
      _EventTemplate(
        title: 'Everyday Opportunities',
        description:
            'Your early life begins with ordinary resources and opportunities.',
      ),
    ],
    StartingBackgroundTier.middleClass: [
      _EventTemplate(
        title: 'A Stable Beginning',
        description:
            'Your early life begins in a relatively stable household.',
      ),
      _EventTemplate(
        title: 'Room to Grow',
        description:
            'Your household has some room to support your early development.',
      ),
      _EventTemplate(
        title: 'A Balanced Start',
        description:
            'Your early years begin with a reasonable level of stability.',
      ),
    ],
    StartingBackgroundTier.upperMiddleClass: [
      _EventTemplate(
        title: 'A Comfortable Beginning',
        description:
            'Your early life begins with comfortable resources and opportunities.',
      ),
      _EventTemplate(
        title: 'More Room to Explore',
        description:
            'Your household can provide additional opportunities during your early years.',
      ),
      _EventTemplate(
        title: 'A Promising Start',
        description:
            'Your early life begins with a strong degree of household stability.',
      ),
    ],
    StartingBackgroundTier.wealthy: [
      _EventTemplate(
        title: 'A Life of Privilege',
        description:
            'Your early life begins with substantial family resources.',
      ),
      _EventTemplate(
        title: 'Access to Opportunities',
        description:
            'Your household has resources that can open additional doors.',
      ),
      _EventTemplate(
        title: 'A Wealthy Beginning',
        description:
            'Your early years begin with considerable financial advantages.',
      ),
    ],
    StartingBackgroundTier.veryWealthy: [
      _EventTemplate(
        title: 'Born into Great Wealth',
        description:
            'Your early life begins with exceptional family resources.',
      ),
      _EventTemplate(
        title: 'Exceptional Opportunities',
        description:
            'Your household has access to substantial resources and opportunities.',
      ),
      _EventTemplate(
        title: 'A Highly Privileged Start',
        description:
            'Your early years begin with extraordinary financial advantages.',
      ),
    ],
  };

  static SimulationEvent generate({
    required SeededRandom random,
    required int year,
    required String playerName,
    required StartingBackground background,
  }) {
    final templates = _templates[background.tier];

    if (templates == null || templates.isEmpty) {
      throw StateError(
        'No starting life events are defined for '
        '${background.tier.name}.',
      );
    }

    final template = templates[random.nextInt(templates.length)];

    return SimulationEvent(
      id: 'starting-life-event-$year',
      type: SimulationEventType.startingLifeEvent,
      year: year,
      title: template.title,
      description: template.description,
    );
  }
}

class _EventTemplate {
  const _EventTemplate({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
