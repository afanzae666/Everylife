import '../career/school_npc.dart';
import '../character/cultural_name_catalog.dart';
import '../character/gender.dart';

/// Numbers and rules for dating and having children.
abstract final class LoveRules {
  /// Dating opens at the start of high school.
  static const int minDatingAge = 15;

  /// Intimacy and pregnancy open here, for both people.
  static const int adultAge = 18;

  /// While one of the two is under 18 they must be close in age.
  static const int maxMinorGap = 3;

  /// Relationship needed to ask someone out.
  static const int dateAt = 60;

  /// Relationship an ex needs before they will consider getting back together.
  static const int getBackAt = 50;

  /// At or below this, a person may refuse to interact at all.
  static const int refuseAtOrBelow = 10;

  /// Relationship needed to get intimate with someone who is not my
  /// partner, and the chance (percent) that a partner finds out.
  static const int hookUpAt = 50;
  static const int caughtChance = 30;

  /// Relationship needed before the relationship can get intimate.
  static const int intimacyAt = 70;

  // ------------------------------------------------------------ Milestones

  static const String stageDating = 'dating';
  static const String stageEngaged = 'engaged';
  static const String stageMarried = 'married';

  /// Relationship needed to propose, and years of dating before it.
  static const int engageAt = 75;
  static const int yearsBeforeEngagement = 1;

  /// Relationship needed to marry, and years engaged before the wedding.
  static const int marryAt = 80;
  static const int yearsBeforeWedding = 1;

  /// Prenup choices. [share] is the part of the player's cash the spouse
  /// takes in a divorce.
  static const List<LoveOption> prenups = [
    LoveOption(
      id: 'none',
      label: 'No prenup',
      blurb: 'Everything is shared. Romantic, and risky.',
      share: 50,
    ),
    LoveOption(
      id: 'fair',
      label: 'Fair prenup',
      blurb: 'A sensible agreement for both of us.',
      costBase: -150000,
      share: 20,
    ),
    LoveOption(
      id: 'ironclad',
      label: 'Ironclad prenup',
      blurb: 'My lawyers wrote it. My partner may feel hurt.',
      costBase: -300000,
      share: 0,
      relation: -10,
    ),
  ];

  static const List<LoveOption> rings = [
    LoveOption(
      id: 'promise',
      label: 'Promise ring',
      blurb: 'Cheap and sweet. The thought counts.',
      costBase: -5000,
    ),
    LoveOption(
      id: 'simple',
      label: 'Simple band',
      blurb: 'Tasteful and simple.',
      costBase: -30000,
      bonus: 3,
    ),
    LoveOption(
      id: 'diamond',
      label: 'Diamond ring',
      blurb: 'It sparkles. So does my debt.',
      costBase: -300000,
      bonus: 8,
    ),
    LoveOption(
      id: 'luxury',
      label: 'Luxury ring',
      blurb: 'Ridiculously expensive. Impossible to say no to.',
      costBase: -1500000,
      bonus: 14,
    ),
  ];

  static const List<LoveOption> weddings = [
    LoveOption(
      id: 'elope',
      label: 'Quick signing',
      blurb: 'Two signatures and a free coffee. Romantic on a budget.',
      happiness: 2,
    ),
    LoveOption(
      id: 'courthouse',
      label: 'Courthouse wedding',
      blurb: 'Quick, quiet and cheap.',
      costBase: -30000,
      happiness: 4,
    ),
    LoveOption(
      id: 'backyard',
      label: 'Backyard party',
      blurb: 'Friends, family and a very ambitious barbecue.',
      costBase: -400000,
      happiness: 8,
    ),
    LoveOption(
      id: 'grand',
      label: 'Grand wedding',
      blurb: 'A hall, a band and far too many cousins.',
      costBase: -2500000,
      happiness: 12,
    ),
  ];

  static LoveOption? option(List<LoveOption> list, String id) {
    for (final item in list) {
      if (item.id == id) return item;
    }

    return null;
  }

