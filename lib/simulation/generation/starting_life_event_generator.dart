import '../../core/random/seeded_random.dart';
import '../../domain/character/starting_background.dart';
import '../../domain/event/simulation_event.dart';
import '../../domain/family/family_household.dart';
import '../../domain/family/parent_npc.dart';
import '../../domain/family/family_asset.dart';

class StartingLifeEventGenerator {
  const StartingLifeEventGenerator._();

  static const Map<StartingBackgroundTier, List<_EventTemplate>>
      _templates = {
    StartingBackgroundTier.struggling: [
      _EventTemplate(
        title: 'Growing Up Against the Odds',
        description:
            'You were born into a struggling household where '
            'even ordinary expenses can become difficult decisions. '
            'Your family has little financial room for unexpected '
            'problems, and building a secure future will take time '
            'and sacrifice. Your early life begins with real '
            'challenges, but your circumstances do not decide '
            'the person you will become.',
      ),
      _EventTemplate(
        title: 'A Household Under Pressure',
        description:
            'Your family begins this chapter of life with limited '
            'financial security. Work may not always provide enough '
            'income, savings are difficult to build, and an unexpected '
            'expense can affect the entire household. The adults '
            'around you must carefully balance immediate needs '
            'against hopes for a better future.',
      ),
      _EventTemplate(
        title: 'Hope Beyond Hardship',
        description:
            'You enter the world in a family that cannot easily '
            'afford every opportunity it would like to provide. '
            'Your household must make careful choices about daily '
            'needs, education, and future plans. Although money '
            'creates limits, the support, sacrifices, and decisions '
            'within your family may still open a different path '
            'for your life.',
      ),
    ],
    StartingBackgroundTier.workingClass: [
      _EventTemplate(
        title: 'A Family Built on Hard Work',
        description:
            'You were born into a working-class household where '
            'daily life depends on earning a living and managing '
            'each paycheck carefully. Your family works to keep '
            'the household running, but large expenses can still '
            'put pressure on its finances. Stability is possible, '
            'though it often depends on steady work and careful '
            'planning.',
      ),
      _EventTemplate(
        title: 'Every Paycheck Matters',
        description:
            'Your family relies on work and regular income to '
            'cover everyday needs. There may be enough for the '
            'essentials, but saving for major purchases or dealing '
            'with an unexpected bill requires careful decisions. '
            'Your early life begins in a household where persistence '
            'and practical choices matter more than luxury.',
      ),
      _EventTemplate(
        title: 'Building a Better Future',
        description:
            'You grow up in a family that hopes hard work will '
            'create more opportunities for the next generation. '
            'Your household aims to provide a decent upbringing '
            'and a useful education while staying within its means. '
            'The path ahead may not be easy, but your family has '
            'a foundation from which to work toward greater '
            'security and opportunity.',
      ),
    ],
    StartingBackgroundTier.middleClass: [
      _EventTemplate(
        title: 'A Stable Start in Life',
        description:
            'You were born into a middle-class household with '
            'a relatively stable standard of living. Everyday '
            'needs can generally be met, and your family has some '
            'room to plan beyond the next bill. Financial choices '
            'still matter, but your early circumstances provide '
            'a reasonable foundation for education, personal '
            'development, and future ambitions.',
      ),
      _EventTemplate(
        title: 'An Investment in Education',
        description:
            'Your family sees education and personal development '
            'as important investments in your future. Within its '
            'means, your household tries to provide useful learning '
            'opportunities and a supportive environment. You may '
            'have room to explore your interests and develop your '
            'abilities, while still learning that time, effort, '
            'and financial resources have their limits.',
      ),
      _EventTemplate(
        title: 'Room to Find Your Own Path',
        description:
            'Your early years begin in a household that can offer '
            'a degree of comfort without unlimited resources. '
            'Your family may be able to support hobbies, learning, '
            'and new experiences while still making practical '
            'decisions about money. You have room to discover '
            'your interests and ambitions, but the direction '
            'of your life remains yours to shape.',
      ),
    ],
    StartingBackgroundTier.upperMiddleClass: [
      _EventTemplate(
        title: 'Growing Up with Greater Opportunity',
        description:
            'You were born into a comfortable household with '
            'resources to support a wider range of opportunities. '
            'Your family may be able to afford quality education, '
            'enrichment activities, and experiences beyond basic '
            'daily needs. These advantages give you more options '
            'early in life, although making the most of them '
            'will still require your own effort and choices.',
      ),
      _EventTemplate(
        title: 'High Expectations, Strong Support',
        description:
            'Your family has the means to invest in education, '
            'skills, and long-term plans. You may grow up with '
            'access to additional classes, enriching activities, '
            'and a comfortable home environment. That support '
            'can create valuable opportunities, but it may also '
            'come with expectations about achievement and the '
            'future you are expected to build.',
      ),
      _EventTemplate(
        title: 'A World of Possibilities',
        description:
            'Your household enjoys a level of financial comfort '
            'that makes it easier to explore different interests '
            'and experiences. Your family may have the freedom '
            'to plan ahead rather than focus only on immediate '
            'expenses. This wider perspective can introduce you '
            'to new ambitions and possibilities, even though '
            'your future is not guaranteed by your upbringing.',
      ),
    ],
    StartingBackgroundTier.wealthy: [
      _EventTemplate(
        title: 'Born into Financial Security',
        description:
            'You were born into a wealthy family with substantial '
            'financial resources. Quality education, comfortable '
            'living arrangements, and additional opportunities '
            'may be readily available to you. Your family has '
            'more freedom to plan for the future than most, '
            'but wealth alone cannot decide your values, '
            'relationships, or what you eventually accomplish.',
      ),
      _EventTemplate(
        title: 'Connections and Opportunity',
        description:
            'Your family enjoys considerable financial comfort '
            'and may be connected to professional, business, '
            'or social circles that offer valuable experience. '
            'You could encounter opportunities to learn about '
            'business, investment, and influential careers earlier '
            'than many people. These connections can be useful, '
            'but trust and lasting achievement still have to '
            'be earned.',
      ),
      _EventTemplate(
        title: 'A Legacy in the Making',
        description:
            'You enter life in a household with significant '
            'resources and the ability to think beyond immediate '
            'financial needs. Your family may own valuable assets, '
            'investments, or a successful business, and may begin '
            'teaching you about responsibility and long-term '
            'planning as you grow. You inherit advantages, '
            'but how you use them will shape your own story.',
      ),
    ],
    StartingBackgroundTier.veryWealthy: [
      _EventTemplate(
        title: 'Born into a Powerful Family Legacy',
        description:
            'You were born into a family whose wealth may span '
            'major businesses, extensive investments, valuable '
            'properties, or generations of accumulated assets. '
            'Your household can provide extraordinary resources '
            'and access to exclusive opportunities. Alongside '
            'these advantages, family legacy may bring complex '
            'responsibilities and expectations about the future.',
      ),
      _EventTemplate(
        title: 'A Name with Influence',
        description:
            'Your family possesses exceptional wealth and may '
            'have a recognized presence in business or influential '
            'social circles. Its reputation can introduce you '
            'to people and experiences far beyond ordinary life. '
            'Yet a famous name can bring scrutiny and pressure '
            'as well as opportunity, leaving you to decide '
            'whether to follow the family path or create one '
            'of your own.',
      ),
      _EventTemplate(
        title: 'The Next Generation of a Fortune',
        description:
            'You begin life surrounded by the resources of a '
            'family that may own large businesses, substantial '
            'investments, or a broad portfolio of assets. Your '
            'future could involve international education, '
            'leadership, entrepreneurship, or responsibility '
            'for preserving family wealth. Such a beginning '
            'provides extraordinary possibilities, but managing '
            'them wisely is a challenge of its own.',
      ),
    ],
  };

