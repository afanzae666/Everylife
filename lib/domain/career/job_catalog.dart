import 'education_state.dart';

/// A kind of job the player can hold and climb the ladder of.
class JobDefinition {
  const JobDefinition({
    required this.id,
    required this.title,
    required this.rankTitles,
    required this.baseSalary,
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
    // No qualifications needed.
    JobDefinition(
      id: 'cashier',
      title: 'Cashier',
      rankTitles: ['Cashier', 'Senior Cashier', 'Shift Supervisor', 'Store Manager'],
      baseSalary: 1400000,
      minAge: 16,
    ),
    JobDefinition(
      id: 'server',
      title: 'Restaurant Server',
      rankTitles: ['Server', 'Head Server', 'Floor Manager', 'Restaurant Manager'],
      baseSalary: 1300000,
      minAge: 16,
    ),
    JobDefinition(
      id: 'delivery',
      title: 'Delivery Rider',
      rankTitles: ['Delivery Rider', 'Route Lead', 'Dispatcher', 'Logistics Manager'],
      baseSalary: 1500000,
      minAge: 16,
    ),
    JobDefinition(
      id: 'construction',
      title: 'Construction Worker',
      rankTitles: ['Laborer', 'Skilled Builder', 'Foreman', 'Site Manager'],
      baseSalary: 1800000,
    ),
    // High school diploma.
    JobDefinition(
      id: 'office_clerk',
      title: 'Office Clerk',
      rankTitles: ['Office Clerk', 'Senior Clerk', 'Team Lead', 'Office Manager'],
      baseSalary: 2200000,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'sales',
      title: 'Sales Associate',
      rankTitles: ['Sales Associate', 'Senior Sales Rep', 'Sales Lead', 'Sales Director'],
      baseSalary: 2400000,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'mechanic',
      title: 'Mechanic',
      rankTitles: ['Apprentice Mechanic', 'Mechanic', 'Master Mechanic', 'Workshop Owner'],
      baseSalary: 2600000,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'electrician',
      title: 'Electrician',
      rankTitles: ['Apprentice Electrician', 'Electrician', 'Master Electrician', 'Contractor'],
      baseSalary: 3000000,
      requiredEducation: EducationLevel.highSchool,
    ),
    JobDefinition(
      id: 'call_center',
      title: 'Call Center Agent',
      rankTitles: ['Call Center Agent', 'Senior Agent', 'Team Supervisor', 'Operations Manager'],
      baseSalary: 2000000,
      requiredEducation: EducationLevel.highSchool,
    ),
    // University degree.
    JobDefinition(
      id: 'teacher',
      title: 'Teacher',
      rankTitles: ['Teacher', 'Senior Teacher', 'Head of Department', 'Principal'],
      baseSalary: 3200000,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'nurse',
      title: 'Nurse',
      rankTitles: ['Nurse', 'Senior Nurse', 'Head Nurse', 'Director of Nursing'],
      baseSalary: 3800000,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'accountant',
      title: 'Accountant',
      rankTitles: ['Junior Accountant', 'Accountant', 'Senior Accountant', 'Finance Director'],
      baseSalary: 4500000,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'marketing',
      title: 'Marketing Specialist',
      rankTitles: ['Marketing Assistant', 'Marketing Specialist', 'Marketing Manager', 'Chief Marketing Officer'],
      baseSalary: 4200000,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'civil_engineer',
      title: 'Civil Engineer',
      rankTitles: ['Junior Engineer', 'Engineer', 'Senior Engineer', 'Chief Engineer'],
      baseSalary: 5500000,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
    JobDefinition(
      id: 'software_engineer',
      title: 'Software Engineer',
      rankTitles: ['Junior Developer', 'Software Engineer', 'Senior Engineer', 'Engineering Director'],
      baseSalary: 6000000,
      minAge: 22,
      requiredEducation: EducationLevel.bachelor,
    ),
  ];
}
