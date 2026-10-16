import 'dart:math';

import 'gender.dart';

/// Country-aware name and appearance pools used by Character Randomize.
///
/// Appearance weights are gameplay estimates, not official demographic
/// statistics. They preserve individual variation and allow exceptions.
abstract final class CulturalRandomizerCatalog {
static const Map<String, String> _nameRegionByCountry = {
'AE': 'arab',
'AR': 'latin',
'AT': 'germanic',
'AU': 'english',
'BE': 'western_european',
'BR': 'latin',
'CA': 'english',
'CH': 'germanic',
'CL': 'latin',
'CN': 'chinese',
'CO': 'latin',
'CU': 'latin',
'DE': 'germanic',
'DK': 'nordic',
'EG': 'arab',
'ES': 'iberian',
'ET': 'east_african',
'FJ': 'pacific',
'FR': 'french',
'GB': 'english',
'GH': 'west_african',
'GR': 'greek',
'ID': 'indonesian',
'IE': 'irish',
'IN': 'south_asian',
'IT': 'italian',
'JP': 'japanese',
'KE': 'east_african',
'KR': 'korean',
'MA': 'arab',
'MC': 'french',
'MX': 'latin',
'MY': 'malay',
'NG': 'west_african',
'NL': 'dutch',
'NP': 'south_asian',
'NO': 'nordic',
'NZ': 'english',
'PK': 'south_asian',
'PL': 'slavic',
'PT': 'iberian',
'RU': 'slavic',
'SA': 'arab',
'SE': 'nordic',
'SG': 'singaporean',
'TH': 'thai',
'TR': 'turkish',
'UA': 'slavic',
'US': 'english',
'VN': 'vietnamese',
'ZA': 'south_african',
'TZ': 'east_african',
'PE': 'latin',
'PH': 'filipino',
};

static const Map<String, _NamePool> _namePools = {
'arab': _NamePool(
male: ['Omar', 'Ahmed', 'Khalid', 'Youssef', 'Amir', 'Hassan'],
female: ['Aisha', 'Layla', 'Noor', 'Mariam', 'Amira', 'Salma'],
family: ['Hassan', 'Khalil', 'Mansour', 'Nasser', 'Rahman', 'Saleh'],
),
'latin': _NamePool(
male: ['Mateo', 'Diego', 'Lucas', 'Santiago', 'Gabriel', 'Rafael'],
female: ['Camila', 'Valentina', 'Lucia', 'Sofia', 'Isabella', 'Elena'],
family: ['Garcia', 'Rodriguez', 'Martinez', 'Silva', 'Morales', 'Rojas'],
),
'germanic': _NamePool(
male: ['Lukas', 'Leon', 'Felix', 'Paul', 'Jonas', 'Maximilian'],
female: ['Lena', 'Mia', 'Clara', 'Anna', 'Leonie', 'Emma'],
family: ['Muller', 'Schneider', 'Weber', 'Fischer', 'Meyer', 'Huber'],
),
'english': _NamePool(
male: ['Oliver', 'Jack', 'Noah', 'Henry', 'Ethan', 'James'],
female: ['Olivia', 'Amelia', 'Charlotte', 'Grace', 'Emily', 'Sophie'],
family: ['Smith', 'Taylor', 'Brown', 'Wilson', 'Martin', 'Clark'],
),
'western_european': _NamePool(
male: ['Louis', 'Arthur', 'Leon', 'Gabriel', 'Adam', 'Noah'],
female: ['Louise', 'Alice', 'Emma', 'Juliette', 'Lea', 'Elise'],
family: ['Dubois', 'Lambert', 'Janssens', 'Peeters', 'Moreau', 'Simon'],
),
'nordic': _NamePool(
male: ['Lars', 'Erik', 'Oscar', 'Magnus', 'Nils', 'Anders'],
female: ['Astrid', 'Freja', 'Ingrid', 'Linnea', 'Maja', 'Elsa'],
family: ['Hansen', 'Johansson', 'Andersen', 'Lindberg', 'Berg', 'Dahl'],
),
'chinese': _NamePool(
male: ['Wei', 'Jun', 'Hao', 'Ming', 'Jian', 'Lei'],
female: ['Mei', 'Xinyi', 'Jing', 'Yan', 'Lina', 'Yuting'],
family: ['Wang', 'Li', 'Zhang', 'Liu', 'Chen', 'Yang'],
),
'japanese': _NamePool(
male: ['Haruto', 'Ren', 'Yuto', 'Sota', 'Kaito', 'Haruki'],
female: ['Yui', 'Sakura', 'Hina', 'Aoi', 'Akari', 'Mei'],
family: ['Sato', 'Suzuki', 'Takahashi', 'Tanaka', 'Watanabe', 'Ito'],
),
'korean': _NamePool(
male: ['Min-jun', 'Seo-jun', 'Do-yun', 'Ji-ho', 'Ha-jun', 'Ji-hun'],
female: ['Seo-yeon', 'Ji-woo', 'Ha-eun', 'Min-seo', 'Su-bin', 'Ye-eun'],
family: ['Kim', 'Lee', 'Park', 'Choi', 'Jung', 'Kang'],
),
'south_asian': _NamePool(
male: ['Arjun', 'Rohan', 'Aarav', 'Rahul', 'Aditya', 'Kiran'],
female: ['Ananya', 'Priya', 'Aanya', 'Kavya', 'Sana', 'Diya'],
family: ['Sharma', 'Patel', 'Singh', 'Khan', 'Joshi', 'Thapa'],
),
'east_african': _NamePool(
male: ['Amani', 'Baraka', 'Jabari', 'Kamau', 'Mwangi', 'Dawit'],
female: ['Asha', 'Neema', 'Zuri', 'Wanjiku', 'Nia', 'Hana'],
family: ['Otieno', 'Njoroge', 'Tesfaye', 'Mushi', 'Kiptoo', 'Abebe'],
),
'west_african': _NamePool(
male: ['Kwame', 'Kofi', 'Chidi', 'Emeka', 'Tunde', 'Ade'],
female: ['Ama', 'Akosua', 'Chioma', 'Adaeze', 'Abena', 'Folami'],
family: ['Mensah', 'Okafor', 'Adeyemi', 'Boateng', 'Okonkwo', 'Bello'],
),
'pacific': _NamePool(
male: ['Jone', 'Laisiasa', 'Manoa', 'Samu', 'Taito', 'Eroni'],
female: ['Adi', 'Mere', 'Litia', 'Salote', 'Ana', 'Luisa'],
family: ['Vula', 'Naisoro', 'Rokotuibau', 'Tawake', 'Kumar', 'Singh'],
),
'french': _NamePool(
male: ['Gabriel', 'Louis', 'Jules', 'Arthur', 'Raphael', 'Hugo'],
female: ['Jade', 'Louise', 'Ambre', 'Alice', 'Chloe', 'Manon'],
family: ['Martin', 'Bernard', 'Dubois', 'Thomas', 'Robert', 'Richard'],
),
'greek': _NamePool(
male: ['Nikos', 'Giorgos', 'Dimitris', 'Yannis', 'Andreas', 'Kostas'],
female: ['Eleni', 'Maria', 'Katerina', 'Sofia', 'Dimitra', 'Irene'],
family: ['Papadopoulos', 'Papadakis', 'Nikolaidis', 'Georgiou', 'Pappas', 'Dimitriou'],
),
'indonesian': _NamePool(
male: ['Rizky', 'Aditya', 'Dimas', 'Fajar', 'Arif', 'Bima'],
female: ['Putri', 'Ayu', 'Siti', 'Dewi', 'Intan', 'Nadia'],
family: ['Wijaya', 'Saputra', 'Pratama', 'Santoso', 'Hidayat', 'Kurniawan'],
),
'irish': _NamePool(
male: ['Sean', 'Conor', 'Cian', 'Liam', 'Finn', 'Oisin'],
female: ['Aoife', 'Niamh', 'Saoirse', 'Ciara', 'Orla', 'Maeve'],
family: ['Murphy', 'Kelly', 'Byrne', 'Ryan', 'Walsh', 'Doyle'],
),
'italian': _NamePool(
male: ['Leonardo', 'Francesco', 'Lorenzo', 'Alessandro', 'Matteo', 'Luca'],
female: ['Giulia', 'Sofia', 'Aurora', 'Giorgia', 'Chiara', 'Francesca'],
family: ['Rossi', 'Russo', 'Ferrari', 'Esposito', 'Romano', 'Ricci'],
),
'malay': _NamePool(
male: ['Aiman', 'Hakim', 'Amir', 'Farhan', 'Irfan', 'Danish'],
female: ['Aisyah', 'Nur', 'Siti', 'Alya', 'Amira', 'Hana'],
family: ['Abdullah', 'Ismail', 'Rahman', 'Hassan', 'Ibrahim', 'Yusof'],
),
'dutch': _NamePool(
male: ['Daan', 'Sem', 'Milan', 'Lucas', 'Finn', 'Lars'],
female: ['Emma', 'Sophie', 'Julia', 'Tess', 'Mila', 'Sanne'],
family: ['de Jong', 'Jansen', 'de Vries', 'van den Berg', 'Bakker', 'Visser'],
),
'slavic': _NamePool(
male: ['Aleksandr', 'Maksim', 'Danylo', 'Ivan', 'Nikolai', 'Marek'],
female: ['Anastasia', 'Olena', 'Sofia', 'Katarzyna', 'Anna', 'Mila'],
family: ['Ivanov', 'Kowalski', 'Shevchenko', 'Petrov', 'Novak', 'Kravchenko'],
),
'iberian': _NamePool(
male: ['Hugo', 'Mateo', 'Martin', 'Tiago', 'Diego', 'Alejandro'],
female: ['Ines', 'Carmen', 'Lucia', 'Mariana', 'Beatriz', 'Alba'],
family: ['Garcia', 'Silva', 'Fernandez', 'Santos', 'Costa', 'Lopez'],
),
'singaporean': _NamePool(
male: ['Wei Ming', 'Jun Jie', 'Hafiz', 'Arjun', 'Daniel', 'Ryan'],
female: ['Jia Yi', 'Xin Yi', 'Nurul', 'Priya', 'Chloe', 'Alicia'],
family: ['Tan', 'Lim', 'Lee', 'Ng', 'Wong', 'Kaur'],
),
'thai': _NamePool(
male: ['Narin', 'Krit', 'Anan', 'Thanawat', 'Phurin', 'Somchai'],
female: ['Araya', 'Kanya', 'Mali', 'Nicha', 'Siriporn', 'Pim'],
family: ['Saetang', 'Srisai', 'Sukhum', 'Chaiyaporn', 'Wong', 'Kittisak'],
),
'turkish': _NamePool(
male: ['Emir', 'Yusuf', 'Kerem', 'Mehmet', 'Arda', 'Can'],
female: ['Zeynep', 'Elif', 'Defne', 'Ece', 'Merve', 'Aylin'],
family: ['Yilmaz', 'Kaya', 'Demir', 'Sahin', 'Celik', 'Aydin'],
),
'vietnamese': _NamePool(
male: ['Minh', 'Quang', 'Huy', 'Duc', 'Tuan', 'Khoa'],
female: ['Linh', 'Anh', 'Thao', 'Trang', 'Ngoc', 'Mai'],
family: ['Nguyen', 'Tran', 'Le', 'Pham', 'Hoang', 'Phan'],
),
'filipino': _NamePool(
male: ['Miguel', 'Gabriel', 'Jose', 'Andres', 'Rafael', 'Juan'],
female: ['Maria', 'Angel', 'Sofia', 'Isabella', 'Andrea', 'Gabriela'],
family: ['Santos', 'Reyes', 'Cruz', 'Bautista', 'Garcia', 'Mendoza'],
),
'south_african': _NamePool(
male: ['Thabo', 'Sipho', 'Liam', 'Lethabo', 'Nkosi', 'Musa'],
female: ['Naledi', 'Amahle', 'Thandiwe', 'Lerato', 'Zanele', 'Amara'],
family: ['Nkosi', 'Dlamini', 'Mokoena', 'Naidoo', 'Botha', 'Mthembu'],
),
};

static const Map<String, String> _appearanceRegionByCountry = {
'AE': 'west_asian',
'AR': 'latin_america',
'AT': 'europe',
'AU': 'mixed',
'BE': 'europe',
'BR': 'latin_america',
'CA': 'mixed',
'CH': 'europe',
'CL': 'latin_america',
'CN': 'east_asian',
'CO': 'latin_america',
'CU': 'latin_america',
'DE': 'europe',
'DK': 'northern_europe',
'EG': 'north_african',
'ES': 'southern_europe',
'ET': 'east_african',
'FJ': 'pacific',
'FR': 'western_europe',
'GB': 'mixed',
'GH': 'west_african',
'GR': 'southern_europe',
'ID': 'southeast_asian',
'IE': 'northern_europe',
'IN': 'south_asian',
'IT': 'southern_europe',
'JP': 'east_asian',
'KE': 'east_african',
'KR': 'east_asian',
'MA': 'north_african',
'MC': 'western_europe',
'MX': 'latin_america',
'MY': 'southeast_asian',
'NG': 'west_african',
'NL': 'western_europe',
'NP': 'south_asian',
'NO': 'northern_europe',
'NZ': 'mixed',
'PK': 'south_asian',
'PL': 'eastern_europe',
'PT': 'southern_europe',
'RU': 'eastern_europe',
'SA': 'west_asian',
'SE': 'northern_europe',
'SG': 'southeast_asian',
'TH': 'southeast_asian',
'TR': 'west_asian',
'UA': 'eastern_europe',
'US': 'mixed',
'VN': 'southeast_asian',
'ZA': 'southern_africa',
'TZ': 'east_african',
'PE': 'latin_america',
'PH': 'southeast_asian',
};

static const Map<String, _AppearancePool> _appearancePools = {
'east_asian': _AppearancePool(
skin: ['light', 'light', 'light_medium', 'light_medium', 'medium', 'very_light', 'medium_tan'],
hair: ['black', 'black', 'blue_black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown'],
eyes: ['dark_brown', 'dark_brown', 'brown', 'black', 'black', 'chocolate', 'hazel'],
),
'southeast_asian': _AppearancePool(
skin: ['light_medium', 'medium', 'medium', 'medium_tan', 'tan', 'light', 'deep_tan', 'brown'],
hair: ['black', 'black', 'blue_black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown'],
eyes: ['dark_brown', 'dark_brown', 'brown', 'black', 'black', 'chocolate', 'amber'],
),
'south_asian': _AppearancePool(
skin: ['light_medium', 'medium', 'medium_tan', 'medium_tan', 'tan', 'deep_tan', 'brown', 'light'],
hair: ['black', 'black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'blue_black', 'chestnut_brown'],
eyes: ['dark_brown', 'dark_brown', 'brown', 'brown', 'black', 'chocolate', 'hazel', 'amber'],
),
'west_asian': _AppearancePool(
skin: ['light', 'light_medium', 'medium', 'medium', 'medium_tan', 'tan', 'very_light', 'deep_tan'],
hair: ['black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'auburn', 'blue_black'],
eyes: ['brown', 'dark_brown', 'dark_brown', 'hazel', 'amber', 'green', 'black'],
),
'north_african': _AppearancePool(
skin: ['light_medium', 'medium', 'medium_tan', 'tan', 'deep_tan', 'light', 'brown'],
hair: ['black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'auburn'],
eyes: ['brown', 'dark_brown', 'dark_brown', 'hazel', 'amber', 'black', 'green'],
),
'east_african': _AppearancePool(
skin: ['brown', 'deep_brown', 'deep_brown', 'dark', 'dark', 'very_dark', 'deep_tan', 'tan'],
hair: ['black', 'black', 'blue_black', 'dark_brown', 'chocolate_brown'],
eyes: ['dark_brown', 'dark_brown', 'brown', 'black', 'chocolate'],
),
'west_african': _AppearancePool(
skin: ['deep_brown', 'deep_brown', 'dark', 'dark', 'very_dark', 'very_dark', 'brown', 'tan'],
hair: ['black', 'black', 'blue_black', 'dark_brown', 'chocolate_brown'],
eyes: ['dark_brown', 'dark_brown', 'black', 'black', 'brown', 'chocolate'],
),
'southern_africa': _AppearancePool(
skin: ['deep_brown', 'dark', 'brown', 'medium_tan', 'tan', 'light_medium', 'light', 'very_dark'],
hair: ['black', 'black', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'ash_brown'],
eyes: ['dark_brown', 'brown', 'black', 'hazel', 'amber', 'green'],
),
'latin_america': _AppearancePool(
skin: ['light', 'light_medium', 'medium', 'medium', 'medium_tan', 'tan', 'brown', 'deep_tan', 'pale'],
hair: ['black', 'dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'warm_brown', 'auburn'],
eyes: ['brown', 'dark_brown', 'dark_brown', 'hazel', 'amber', 'black', 'green', 'blue_green'],
),
'southern_europe': _AppearancePool(
skin: ['pale', 'very_light', 'light', 'light_medium', 'medium', 'medium', 'tan'],
hair: ['dark_brown', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'black', 'auburn', 'warm_brown'],
eyes: ['brown', 'dark_brown', 'hazel', 'green', 'blue_green', 'gray', 'light_blue'],
),
'western_europe': _AppearancePool(
skin: ['pale', 'pale', 'very_light', 'very_light', 'light', 'light_medium', 'medium'],
hair: ['dark_brown', 'chestnut_brown', 'ash_brown', 'honey_blonde', 'golden_blonde', 'ginger', 'black'],
eyes: ['deep_blue', 'light_blue', 'gray', 'green', 'hazel', 'brown', 'blue_green'],
),
'northern_europe': _AppearancePool(
skin: ['pale', 'pale', 'very_light', 'very_light', 'light', 'light_medium'],
hair: ['honey_blonde', 'golden_blonde', 'ash_blonde', 'platinum_blonde', 'chestnut_brown', 'ash_brown', 'dark_brown'],
eyes: ['light_blue', 'deep_blue', 'gray', 'green', 'blue_green', 'hazel', 'brown'],
),
'eastern_europe': _AppearancePool(
skin: ['pale', 'very_light', 'very_light', 'light', 'light_medium', 'medium'],
hair: ['dark_brown', 'ash_brown', 'chestnut_brown', 'honey_blonde', 'ash_blonde', 'black', 'golden_blonde'],
eyes: ['gray', 'light_blue', 'deep_blue', 'green', 'hazel', 'brown', 'dark_brown'],
),
'europe': _AppearancePool(
skin: ['pale', 'very_light', 'light', 'light_medium', 'medium'],
hair: ['dark_brown', 'chestnut_brown', 'ash_brown', 'honey_blonde', 'black', 'auburn'],
eyes: ['brown', 'hazel', 'green', 'gray', 'light_blue', 'deep_blue'],
),
'pacific': _AppearancePool(
skin: ['medium', 'medium_tan', 'tan', 'deep_tan', 'brown', 'light_medium'],
hair: ['black', 'blue_black', 'dark_brown', 'chocolate_brown'],
eyes: ['dark_brown', 'brown', 'black', 'hazel'],
),
'mixed': _AppearancePool(
skin: ['pale', 'very_light', 'light', 'light_medium', 'medium', 'medium_tan', 'tan', 'deep_tan', 'brown', 'deep_brown', 'dark'],
hair: ['black', 'dark_brown', 'chocolate_brown', 'chestnut_brown', 'ash_brown', 'honey_blonde', 'auburn', 'ginger'],
eyes: ['dark_brown', 'brown', 'hazel', 'green', 'gray', 'light_blue', 'deep_blue', 'blue_green'],
),
};

/// Returns a culturally informed given-name candidate.
static String randomFirstName({
required String countryCode,
required Gender gender,
required Random random,
}) {
final pool = _namePoolFor(countryCode);
final names = gender == Gender.female ? pool.female : pool.male;
return names[random.nextInt(names.length)];
}

/// Returns a culturally informed family-name candidate.
static String randomLastName({
required String countryCode,
required Random random,
}) {
final names = _namePoolFor(countryCode).family;
return names[random.nextInt(names.length)];
}

/// Picks a palette ID using the selected country's weighted profile.
///
/// [availableIds] must come from the existing palette service. If a
/// profile ever references an unavailable ID, it is filtered out.
/// If filtering leaves no candidates, all available palette IDs are used.
static String randomAppearanceColor({
required String countryCode,
required AppearanceFeature feature,
required Iterable<String> availableIds,
required Random random,
}) {
final available = availableIds.toSet().toList(growable: false);
if (available.isEmpty) {
throw ArgumentError.value(
availableIds,
'availableIds',
'Palette must contain at least one color ID.',
);
}

final region = _appearanceRegionByCountry[
      countryCode.trim().toUpperCase()
    ] ??
    'mixed';

final profile = _appearancePools[region] ?? _appearancePools['mixed']!;
final List<String> weightedIds;

switch (feature) {
  case AppearanceFeature.skin:
    weightedIds = profile.skin;
  case AppearanceFeature.hair:
    weightedIds = profile.hair;
  case AppearanceFeature.eyes:
    weightedIds = profile.eyes;
}

final candidates = weightedIds
    .where(available.contains)
    .toList(growable: false);

final pool = candidates.isEmpty ? available : candidates;
return pool[random.nextInt(pool.length)];

}

/// Exposed for tests to ensure the catalog covers every supported country.
static bool supportsCountry(String countryCode) {
final code = countryCode.trim().toUpperCase();
return _nameRegionByCountry.containsKey(code) &&
_appearanceRegionByCountry.containsKey(code);
}

static _NamePool _namePoolFor(String countryCode) {
final code = countryCode.trim().toUpperCase();
final region = _nameRegionByCountry[code] ?? 'english';
return _namePools[region] ?? _namePools['english']!;
}
}

enum AppearanceFeature {
skin,
hair,
eyes,
}

class _NamePool {
const _NamePool({
required this.male,
required this.female,
required this.family,
});

final List<String> male;
final List<String> female;
final List<String> family;
}

class _AppearancePool {
const _AppearancePool({
required this.skin,
required this.hair,
required this.eyes,
});

final List<String> skin;
final List<String> hair;
final List<String> eyes;
}