  static SimulationEvent generate({
    required SeededRandom random,
    required int year,
    required StartingBackground background,
    FamilyHousehold? household,
  }) {
    final templates = _templates[background.tier];

    if (templates == null || templates.isEmpty) {
      throw StateError(
        'No starting life events are defined for '
        '${background.tier.name}.',
      );
    }

    final template = templates[random.nextInt(templates.length)];

    if (household == null) {
      return SimulationEvent(
        id: 'starting-life-event-$year',
        type: SimulationEventType.startingLifeEvent,
        year: year,
        title: template.title,
        description: template.description,
      );
    }

    return SimulationEvent(
      id: 'starting-life-event-$year',
      type: SimulationEventType.startingLifeEvent,
      year: year,
      title: _householdEventTitle(
        household,
        fallbackTitle: template.title,
      ),
      description: _householdEventDescription(
        household,
        background: background,
      ),
    );
  }

  static String _householdEventTitle(
    FamilyHousehold household, {
    required String fallbackTitle,
  }) {
    if (household.housingStatus == HousingStatus.homeless) {
      return 'A Family Without Stable Housing';
    }

    if (household.housingStatus == HousingStatus.temporary) {
      return 'An Uncertain Place to Call Home';
    }

    if (household.annualIncome.minorUnits <
        household.annualLivingCosts.minorUnits) {
      return 'A Family Facing Financial Pressure';
    }

    if (household.assets.any(
      (asset) => asset.type == FamilyAssetType.business,
    )) {
      return 'A Family with Business Interests';
    }

    if (household.cashSavings.minorUnits == 0) {
      return 'A Family Building Financial Security';
    }

    return fallbackTitle;
  }

