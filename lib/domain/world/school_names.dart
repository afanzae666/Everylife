import 'dart:math' as math;

import '../career/education_state.dart';

class _Style {
  const _Style(
    this.elementary,
    this.middle,
    this.high,
    this.university,
    this.names,
  );

  /// Templates: {x} a local name, {c} the city, {n} a school number.
  final String elementary;
  final String middle;
  final String high;
  final String university;
  final List<String> names;
}

/// School names that sound like the player's country.
abstract final class SchoolNames {
  static const _english = _Style(
    '{x} Elementary School',
    '{x} Middle School',
    '{x} High School',
    '{x} University',
    ['Oakridge', 'Maple Hill', 'Riverside', 'Sunrise', 'Greenfield', 'Lakeside', 'Cedar Grove', 'Willow Creek'],
  );
  static const _british = _Style(
    '{x} Primary School',
    '{x} Secondary School',
    '{x} Sixth Form College',
    'University of {c}',
    ['Oakridge', 'Kingsmead', 'Hillcrest', 'Abbey Road', 'Ashford', 'Westbourne', 'Thornbury', 'Eastfield'],
  );
  static const _german = _Style(
    'Grundschule {x}',
    'Realschule {x}',
    '{x}-Gymnasium',
    'Universität {c}',
    ['Goethe', 'Humboldt', 'Schiller', 'Kant', 'Lessing', 'Bach', 'Mozart', 'Gutenberg'],
  );
  static const _french = _Style(
    'École primaire {x}',
    'Collège {x}',
    'Lycée {x}',
    'Université de {c}',
    ['Victor Hugo', 'Jean Moulin', 'Pasteur', 'Molière', 'Voltaire', 'Jules Ferry', 'Marie Curie', 'Descartes'],
  );
  static const _spanish = _Style(
    'Escuela Primaria {x}',
    'Escuela Secundaria {x}',
    'Instituto {x}',
    'Universidad de {c}',
    ['Cervantes', 'Simón Bolívar', 'Benito Juárez', 'San Martín', 'Miguel Hidalgo', 'Gabriela Mistral', 'José Martí', 'Bolívar'],
  );
  static const _portuguese = _Style(
    'Escola Básica {x}',
    'Escola Preparatória {x}',
    'Escola Secundária {x}',
    'Universidade de {c}',
    ['Camões', 'Fernando Pessoa', 'Santos Dumont', 'Machado de Assis', 'Eça de Queirós', 'Dom Pedro', 'Tiradentes', 'Cecília Meireles'],
  );
  static const _italian = _Style(
    'Scuola Primaria {x}',
    'Scuola Media {x}',
    'Liceo {x}',
    'Università di {c}',
    ['Dante Alighieri', 'Galileo Galilei', 'Leonardo da Vinci', 'Giuseppe Verdi', 'Marco Polo', 'Maria Montessori', 'Garibaldi', 'Manzoni'],
  );
  static const _dutch = _Style(
    'Basisschool {x}',
    'Middelbare School {x}',
    '{x} Lyceum',
    'Universiteit van {c}',
    ['De Regenboog', 'Het Kompas', 'De Zonnebloem', 'Erasmus', 'Rembrandt', 'Vondel', 'Spinoza', 'Johan Cruyff'],
  );
  static const _nordic = _Style(
    '{x} Skole',
    '{x} Ungdomsskole',
    '{x} Gymnasium',
    'Universitetet i {c}',
    ['Solbakken', 'Fjordvik', 'Nordstrand', 'Lindeberg', 'Björkhaga', 'Skogås', 'Havnelund', 'Ekeby'],
  );
  static const _polish = _Style(
    'Szkoła Podstawowa nr {n} im. {x}',
    'Gimnazjum nr {n} im. {x}',
    'Liceum Ogólnokształcące nr {n} im. {x}',
    'Uniwersytet w {c}',
    ['Mikołaja Kopernika', 'Adama Mickiewicza', 'Marii Skłodowskiej-Curie', 'Fryderyka Chopina', 'Jana Pawła II', 'Tadeusza Kościuszki'],
  );
  static const _slavic = _Style(
    'Primary School No. {n}',
    'Secondary School No. {n}',
    'Lyceum No. {n}',
    '{c} State University',
    ['Pushkin', 'Tolstoy', 'Lomonosov', 'Gagarin', 'Shevchenko', 'Mendeleev'],
  );
  static const _turkish = _Style(
    '{x} İlkokulu',
    '{x} Ortaokulu',
    '{x} Anadolu Lisesi',
    '{c} Üniversitesi',
    ['Atatürk', 'Cumhuriyet', 'Yıldız', 'Fatih', 'Mehmet Akif', 'Barbaros', 'Gazi', 'Zafer'],
  );
  static const _greek = _Style(
    '{n}th Primary School of {c}',
    '{n}th Junior High School of {c}',
    '{n}th Lyceum of {c}',
    'University of {c}',
    ['Athena'],
  );
  static const _japanese = _Style(
    '{x} Elementary School',
    '{x} Junior High School',
    '{x} High School',
    '{x} University',
    ['Sakura', 'Asahi', 'Midori', 'Hikari', 'Fuji', 'Aoba', 'Himawari', 'Kaede'],
  );
  static const _korean = _Style(
    '{x} Elementary School',
    '{x} Middle School',
    '{x} High School',
    '{x} University',
    ['Hanbit', 'Sejong', 'Dongmun', 'Haneul', 'Mugunghwa', 'Seorak', 'Hangang', 'Namsan'],
  );
  static const _chinese = _Style(
    '{c} No. {n} Primary School',
    '{c} No. {n} Middle School',
    '{c} No. {n} High School',
    '{c} University',
    ['Hua'],
  );
  static const _vietnamese = _Style(
    '{x} Primary School',
    '{x} Secondary School',
    '{x} High School',
    '{x} University',
    ['Nguyen Du', 'Le Quy Don', 'Tran Phu', 'Nguyen Trai', 'Chu Van An', 'Ly Thuong Kiet'],
  );
  static const _thai = _Style(
    'Wat {x} School',
    '{x} Wittayalai School',
    '{x} Wittayakom School',
    '{x} University',
    ['Suan Dusit', 'Benchama', 'Triam', 'Saraburi', 'Thepsirin', 'Suthiwat'],
  );
  static const _malay = _Style(
    'SK {x}',
    'SMK {x}',
    'SMK {x} Tinggi',
    'Universiti {x}',
    ['Seri Perdana', 'Taman Maju', 'Bukit Indah', 'Seri Utama', 'Taman Desa', 'Putra Jaya'],
  );
  static const _singapore = _Style(
    '{x} Primary School',
    '{x} Secondary School',
    '{x} Junior College',
    'National University of {c}',
    ['Raffles', 'Bukit Timah', 'Tanjong Katong', 'Queenstown', 'Pasir Ris', 'Clementi'],
  );
  static const _filipino = _Style(
    '{x} Elementary School',
    '{x} Junior High School',
    '{x} Senior High School',
    'University of {c}',
    ['Rizal', 'Bonifacio', 'Mabini', 'Quezon', 'Aguinaldo', 'Luna'],
  );
  static const _indonesian = _Style(
    'SD Negeri {n} {x}',
    'SMP Negeri {n} {x}',
    'SMA Negeri {n} {x}',
    'Universitas {x}',
    ['Menteng', 'Cendana', 'Nusantara', 'Garuda', 'Pancasila', 'Bhakti', 'Cempaka', 'Harapan'],
  );
  static const _indian = _Style(
    '{x} Primary School',
    '{x} Public School',
    '{x} Senior Secondary School',
    'University of {c}',
    ['Saraswati', 'Kendriya', 'Delhi', 'Vidya Mandir', 'Gandhi Memorial', 'Tagore'],
  );
  static const _southAsian = _Style(
    '{x} Primary School',
    '{x} Middle School',
    '{x} High School',
    '{c} University',
    ['Iqbal', 'Jinnah', 'Himalaya', 'Mount Everest', 'Sagarmatha', 'Lumbini'],
  );
  static const _arabic = _Style(
    'Al-{x} Primary School',
    'Al-{x} Intermediate School',
    'Al-{x} Secondary School',
    '{c} University',
    ['Noor', 'Amal', 'Salam', 'Huda', 'Falah', 'Najah', 'Rashid', 'Andalus'],
  );
  static const _african = _Style(
    'St. {x} Primary School',
    '{x} Junior Secondary School',
    '{x} Senior Secondary School',
    'University of {c}',
    ['Mary\'s', 'Joseph\'s', 'Peter\'s', 'Unity', 'Freedom', 'Heritage', 'Hope', 'Nelson Mandela'],
  );

