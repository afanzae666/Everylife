import 'education_state.dart';

/// Groups of jobs, shown as headers in the job list.
enum JobSector {
  service('Service & Retail'),
  transport('Transport'),
  trades('Construction & Trades'),
  farming('Farming & Fishing'),
  office('Office & Business'),
  health('Health'),
  education('Education'),
  tech('Tech & Engineering'),
  public('Public Service'),
  creative('Food & Media');

  const JobSector(this.label);

  final String label;
}

/// A kind of job the player can hold and climb the ladder of.
class JobDefinition {
  const JobDefinition({
    required this.id,
    required this.title,
    required this.rankTitles,
    required this.baseSalary,
    required this.emoji,
    required this.sector,
    this.minAge = 18,
    this.requiredEducation = EducationLevel.none,
  });

  final String id;

  /// Field name shown in lists, for example "Nurse".
  final String title;

  /// Titles for ranks 0 to 3.
  final List<String> rankTitles;

  /// Entry-level yearly salary in baseline minor units (US cents).
  final int baseSalary;

  /// The picture shown next to the job name everywhere in the game.
  final String emoji;

  /// The part of the economy this job belongs to.
  final JobSector sector;

  final int minAge;
  final EducationLevel requiredEducation;

  /// Salary at [rank], in baseline minor units.
  int salaryAt(int rank) {
    final safeRank = rank.clamp(0, JobCatalog.rankMultipliers.length - 1).toInt();

    return baseSalary * JobCatalog.rankMultipliers[safeRank] ~/ 100;
  }

  String titleAt(int rank) {
    final safeRank = rank.clamp(0, rankTitles.length - 1).toInt();

    return rankTitles[safeRank];
  }
}

abstract final class JobCatalog {
  /// Salary percentage of the entry level for ranks 0 to 3.
  static const List<int> rankMultipliers = [100, 135, 180, 250];

  static JobDefinition? byId(String id) {
    for (final job in all) {
      if (job.id == id) return job;
    }

    return null;
  }

  static bool meetsEducation(EducationLevel have, EducationLevel need) {
    return have.index >= need.index;
  }