  /// "Girlfriend", "Fiancée", "Husband"... the word for a partner.
  static String partnerLabel(String stage, Gender gender) {
    final female = gender == Gender.female;

    return switch (stage) {
      stageMarried => female ? 'Wife' : 'Husband',
      stageEngaged => female ? 'Fiancée' : 'Fiancé',
      _ => female ? 'Girlfriend' : 'Boyfriend',
    };
  }

  static String exLabel(Gender gender, {bool wasSpouse = false}) {
    if (!wasSpouse) return 'Ex';

    return gender == Gender.female ? 'Ex-wife' : 'Ex-husband';
  }

  static bool canDate(int playerAge, int otherAge) {
    if (playerAge < minDatingAge || otherAge < minDatingAge) return false;

    if (playerAge < adultAge || otherAge < adultAge) {
      return (playerAge - otherAge).abs() <= maxMinorGap;
    }

    return true;
  }

  static bool canBeIntimate(int playerAge, int otherAge) =>
      playerAge >= adultAge && otherAge >= adultAge;
}

/// One choice in an engagement, prenup or wedding pop-up.
class LoveOption {
  const LoveOption({
    required this.id,
    required this.label,
    required this.blurb,
    this.costBase = 0,
    this.share = 0,
    this.bonus = 0,
    this.relation = 0,
    this.happiness = 0,
  });

  final String id;
  final String label;
  final String blurb;

  /// Money change in baseline cents (negative spends money).
  final int costBase;

  /// Prenups: percent of the player's cash the spouse takes in a divorce.
  final int share;

  /// Rings: extra chance of a yes.
  final int bonus;

  /// Change in the relationship when picked.
  final int relation;

  /// Weddings: happiness gained.
  final int happiness;
}

/// A child of the player. Looks, smarts and fertility come from both parents
/// (see `Genetics`), and they are saved, so they never change.
class ChildNpc {
  const ChildNpc({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthYear,
    required this.looks,
    required this.smarts,
    required this.fertilityBase,
    required this.skinTone,
    required this.hairColor,
    required this.eyeColor,
    required this.eyebrows,
    this.countryCode = 'ID',
    this.otherParentName = '',
    this.relationshipPercent = 80,
  });

  final String id;
  final String firstName;
  final String lastName;
  final Gender gender;
  final int birthYear;
  final int looks;
  final int smarts;
  final int fertilityBase;
  final String skinTone;
  final String hairColor;
  final String eyeColor;
  final String eyebrows;
  final String countryCode;

  /// Full name of the other parent (the player is the first one).
  final String otherParentName;
  final int relationshipPercent;

  String get fullName => CulturalNameCatalog.formatFullName(
        countryCode,
        firstName,
        lastName,
      );

  ChildNpc copyWith({int? relationshipPercent, String? firstName}) =>
      ChildNpc(
        id: id,
        firstName: firstName ?? this.firstName,
        lastName: lastName,
        gender: gender,
        birthYear: birthYear,
        looks: looks,
        smarts: smarts,
        fertilityBase: fertilityBase,
        skinTone: skinTone,
        hairColor: hairColor,
        eyeColor: eyeColor,
        eyebrows: eyebrows,
        countryCode: countryCode,
        otherParentName: otherParentName,
        relationshipPercent: relationshipPercent ?? this.relationshipPercent,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender.name,
        'birthYear': birthYear,
        'looks': looks,
        'smarts': smarts,
        'fertilityBase': fertilityBase,
        'skinTone': skinTone,
        'hairColor': hairColor,
        'eyeColor': eyeColor,
        'eyebrows': eyebrows,
        'countryCode': countryCode,
        'otherParentName': otherParentName,
        'relationshipPercent': relationshipPercent,
      };

