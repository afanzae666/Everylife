import '../character/cultural_name_catalog.dart';
import '../character/gender.dart';
import '../family/npc_finance.dart';

/// Who someone is at school or university.
enum SchoolRole {
  classmate('classmate', '🧑‍🎓'),
  teacher('teacher', '🧑‍🏫'),
  principal('principal', '🧑‍💼'),
  professor('professor', '👨‍🏫'),
  dean('dean', '🎓');

  const SchoolRole(this.label, this.emoji);

  /// Shown as the relationship label ("classmate", "teacher", ...).
  final String label;
  final String emoji;

  bool get isStudent => this == SchoolRole.classmate;

  bool get isFaculty => this != SchoolRole.classmate;
}

/// A classmate or a member of the faculty. They belong to one school and
/// can be talked to like family members.
class SchoolNpc {
  const SchoolNpc({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthYear,
    required this.role,
    this.countryCode = 'ID',
    this.relationshipPercent = 40,
    this.finance,
    this.bestFriend = false,
    this.bestFriendAsked = false,
  });

  final String id;
  final String firstName;
  final String lastName;
  final Gender gender;
  final int birthYear;
  final SchoolRole role;
  final String countryCode;
  final int relationshipPercent;

  /// Real job and savings of faculty (null for students).
  final NpcFinance? finance;

  /// Set for a friend the player made their best friend.
  final bool bestFriend;

  /// True once the player was asked about a best friendship and said no, so
  /// they are not asked again.
  final bool bestFriendAsked;

  String get fullName => CulturalNameCatalog.formatFullName(
        countryCode,
        firstName,
        lastName,
      );

  SchoolNpc copyWith({
    int? relationshipPercent,
    NpcFinance? finance,
    bool? bestFriend,
    bool? bestFriendAsked,
  }) =>
      SchoolNpc(
        id: id,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        birthYear: birthYear,
        role: role,
        countryCode: countryCode,
        relationshipPercent: relationshipPercent ?? this.relationshipPercent,
        finance: finance ?? this.finance,
        bestFriend: bestFriend ?? this.bestFriend,
        bestFriendAsked: bestFriendAsked ?? this.bestFriendAsked,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender.name,
        'birthYear': birthYear,
        'role': role.name,
        'countryCode': countryCode,
        'relationshipPercent': relationshipPercent,
        if (finance != null) 'finance': finance!.toJson(),
        if (bestFriend) 'bestFriend': true,
        if (bestFriendAsked) 'bestFriendAsked': true,
      };

  static SchoolNpc? fromJson(Object? json) {
    if (json is! Map) return null;

    final id = json['id'];
    final first = json['firstName'];
    final last = json['lastName'];
    final birthYear = json['birthYear'];

    if (id is! String || first is! String || last is! String) return null;
    if (birthYear is! int) return null;

    final gender = Gender.values.firstWhere(
      (value) => value.name == json['gender'],
      orElse: () => Gender.male,
    );
    final role = SchoolRole.values.firstWhere(
      (value) => value.name == json['role'],
      orElse: () => SchoolRole.classmate,
    );
    final country = json['countryCode'];
    final score = json['relationshipPercent'];

    return SchoolNpc(
      id: id,
      firstName: first,
      lastName: last,
      gender: gender,
      birthYear: birthYear,
      role: role,
      countryCode: country is String ? country : 'ID',
      relationshipPercent: score is int ? score.clamp(-100, 100).toInt() : 40,
      finance: NpcFinance.fromJson(json['finance']),
      bestFriend: json['bestFriend'] == true,
      bestFriendAsked: json['bestFriendAsked'] == true,
    );
  }
}