  static String _householdEventDescription(
    FamilyHousehold household, {
    required StartingBackground background,
  }) {
    final parentDescriptions = household.parents.map((parent) {
      final occupation = parent.occupation;

      final employmentDescription = switch (parent.employmentStatus) {
        EmploymentStatus.employed =>
          occupation == null || occupation.trim().isEmpty
              ? 'works as an employee'
              : 'works as a $occupation',
        EmploymentStatus.selfEmployed =>
          occupation == null || occupation.trim().isEmpty
              ? 'works independently'
              : 'is self-employed as a $occupation',
        EmploymentStatus.unemployed => 'is currently unemployed',
        EmploymentStatus.retired => 'is retired',
        EmploymentStatus.homemaker => 'takes care of the household',
        EmploymentStatus.unableToWork => 'is unable to work',
      };

      return '${parent.fullName} $employmentDescription.';
    }).join(' ');

    final parentsDescription = household.parents.isEmpty
        ? 'No parent or guardian employment details are recorded.'
        : parentDescriptions;

    final incomeDescription =
        household.annualIncome.minorUnits == 0
            ? 'The household currently has no recorded annual income.'
            : household.annualIncome.minorUnits <
                    household.annualLivingCosts.minorUnits
                ? 'The household income is lower than its estimated '
                    'annual living costs, creating financial pressure.'
                : household.annualIncome.minorUnits ==
                        household.annualLivingCosts.minorUnits
                    ? 'The household income matches its estimated '
                        'annual living costs, leaving little room '
                        'for unexpected expenses.'
                    : 'The household income covers its estimated '
                        'annual living costs, although other '
                        'obligations may affect its financial flexibility.';

    final housingDescription = switch (household.housingStatus) {
      HousingStatus.rented =>
        'The family lives in rented housing.',
      HousingStatus.familyOwned =>
        'The family lives in a home owned by the family.',
      HousingStatus.ownedWithMortgage =>
        'The family lives in a home financed with a mortgage.',
      HousingStatus.temporary =>
        'The family lives in temporary accommodation.',
      HousingStatus.providedByOthers =>
        'The family accommodation is provided by others.',
      HousingStatus.homeless =>
        'The family currently has no stable housing.',
    };

    final savingsDescription =
        household.cashSavings.minorUnits == 0
            ? 'The household has no recorded cash savings.'
            : 'The household has recorded cash savings.';

    final assetDescription = household.assets.isEmpty
        ? 'No additional family assets are recorded.'
        : 'The household has ${household.assets.length} recorded '
            'family assets: '
            '${household.assets.map((asset) => asset.name).join(', ')}.';

    final debtDescription = household.totalDebt.minorUnits > 0
        ? 'The household has recorded outstanding debt.'
        : 'No outstanding household debt is recorded.';

    return 'Your early circumstances are shaped by the household '
        'you were born into. The details below reflect the family '
        'situation recorded at the beginning of your life. '
        'Your starting background is classified as '
        '${background.label}. '
        '$parentsDescription '
        '$housingDescription '
        '$incomeDescription '
        '$savingsDescription '
        '$assetDescription '
        '$debtDescription '
        'These circumstances influence the opportunities and '
        'challenges around your childhood, but they do not determine '
        'the person you will become.';
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