  static ChildNpc? fromJson(Object? json) {
    if (json is! Map) return null;

    final id = json['id'];
    final first = json['firstName'];
    final last = json['lastName'];
    final birthYear = json['birthYear'];

    if (id is! String || first is! String || last is! String) return null;
    if (birthYear is! int) return null;

    int number(String key, int fallback) {
      final value = json[key];

      return value is int ? value.clamp(0, 100).toInt() : fallback;
    }

    String text(String key, String fallback) {
      final value = json[key];

      return value is String ? value : fallback;
    }

    final score = json['relationshipPercent'];

    return ChildNpc(
      id: id,
      firstName: first,
      lastName: last,
      gender: Gender.values.firstWhere(
        (value) => value.name == json['gender'],
        orElse: () => Gender.male,
      ),
      birthYear: birthYear,
      looks: number('looks', 60),
      smarts: number('smarts', 60),
      fertilityBase: number('fertilityBase', 70),
      skinTone: text('skinTone', 'medium'),
      hairColor: text('hairColor', 'black'),
      eyeColor: text('eyeColor', 'brown'),
      eyebrows: text('eyebrows', 'straight'),
      countryCode: text('countryCode', 'ID'),
      otherParentName: text('otherParentName', ''),
      relationshipPercent: score is int ? score.clamp(-100, 100).toInt() : 80,
    );
  }
}

/// A baby on the way. The birth happens at the next birthday.
class Pregnancy {
  const Pregnancy({
    required this.conceivedYear,
    required this.partner,
    this.decided = false,
  });

  final int conceivedYear;

  /// True once the player chose to keep the baby. (A pregnancy that was not
  /// answered yet is kept at birth.)
  final bool decided;

  Pregnancy copyWith({bool? decided}) => Pregnancy(
        conceivedYear: conceivedYear,
        partner: partner,
        decided: decided ?? this.decided,
      );

  /// The other parent when the baby was conceived.
  final SchoolNpc partner;

  Map<String, dynamic> toJson() => {
        'conceivedYear': conceivedYear,
        'partner': partner.toJson(),
        if (decided) 'decided': true,
      };

  static Pregnancy? fromJson(Object? json) {
    if (json is! Map) return null;

    final year = json['conceivedYear'];
    final partner = SchoolNpc.fromJson(json['partner']);

    if (year is! int || partner == null) return null;

    return Pregnancy(
      conceivedYear: year,
      partner: partner,
      decided: json['decided'] == true,
    );
  }
}

/// The player's romantic life and family of their own.
class LoveState {
  const LoveState({
    this.partnerId,
    this.partnerSince,
    this.pregnancy,
    this.children = const <ChildNpc>[],
    this.birthControl = const <String>{},
    this.exIds = const <String>{},
    this.stage = LoveRules.stageDating,
    this.stageSince,
    this.prenup,
    this.exSpouseIds = const <String>{},
    this.divorced = false,
  });

  /// 'dating', 'engaged' or 'married' for the current partner.
  final String stage;

  /// Year the current stage began.
  final int? stageSince;

  /// Prenup id chosen before the wedding ('none', 'fair', 'ironclad').
  final String? prenup;

  /// Exes who were once married to the player.
  final Set<String> exSpouseIds;

  /// True after the player went through a divorce.
  final bool divorced;

  bool get isEngaged => hasPartner && stage == LoveRules.stageEngaged;
  bool get isMarried => hasPartner && stage == LoveRules.stageMarried;

  /// People the player broke up with. They live on the Exes page, not in
  /// the friends list.
  final Set<String> exIds;

  /// Ids of women who use birth control.
  final Set<String> birthControl;

  /// Id of the boyfriend or girlfriend. They live in the friends list, so
  /// their relationship score is shared with every other screen.
  final String? partnerId;
  final int? partnerSince;
  final Pregnancy? pregnancy;
  final List<ChildNpc> children;

  bool get hasPartner => partnerId != null;

  bool get isEmpty =>
      partnerId == null &&
      pregnancy == null &&
      children.isEmpty &&
      birthControl.isEmpty &&
      exIds.isEmpty &&
      exSpouseIds.isEmpty &&
      !divorced;