  static const List<JobDefinition> all = [
    JobDefinition(
      id: 'cashier',
      title: 'Cashier',
      rankTitles: ['Cashier', 'Senior Cashier', 'Shift Supervisor', 'Store Manager'],
      baseSalary: 1400000,
      emoji: '🛒',
      sector: JobSector.service,
      minAge: 16,
    ),
    JobDefinition(
      id: 'server',
      title: 'Restaurant Server',
      rankTitles: ['Server', 'Head Server', 'Floor Manager', 'Restaurant Manager'],
      baseSalary: 1300000,
      emoji: '🍽️',
      sector: JobSector.service,
      minAge: 16,
    ),
    JobDefinition(
      id: 'barista',
      title: 'Barista',
      rankTitles: ['Barista', 'Senior Barista', 'Shift Lead', 'Cafe Manager'],
      baseSalary: 1300000,
      emoji: '☕',
      sector: JobSector.service,
      minAge: 16,
    ),
    JobDefinition(
      id: 'security_guard',
      title: 'Security Guard',
      rankTitles: ['Security Guard', 'Senior Guard', 'Security Supervisor', 'Head of Security'],
      baseSalary: 1600000,
      emoji: '🛡️',
      sector: JobSector.service,
    ),
    JobDefinition(
      id: 'sales',
      title: 'Sales Associate',
      rankTitles: ['Sales Associate', 'Senior Sales Rep', 'Sales Lead', 'Sales Director'],
      baseSalary: 2400000,
      emoji: '🛍️',
      sector: JobSector.service,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'delivery',
      title: 'Delivery Rider',
      rankTitles: ['Delivery Rider', 'Route Lead', 'Dispatcher', 'Logistics Manager'],
      baseSalary: 1500000,
      emoji: '🛵',
      sector: JobSector.transport,
      minAge: 16,
    ),
    JobDefinition(
      id: 'taxi_driver',
      title: 'Taxi Driver',
      rankTitles: ['Taxi Driver', 'Senior Driver', 'Fleet Supervisor', 'Taxi Company Owner'],
      baseSalary: 1700000,
      emoji: '🚕',
      sector: JobSector.transport,
    ),
    JobDefinition(
      id: 'bus_driver',
      title: 'Bus Driver',
      rankTitles: ['Bus Driver', 'Senior Bus Driver', 'Route Supervisor', 'Transit Manager'],
      baseSalary: 1900000,
      emoji: '🚌',
      sector: JobSector.transport,
    ),
    JobDefinition(
      id: 'truck_driver',
      title: 'Truck Driver',
      rankTitles: ['Truck Driver', 'Long-Haul Driver', 'Fleet Lead', 'Freight Manager'],
      baseSalary: 2300000,
      emoji: '🚚',
      sector: JobSector.transport,
      minAge: 21,
    ),
    JobDefinition(
      id: 'pilot',
      title: 'Pilot',
      rankTitles: ['First Officer', 'Captain', 'Senior Captain', 'Chief Pilot'],
      baseSalary: 9000000,
      emoji: '✈️',
      sector: JobSector.transport,
      minAge: 24,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'construction',
      title: 'Construction Worker',
      rankTitles: ['Laborer', 'Skilled Builder', 'Foreman', 'Site Manager'],
      baseSalary: 1800000,
      emoji: '👷',
      sector: JobSector.trades,
    ),
    JobDefinition(
      id: 'carpenter',
      title: 'Carpenter',
      rankTitles: ['Carpenter', 'Senior Carpenter', 'Master Carpenter', 'Workshop Owner'],
      baseSalary: 2000000,
      emoji: '🪚',
      sector: JobSector.trades,
    ),
    JobDefinition(
      id: 'mechanic',
      title: 'Mechanic',
      rankTitles: ['Apprentice Mechanic', 'Mechanic', 'Master Mechanic', 'Workshop Owner'],
      baseSalary: 2600000,
      emoji: '🔧',
      sector: JobSector.trades,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'electrician',
      title: 'Electrician',
      rankTitles: ['Apprentice Electrician', 'Electrician', 'Master Electrician', 'Contractor'],
      baseSalary: 3000000,
      emoji: '⚡',
      sector: JobSector.trades,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'plumber',
      title: 'Plumber',
      rankTitles: ['Apprentice Plumber', 'Plumber', 'Master Plumber', 'Plumbing Contractor'],
      baseSalary: 2800000,
      emoji: '🚰',
      sector: JobSector.trades,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'farmer',
      title: 'Farmer',
      rankTitles: ['Farm Hand', 'Farmer', 'Estate Manager', 'Farm Owner'],
      baseSalary: 1500000,
      emoji: '🌾',
      sector: JobSector.farming,
    ),
    JobDefinition(
      id: 'fisher',
      title: 'Fisher',
      rankTitles: ['Deckhand', 'Fisher', 'Boat Captain', 'Fishing Fleet Owner'],
      baseSalary: 1500000,
      emoji: '🎣',
      sector: JobSector.farming,
    ),
    JobDefinition(
      id: 'office_clerk',
      title: 'Office Clerk',
      rankTitles: ['Office Clerk', 'Senior Clerk', 'Team Lead', 'Office Manager'],
      baseSalary: 2200000,
      emoji: '📎',
      sector: JobSector.office,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'call_center',
      title: 'Call Center Agent',
      rankTitles: ['Call Center Agent', 'Senior Agent', 'Team Supervisor', 'Operations Manager'],
      baseSalary: 2000000,
      emoji: '🎧',
      sector: JobSector.office,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'accountant',
      title: 'Accountant',
      rankTitles: ['Junior Accountant', 'Accountant', 'Senior Accountant', 'Finance Director'],
      baseSalary: 4500000,
      emoji: '🧮',
      sector: JobSector.office,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'marketing',
      title: 'Marketing Specialist',
      rankTitles: ['Marketing Assistant', 'Marketing Specialist', 'Marketing Manager', 'Chief Marketing Officer'],
      baseSalary: 4200000,
      emoji: '📣',
      sector: JobSector.office,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'banker',
      title: 'Banker',
      rankTitles: ['Bank Teller', 'Loan Officer', 'Branch Manager', 'Regional Director'],
      baseSalary: 5000000,
      emoji: '🏦',
      sector: JobSector.office,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'lawyer',
      title: 'Lawyer',
      rankTitles: ['Junior Associate', 'Lawyer', 'Senior Counsel', 'Managing Partner'],
      baseSalary: 7000000,
      emoji: '⚖️',
      sector: JobSector.office,
      minAge: 24,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'nurse',
      title: 'Nurse',
      rankTitles: ['Nurse', 'Senior Nurse', 'Head Nurse', 'Director of Nursing'],
      baseSalary: 3800000,
      emoji: '🩺',
      sector: JobSector.health,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'pharmacist',
      title: 'Pharmacist',
      rankTitles: ['Pharmacy Assistant', 'Pharmacist', 'Senior Pharmacist', 'Pharmacy Owner'],
      baseSalary: 5500000,
      emoji: '💊',
      sector: JobSector.health,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'doctor',
      title: 'Doctor',
      rankTitles: ['Resident Doctor', 'Doctor', 'Senior Physician', 'Chief of Medicine'],
      baseSalary: 9000000,
      emoji: '🧑‍⚕️',
      sector: JobSector.health,
      minAge: 24,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'teacher',
      title: 'Teacher',
      rankTitles: ['Teacher', 'Senior Teacher', 'Head of Department', 'Principal'],
      baseSalary: 3200000,
      emoji: '🍎',
      sector: JobSector.education,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'professor',
      title: 'Professor',
      rankTitles: ['Lecturer', 'Assistant Professor', 'Associate Professor', 'Professor'],
      baseSalary: 5200000,
      emoji: '👨‍🏫',
      sector: JobSector.education,
      minAge: 28,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'principal',
      title: 'School Principal',
      rankTitles: ['Vice Principal', 'Assistant Principal', 'Principal', 'Head Principal'],
      baseSalary: 5000000,
      emoji: '🧑‍💼',
      sector: JobSector.education,
      minAge: 32,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'dean',
      title: 'University Dean',
      rankTitles: ['Associate Dean', 'Deputy Dean', 'Dean', 'Senior Dean'],
      baseSalary: 7500000,
      emoji: '🎓',
      sector: JobSector.education,
      minAge: 36,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'software_engineer',
      title: 'Software Engineer',
      rankTitles: ['Junior Developer', 'Software Engineer', 'Senior Engineer', 'Engineering Director'],
      baseSalary: 6000000,
      emoji: '💻',
      sector: JobSector.tech,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'civil_engineer',
      title: 'Civil Engineer',
      rankTitles: ['Junior Engineer', 'Engineer', 'Senior Engineer', 'Chief Engineer'],
      baseSalary: 5500000,
      emoji: '🏗️',
      sector: JobSector.tech,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'police',
      title: 'Police Officer',
      rankTitles: ['Police Officer', 'Detective', 'Police Captain', 'Police Chief'],
      baseSalary: 3200000,
      emoji: '👮',
      sector: JobSector.public,
      minAge: 20,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'firefighter',
      title: 'Firefighter',
      rankTitles: ['Firefighter', 'Engineer Operator', 'Fire Captain', 'Fire Chief'],
      baseSalary: 3000000,
      emoji: '🚒',
      sector: JobSector.public,
      minAge: 20,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'chef',
      title: 'Chef',
      rankTitles: ['Line Cook', 'Sous Chef', 'Head Chef', 'Restaurant Owner'],
      baseSalary: 2500000,
      emoji: '👨‍🍳',
      sector: JobSector.creative,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'journalist',
      title: 'Journalist',
      rankTitles: ['Reporter', 'Journalist', 'Senior Editor', 'Editor in Chief'],
      baseSalary: 3800000,
      emoji: '📰',
      sector: JobSector.creative,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
  ];

  /// Jobs a self-employed parent may have (their own workshop, farm, etc.).
  static const List<String> selfEmployedJobIds = [
    'mechanic',
    'electrician',
    'plumber',
    'carpenter',
    'farmer',
    'fisher',
    'taxi_driver',
    'barista',
    'chef',
    'construction',
  ];
}