  static const Map<String, _Style> _byCountry = {
    'US': _english, 'CA': _english, 'AU': _british, 'NZ': _british,
    'GB': _british, 'IE': _british, 'FJ': _british,
    'DE': _german, 'AT': _german, 'CH': _german,
    'FR': _french, 'MC': _french, 'BE': _french,
    'ES': _spanish, 'MX': _spanish, 'AR': _spanish, 'CL': _spanish,
    'CO': _spanish, 'PE': _spanish, 'CU': _spanish,
    'PT': _portuguese, 'BR': _portuguese,
    'IT': _italian, 'NL': _dutch,
    'DK': _nordic, 'NO': _nordic, 'SE': _nordic,
    'PL': _polish, 'RU': _slavic, 'UA': _slavic,
    'TR': _turkish, 'GR': _greek,
    'JP': _japanese, 'KR': _korean, 'CN': _chinese, 'VN': _vietnamese,
    'TH': _thai, 'MY': _malay, 'SG': _singapore, 'PH': _filipino,
    'ID': _indonesian, 'IN': _indian, 'PK': _southAsian, 'NP': _southAsian,
    'SA': _arabic, 'AE': _arabic, 'EG': _arabic, 'MA': _arabic,
    'NG': _african, 'GH': _african, 'KE': _african, 'TZ': _african,
    'ET': _african, 'ZA': _african,
  };

  /// A school name for [stage] in [countryCode], using [cityName] where the
  /// local style puts the city in the name.
  static String generate({
    required String countryCode,
    required SchoolStage stage,
    required String cityName,
    required math.Random random,
  }) {
    final style = _byCountry[countryCode.toUpperCase()] ?? _english;
    final template = switch (stage) {
      SchoolStage.elementary => style.elementary,
      SchoolStage.middle => style.middle,
      SchoolStage.high => style.high,
      SchoolStage.university => style.university,
      SchoolStage.none => style.high,
    };

    return template
        .replaceAll('{x}', style.names[random.nextInt(style.names.length)])
        .replaceAll('{c}', cityName)
        .replaceAll('{n}', '${1 + random.nextInt(30)}');
  }
}