  LoveState copyWith({
    String? partnerId,
    int? partnerSince,
    bool clearPartner = false,
    Pregnancy? pregnancy,
    bool clearPregnancy = false,
    List<ChildNpc>? children,
    Set<String>? birthControl,
    Set<String>? exIds,
    String? stage,
    int? stageSince,
    String? prenup,
    Set<String>? exSpouseIds,
    bool? divorced,
  }) =>
      LoveState(
        stage: clearPartner ? LoveRules.stageDating : (stage ?? this.stage),
        stageSince:
            clearPartner ? null : (stageSince ?? this.stageSince),
        prenup: clearPartner ? null : (prenup ?? this.prenup),
        exSpouseIds: exSpouseIds ?? this.exSpouseIds,
        divorced: divorced ?? this.divorced,
        partnerId: clearPartner ? null : (partnerId ?? this.partnerId),
        partnerSince: clearPartner ? null : (partnerSince ?? this.partnerSince),
        pregnancy: clearPregnancy ? null : (pregnancy ?? this.pregnancy),
        children: children ?? this.children,
        birthControl: birthControl ?? this.birthControl,
        exIds: exIds ?? this.exIds,
      );

  Map<String, dynamic> toJson() => {
        if (partnerId != null) 'partnerId': partnerId,
        if (partnerSince != null) 'partnerSince': partnerSince,
        if (pregnancy != null) 'pregnancy': pregnancy!.toJson(),
        if (children.isNotEmpty)
          'children': [for (final child in children) child.toJson()],
        if (birthControl.isNotEmpty) 'birthControl': birthControl.toList()..sort(),
        if (exIds.isNotEmpty) 'exIds': exIds.toList()..sort(),
        if (stage != LoveRules.stageDating) 'stage': stage,
        if (stageSince != null) 'stageSince': stageSince,
        if (prenup != null) 'prenup': prenup,
        if (exSpouseIds.isNotEmpty) 'exSpouseIds': exSpouseIds.toList()..sort(),
        if (divorced) 'divorced': true,
      };

  factory LoveState.fromJson(Object? json) {
    if (json is! Map) return const LoveState();

    final id = json['partnerId'];
    final since = json['partnerSince'];

    return LoveState(
      partnerId: id is String ? id : null,
      partnerSince: since is int ? since : null,
      pregnancy: Pregnancy.fromJson(json['pregnancy']),
      children: json['children'] is List
          ? [
              for (final raw in json['children'] as List)
                if (ChildNpc.fromJson(raw) case final child?) child,
            ]
          : const <ChildNpc>[],
      birthControl: json['birthControl'] is List
          ? (json['birthControl'] as List).whereType<String>().toSet()
          : const <String>{},
      exIds: json['exIds'] is List
          ? (json['exIds'] as List).whereType<String>().toSet()
          : const <String>{},
      stage: json['stage'] is String
          ? json['stage'] as String
          : LoveRules.stageDating,
      stageSince: json['stageSince'] is int ? json['stageSince'] as int : null,
      prenup: json['prenup'] is String ? json['prenup'] as String : null,
      exSpouseIds: json['exSpouseIds'] is List
          ? (json['exSpouseIds'] as List).whereType<String>().toSet()
          : const <String>{},
      divorced: json['divorced'] == true,
    );
  }
}

/// The "Marital Status" and "Children" rows of an information overlay.
abstract final class MaritalInfo {
  /// Shown from this age.
  static const int minAge = 15;

  /// [partnerName] is the boyfriend, girlfriend, fiancé(e) or spouse, if
  /// any. [married] changes the wording. [children] is the number of
  /// children: the row shows for anyone married or with children.
  static List<MapEntry<String, String>> rows({
    required int age,
    String? partnerName,
    bool married = false,
    bool widowed = false,
    bool divorced = false,
    String stage = LoveRules.stageDating,
    int children = 0,
  }) {
    if (age < minAge) return const [];

    final isMarried = married || stage == LoveRules.stageMarried;
    final status = widowed
        ? 'Widowed'
        : partnerName == null
            ? (divorced ? 'Divorced' : 'Single')
            : isMarried
                ? 'Married to $partnerName'
                : stage == LoveRules.stageEngaged
                    ? 'Engaged to $partnerName'
                    : 'Dating $partnerName';

    return [
      MapEntry('Marital Status', status),
      if (isMarried || children > 0)
        MapEntry('Children', '$children'),
    ];
  }
}
