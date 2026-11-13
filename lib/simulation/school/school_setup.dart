import 'dart:math' as math;

import '../../domain/career/education_state.dart';
import '../../domain/career/school_npc.dart';
import '../../domain/character/cultural_randomizer_catalog.dart';
import '../../domain/character/gender.dart';
import '../../domain/world/city_catalog.dart';
import '../../domain/world/country_catalog.dart';
import '../../domain/world/school_names.dart';
import '../../domain/world/world_state.dart';
import '../economy/npc_economy.dart';

/// Makes the school (its name, classmates and faculty) for the stage the
/// player is in. The result only depends on the player and the stage, so it
/// never uses the game's dice and a life always gets the same school.
abstract final class SchoolSetup {
  /// Returns [state] with a school filled in when the player studies and the
  /// school for the current stage does not exist yet.
  static WorldState ensure(WorldState state) {
    final education = state.lifeProgress.education;

    if (!education.isStudent) {
      return state;
    }

    if (education.schoolStage == education.stage &&
        education.schoolName != null &&
        education.npcs.isNotEmpty) {
      return state;
    }

    final player = state.player;
    final stage = education.stage;
    final seedText = '${player.id}|${stage.name}|${player.birthYear}';
    var seed = 17;

    for (final unit in seedText.codeUnits) {
      seed = (seed * 31 + unit) & 0x3fffffff;
    }

    final random = math.Random(seed);
    final countryCode = _supported(player.location?.countryCode);
    final location = player.location;
    final city = location == null ? null : CityCatalog.findById(location.cityId);
    final country = location == null
        ? null
        : CountryCatalog.findByCode(location.countryCode);
    final generatedName = SchoolNames.generate(
      countryCode: location?.countryCode ?? 'US',
      stage: stage,
      cityName: city?.name ?? country?.name ?? 'Springfield',
      random: random,
    );
    final campus = education.major?.campusName;
    final name = campus == null
        ? generatedName
        : '${city?.name ?? country?.name ?? 'Springfield'} $campus';
    final playerAge = player.ageAt(state.clock.currentYear);
    final isUniversity = stage == SchoolStage.university;

    var counter = 0;

    SchoolNpc make(SchoolRole role, int birthYear, int baseScore) {
      counter++;
      final gender = random.nextBool() ? Gender.male : Gender.female;

      return SchoolNpc(
        id: 'school-${stage.name}-$counter',
        firstName: CulturalRandomizerCatalog.randomFirstName(
          countryCode: countryCode,
          gender: gender,
          random: math.Random(random.nextInt(0x3fffffff)),
        ),
        lastName: CulturalRandomizerCatalog.randomLastName(
          countryCode: countryCode,
          random: math.Random(random.nextInt(0x3fffffff)),
        ),
        gender: gender,
        birthYear: birthYear,
        role: role,
        countryCode: countryCode,
        relationshipPercent: baseScore + random.nextInt(16),
      );
    }

    final year = state.clock.currentYear;
    final npcs = <SchoolNpc>[
      for (var i = 0; i < 7; i++)
        make(
          SchoolRole.classmate,
          player.birthYear + random.nextInt(3) - 1,
          30,
        ),
      for (var i = 0; i < 3; i++)
        make(
          isUniversity ? SchoolRole.professor : SchoolRole.teacher,
          year - (playerAge + 22 + random.nextInt(30)),
          30,
        ),
      make(
        isUniversity ? SchoolRole.dean : SchoolRole.principal,
        year - (playerAge + 40 + random.nextInt(18)),
        25,
      ),
    ];

    // Faculty are paid for real: their salary and savings come from the job
    // list, and the economy system keeps them going every year.
    final funded = [
      for (final npc in npcs)
        npc.role.isFaculty
            ? npc.copyWith(
                finance: NpcEconomy.forFaculty(
                  npc: npc,
                  age: year - npc.birthYear,
                ),
              )
            : npc,
    ];

    return state.copyWith(
      lifeProgress: state.lifeProgress.copyWith(
        education: education.copyWith(
          schoolName: name,
          // Drawn from its own random, so nothing else in the school shifts.
          isPrivateSchool: math.Random(seed ^ 0x5bd1).nextInt(100) <
              (isUniversity ? 35 : 25),
          schoolStage: stage,
          npcs: funded,
          clearClub: true,
        ),
      ),
    );
  }

  static String _supported(String? countryCode) {
    final code = (countryCode ?? '').toUpperCase();

    return CulturalRandomizerCatalog.supportsCountry(code) ? code : 'ID';
  }
}
