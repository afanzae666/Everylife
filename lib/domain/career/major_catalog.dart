/// The area a degree is in. Jobs ask for a field, not for one exact major.
enum StudyField {
  business('Business & Economics'),
  engineering('Engineering'),
  computerScience('Computer Science'),
  law('Law'),
  education('Education'),
  artsDesign('Arts & Design'),
  medicine('Medicine'),
  nursing('Nursing'),
  psychology('Psychology'),
  science('Natural Sciences'),
  architecture('Architecture'),
  communications('Communications'),
  pharmacy('Pharmacy'),
  dentistry('Dentistry'),
  aviation('Aviation');

  const StudyField(this.label);

  final String label;
}

/// The kind of place that teaches a major.
enum InstitutionType {
  /// A university with many majors.
  general('General University'),

  /// A school for one profession (medical school, aviation academy, ...).
  specialized('Specialized Institution');

  const InstitutionType(this.label);

  final String label;
}

/// One study program: what it takes to get in, how long it lasts and what
/// it costs. Every program is configuration of the same system.
class MajorDefinition {
  const MajorDefinition({
    required this.id,
    required this.name,
    required this.emoji,
    required this.field,
    required this.blurb,
    required this.years,
    required this.tuition,
    required this.minGrades,
    required this.minIntelligence,
    this.institution = InstitutionType.general,
    this.campusName,
  });

  final String id;
  final String name;
  final String emoji;
  final StudyField field;

  /// One line shown in the picker.
  final String blurb;

  /// How many years the program lasts.
  final int years;

  /// Total tuition for the whole program, paid once, in baseline minor
  /// units (US cents), before the country's cost of living is applied.
  final int tuition;

  /// Grades (0-100) that make admission likely.
  final int minGrades;

  /// Intelligence (0-100) that makes admission likely.
  final int minIntelligence;

  final InstitutionType institution;

  /// The name of the school for specialized programs, for example
  /// "Medical School". General majors are taught at the university.
  final String? campusName;
}

abstract final class MajorCatalog {
  /// Length used when the major is unknown.
  static const int defaultYears = 4;

  static MajorDefinition? byId(String? id) {
    if (id == null) return null;

    for (final major in all) {
      if (major.id == id) return major;
    }

    return null;
  }

  /// Majors taught at the given kind of institution.
  static List<MajorDefinition> at(InstitutionType type) => [
        for (final major in all)
          if (major.institution == type) major,
      ];

  static const List<MajorDefinition> all = [
    MajorDefinition(
      id: 'business',
      name: 'Business & Economics',
      emoji: '📈',
      field: StudyField.business,
      blurb: 'Markets, money and management.',
      years: 3,
      tuition: 1800000,
      minGrades: 50,
      minIntelligence: 40,
    ),
    MajorDefinition(
      id: 'engineering',
      name: 'Engineering',
      emoji: '🏗️',
      field: StudyField.engineering,
      blurb: 'Build bridges, machines and the future.',
      years: 5,
      tuition: 4500000,
      minGrades: 65,
      minIntelligence: 60,
    ),
    MajorDefinition(
      id: 'computer_science',
      name: 'Computer Science',
      emoji: '💻',
      field: StudyField.computerScience,
      blurb: 'Code, data and clever machines.',
      years: 4,
      tuition: 3200000,
      minGrades: 60,
      minIntelligence: 55,
    ),
    MajorDefinition(
      id: 'law',
      name: 'Law',
      emoji: '⚖️',
      field: StudyField.law,
      blurb: 'Argue, read the fine print and win.',
      years: 4,
      tuition: 4800000,
      minGrades: 70,
      minIntelligence: 60,
    ),
    MajorDefinition(
      id: 'education',
      name: 'Education',
      emoji: '🍎',
      field: StudyField.education,
      blurb: 'Learn how to teach the next generation.',
      years: 4,
      tuition: 2000000,
      minGrades: 45,
      minIntelligence: 40,
    ),
    MajorDefinition(
      id: 'arts_design',
      name: 'Arts & Design',
      emoji: '🎨',
      field: StudyField.artsDesign,
      blurb: 'Make things people want to look at.',
      years: 3,
      tuition: 1500000,
      minGrades: 40,
      minIntelligence: 35,
    ),
    MajorDefinition(
      id: 'psychology',
      name: 'Psychology',
      emoji: '🧠',
      field: StudyField.psychology,
      blurb: 'Why people think, feel and do what they do.',
      years: 3,
      tuition: 2400000,
      minGrades: 55,
      minIntelligence: 50,
    ),
    MajorDefinition(
      id: 'science',
      name: 'Natural Sciences',
      emoji: '🔬',
      field: StudyField.science,
      blurb: 'Labs, experiments and the rules of nature.',
      years: 4,
      tuition: 3000000,
      minGrades: 60,
      minIntelligence: 55,
    ),
    MajorDefinition(
      id: 'architecture',
      name: 'Architecture',
      emoji: '🏛️',
      field: StudyField.architecture,
      blurb: 'Design the buildings people will live in.',
      years: 5,
      tuition: 4200000,
      minGrades: 62,
      minIntelligence: 58,
    ),
    MajorDefinition(
      id: 'communications',
      name: 'Communications',
      emoji: '🎙️',
      field: StudyField.communications,
      blurb: 'Media, storytelling and getting heard.',
      years: 3,
      tuition: 1900000,
      minGrades: 45,
      minIntelligence: 40,
    ),
    MajorDefinition(
      id: 'medicine',
      name: 'Medicine',
      emoji: '🩺',
      field: StudyField.medicine,
      blurb: 'Long years of study to save lives.',
      years: 6,
      tuition: 12000000,
      minGrades: 80,
      minIntelligence: 70,
      institution: InstitutionType.specialized,
      campusName: 'Medical School',
    ),
    MajorDefinition(
      id: 'nursing',
      name: 'Nursing',
      emoji: '💉',
      field: StudyField.nursing,
      blurb: 'Care for patients on the front line.',
      years: 3,
      tuition: 2100000,
      minGrades: 55,
      minIntelligence: 45,
      institution: InstitutionType.specialized,
      campusName: 'Nursing College',
    ),
    MajorDefinition(
      id: 'pharmacy',
      name: 'Pharmacy',
      emoji: '💊',
      field: StudyField.pharmacy,
      blurb: 'Medicines, doses and the chemistry behind them.',
      years: 5,
      tuition: 6500000,
      minGrades: 70,
      minIntelligence: 62,
      institution: InstitutionType.specialized,
      campusName: 'Pharmacy College',
    ),
    MajorDefinition(
      id: 'dentistry',
      name: 'Dentistry',
      emoji: '🦷',
      field: StudyField.dentistry,
      blurb: 'Steady hands, bright smiles.',
      years: 6,
      tuition: 11000000,
      minGrades: 78,
      minIntelligence: 68,
      institution: InstitutionType.specialized,
      campusName: 'Dental School',
    ),
    MajorDefinition(
      id: 'aviation',
      name: 'Aviation',
      emoji: '✈️',
      field: StudyField.aviation,
      blurb: 'Learn to fly, from the simulator to the sky.',
      years: 3,
      tuition: 8500000,
      minGrades: 65,
      minIntelligence: 55,
      institution: InstitutionType.specialized,
      campusName: 'Aviation Academy',
    ),
  ];
}
