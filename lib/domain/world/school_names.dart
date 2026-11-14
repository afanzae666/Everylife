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
  final List<String> elementary;
  final List<String> middle;
  final List<String> high;
  final List<String> university;
  final List<String> names;
}

/// School names that sound like the player's country.
abstract final class SchoolNames {
    static const _english = _Style(
    ['{x} Elementary School', '{x} Elementary', '{x} Elementary Academy'],
    ['{x} Middle School', '{x} Junior High', '{x} Middle Academy', '{x} Intermediate School'],
    ['{x} High School', '{x} Senior High School', '{x} Preparatory High School', '{x} Heights High School'],
    ['{x} University', '{c} State University', '{x} Institute of Technology', '{x} State College', 'University of {c}'],
    ['Oakridge', 'Maple Hill', 'Riverside', 'Sunrise', 'Greenfield', 'Lakeside', 'Cedar Grove', 'Willow Creek', 'Brookside', 'Hawthorne', 'Pinecrest', 'Sunnydale', 'Fairview', 'Stonebridge', 'Meadowbrook', 'Ridgewood', 'Silver Lake', 'Birchwood', 'Harbor View', 'Evergreen', 'Lincoln', 'Jefferson', 'Roosevelt', 'Franklin'],
  );
    static const _british = _Style(
    ['{x} Primary School', '{x} Junior School', '{x} Primary Academy', 'St {x} Primary School'],
    ['{x} Secondary School', '{x} High School', '{x} Academy', 'St {x} Secondary School'],
    ['{x} Sixth Form College', '{x} Sixth Form', '{x} College', '{x} Grammar School'],
    ['University of {c}', '{c} Metropolitan University', '{c} Institute of Technology'],
    ['Oakridge', 'Kingsmead', 'Hillcrest', 'Abbey Road', 'Ashford', 'Westbourne', 'Thornbury', 'Eastfield', 'Millfield', 'Stratford', 'Brookfield', 'Redwood', 'Chesterton', 'Langley', 'Holloway', 'Pembroke', 'Northgate', 'Fairfax', 'Grange Hill', 'Wycombe', 'Marlow', 'Windermere', 'Hartwell', 'Kingsley'],
  );
    static const _german = _Style(
    ['Grundschule {x}', '{x}-Grundschule', 'Grundschule am {x}-Platz'],
    ['Realschule {x}', '{x}-Realschule', 'Gesamtschule {x}'],
    ['{x}-Gymnasium', 'Gymnasium {x}', '{x}-Oberschule'],
    ['Universität {c}', 'Technische Universität {c}', '{x}-Universität {c}'],
    ['Goethe', 'Humboldt', 'Schiller', 'Kant', 'Lessing', 'Bach', 'Mozart', 'Gutenberg', 'Einstein', 'Beethoven', 'Heine', 'Brecht', 'Humperdinck', 'Mann', 'Hesse', 'Grimm', 'Leibniz', 'Kepler', 'Bonhoeffer', 'Fontane'],
  );
    static const _french = _Style(
    ['École primaire {x}', 'École élémentaire {x}', 'École publique {x}'],
    ['Collège {x}', 'Collège public {x}', 'Collège Saint-{x}'],
    ['Lycée {x}', 'Lycée général {x}', 'Lycée polyvalent {x}'],
    ['Université de {c}', 'Université {c} Sorbonne', 'Institut universitaire de {c}'],
    ['Victor Hugo', 'Jean Moulin', 'Pasteur', 'Molière', 'Voltaire', 'Jules Ferry', 'Marie Curie', 'Descartes', 'Hugo', 'Pagnol', 'Camus', 'Rousseau', 'Diderot', 'Zola', 'Montaigne', 'Balzac', 'Colette', 'Pierre Curie', 'Saint-Exupéry', 'Georges Brassens'],
  );
    static const _spanish = _Style(
    ['Escuela Primaria {x}', 'Colegio {x}', 'Escuela {x}'],
    ['Escuela Secundaria {x}', 'Colegio Secundario {x}', 'Escuela Media {x}'],
    ['Instituto {x}', 'Bachillerato {x}', 'Colegio Preparatorio {x}'],
    ['Universidad de {c}', 'Universidad Nacional de {c}', 'Instituto Tecnológico de {c}'],
    ['Cervantes', 'Simón Bolívar', 'Benito Juárez', 'San Martín', 'Miguel Hidalgo', 'Gabriela Mistral', 'José Martí', 'Bolívar', 'Rubén Darío', 'Pablo Neruda', 'Frida Kahlo', 'Federico García Lorca', 'Octavio Paz', 'Sor Juana', 'Antonio Machado', 'Simón Rodríguez', 'Andrés Bello', 'Rosalía de Castro'],
  );
    static const _portuguese = _Style(
    ['Escola Básica {x}', 'Colégio {x}', 'Escola Municipal {x}'],
    ['Escola Preparatória {x}', 'Colégio Estadual {x}', 'Escola Municipal {x} II'],
    ['Escola Secundária {x}', 'Colégio {x} Ensino Médio', 'Liceu {x}'],
    ['Universidade de {c}', 'Universidade Federal de {c}', 'Instituto Politécnico de {c}'],
    ['Camões', 'Fernando Pessoa', 'Santos Dumont', 'Machado de Assis', 'Eça de Queirós', 'Dom Pedro', 'Tiradentes', 'Cecília Meireles', 'Clarice Lispector', 'Carlos Drummond', 'Vinicius de Moraes', 'Jorge Amado', 'Padre Vieira', 'Almeida Garrett', 'Cora Coralina', 'Monteiro Lobato'],
  );
    static const _italian = _Style(
    ['Scuola Primaria {x}', 'Scuola Elementare {x}', 'Istituto Comprensivo {x}'],
    ['Scuola Media {x}', 'Scuola Secondaria {x}', 'Istituto {x}'],
    ['Liceo {x}', 'Istituto Tecnico {x}', 'Liceo Scientifico {x}'],
    ['Università di {c}', 'Politecnico di {c}', 'Università degli Studi di {c}'],
    ['Dante Alighieri', 'Galileo Galilei', 'Leonardo da Vinci', 'Giuseppe Verdi', 'Marco Polo', 'Maria Montessori', 'Garibaldi', 'Manzoni', 'Pirandello', 'Rossini', 'Puccini', 'Volta', 'Fermi', 'Collodi', 'Michelangelo', 'Raffaello', 'Pascoli', 'Leopardi'],
  );
    static const _dutch = _Style(
    ['Basisschool {x}', 'Openbare Basisschool {x}', '{x} Basisschool'],
    ['Middelbare School {x}', '{x} College', 'Scholengemeenschap {x}'],
    ['{x} Lyceum', '{x} Gymnasium', 'Het {x} College'],
    ['Universiteit van {c}', 'Technische Universiteit {c}', 'Hogeschool {c}'],
    ['De Regenboog', 'Het Kompas', 'De Zonnebloem', 'Erasmus', 'Rembrandt', 'Vondel', 'Spinoza', 'Johan Cruyff', 'Anne Frank', 'Van Gogh', 'Huygens', 'De Vlinder', 'De Bron', 'De Wereldboom', 'Het Kristal', 'De Meidoorn', 'Hugo de Groot', 'Multatuli'],
  );
    static const _nordic = _Style(
    ['{x} Skole', '{x} Barneskole', '{x} Grundskola'],
    ['{x} Ungdomsskole', '{x} Skole', '{x} Högstadium'],
    ['{x} Gymnasium', '{x} Videregående', '{x} Upper Secondary'],
    ['Universitetet i {c}', '{c} Universitet', 'Handelshögskolan i {c}'],
    ['Solbakken', 'Fjordvik', 'Nordstrand', 'Lindeberg', 'Björkhaga', 'Skogås', 'Havnelund', 'Ekeby', 'Strandvik', 'Granlund', 'Alvdal', 'Midtbyen', 'Lillehammer', 'Sjöberg', 'Kastelli', 'Vikingstad', 'Åsgård', 'Nyborg'],
  );
    static const _polish = _Style(
    ['Szkoła Podstawowa nr {n} im. {x}', 'Szkoła Podstawowa im. {x}', 'Publiczna Szkoła Podstawowa nr {n}'],
    ['Gimnazjum nr {n} im. {x}', 'Szkoła Średnia nr {n} im. {x}'],
    ['Liceum Ogólnokształcące nr {n} im. {x}', 'Technikum nr {n} im. {x}', 'Liceum im. {x}'],
    ['Uniwersytet w {c}', 'Politechnika {c}', 'Akademia {c}'],
    ['Mikołaja Kopernika', 'Adama Mickiewicza', 'Marii Skłodowskiej-Curie', 'Fryderyka Chopina', 'Jana Pawła II', 'Tadeusza Kościuszki', 'Stefana Żeromskiego', 'Bolesława Prusa', 'Henryka Sienkiewicza', 'Juliusza Słowackiego', 'Władysława Reymonta', 'Marii Konopnickiej'],
  );
    static const _slavic = _Style(
    ['Primary School No. {n}', 'School No. {n} named after {x}'],
    ['Secondary School No. {n}', 'Gymnasium No. {n} named after {x}'],
    ['Lyceum No. {n}', 'Lyceum named after {x}', 'Gymnasium No. {n}'],
    ['{c} State University', '{c} Technical University', '{c} National University'],
    ['Pushkin', 'Tolstoy', 'Lomonosov', 'Gagarin', 'Shevchenko', 'Mendeleev', 'Chekhov', 'Dostoevsky', 'Tchaikovsky', 'Lesya Ukrainka', 'Korolev', 'Sakharov', 'Gorky', 'Taras'],
  );
    static const _turkish = _Style(
    ['{x} İlkokulu', '{x} İlköğretim Okulu', '{c} {x} İlkokulu'],
    ['{x} Ortaokulu', '{x} İmam Hatip Ortaokulu', '{c} {x} Ortaokulu'],
    ['{x} Anadolu Lisesi', '{x} Fen Lisesi', '{x} Mesleki ve Teknik Lise'],
    ['{c} Üniversitesi', '{c} Teknik Üniversitesi', '{x} Üniversitesi'],
    ['Atatürk', 'Cumhuriyet', 'Yıldız', 'Fatih', 'Mehmet Akif', 'Barbaros', 'Gazi', 'Zafer', 'Fatih Sultan Mehmet', 'Mimar Sinan', 'Namık Kemal', 'Ziya Gökalp', 'Şehit Er', 'Yunus Emre', 'Mevlana', 'İnönü'],
  );
    static const _greek = _Style(
    ['{n}th Primary School of {c}', '{x} Primary School', 'Model Primary School of {c}'],
    ['{n}th Junior High School of {c}', '{x} Junior High School'],
    ['{n}th Lyceum of {c}', '{x} General Lyceum', 'Experimental Lyceum of {c}'],
    ['University of {c}', 'National Technical University of {c}', '{c} University of Applied Sciences'],
    ['Athena', 'Pericles', 'Socrates', 'Homer', 'Aristotle', 'Plato', 'Archimedes', 'Hippocrates', 'Kazantzakis'],
  );
    static const _japanese = _Style(
    ['{x} Elementary School', '{c} Municipal {x} Elementary School'],
    ['{x} Junior High School', '{c} Municipal {x} Junior High School'],
    ['{x} High School', '{c} Prefectural {x} High School', '{x} Gakuen High School'],
    ['{x} University', '{c} National University', '{x} Institute of Technology'],
    ['Sakura', 'Asahi', 'Midori', 'Hikari', 'Fuji', 'Aoba', 'Himawari', 'Kaede', 'Momiji', 'Wakaba', 'Shirakaba', 'Minami', 'Kita', 'Higashi', 'Nishi', 'Tsubame', 'Ume', 'Take', 'Kiku', 'Tsukushi'],
  );
    static const _korean = _Style(
    ['{x} Elementary School', '{c} {x} Elementary School'],
    ['{x} Middle School', '{c} {x} Middle School'],
    ['{x} High School', '{c} {x} High School', '{x} Foreign Language High School'],
    ['{x} University', '{c} National University', '{x} Institute of Science and Technology'],
    ['Hanbit', 'Sejong', 'Dongmun', 'Haneul', 'Mugunghwa', 'Seorak', 'Hangang', 'Namsan', 'Daehan', 'Gaon', 'Saebyeok', 'Bitgaram', 'Areum', 'Moran', 'Sorak', 'Hanra', 'Chungmu', 'Jeongdong'],
  );
    static const _chinese = _Style(
    ['{c} No. {n} Primary School', '{c} {x} Primary School', '{c} Experimental Primary School'],
    ['{c} No. {n} Middle School', '{c} {x} Middle School', '{c} Foreign Language Middle School'],
    ['{c} No. {n} High School', '{c} {x} High School', '{c} Affiliated High School'],
    ['{c} University', '{c} Normal University', '{c} Institute of Technology'],
    ['Hua', 'Hua', 'Jing', 'Yuying', 'Shide', 'Minzhu', 'Xinhua', 'Zhongshan', 'Qingnian'],
  );
    static const _vietnamese = _Style(
    ['{x} Primary School', '{x} Elementary School', 'Tieu Hoc {x}'],
    ['{x} Secondary School', 'THCS {x}', '{x} Junior High School'],
    ['{x} High School', 'THPT {x}', '{x} Specialized High School'],
    ['{x} University', '{c} University of Technology', '{c} National University'],
    ['Nguyen Du', 'Le Quy Don', 'Tran Phu', 'Nguyen Trai', 'Chu Van An', 'Ly Thuong Kiet', 'Tran Hung Dao', 'Phan Chu Trinh', 'Nguyen Hue', 'Le Loi', 'Hung Vuong', 'Kim Dong', 'Quang Trung', 'Ngo Quyen'],
  );
    static const _thai = _Style(
    ['Wat {x} School', 'Anuban {x} School', '{x} Municipal School'],
    ['{x} Wittayalai School', '{x} Withaya School', '{x} Pittayakhom School'],
    ['{x} Wittayakom School', '{x} Witthayalai', '{x} Wittayakhom School'],
    ['{x} University', '{c} University of Technology', '{x} Rajabhat University'],
    ['Suan Dusit', 'Benchama', 'Triam', 'Saraburi', 'Thepsirin', 'Suthiwat', 'Anuban', 'Suankularb', 'Debsirin', 'Patumwan', 'Mahidol', 'Wat Pho', 'Chulalongkorn', 'Rama'],
  );
    static const _malay = _Style(
    ['SK {x}', 'SJK {x}', 'SK {x} 2'],
    ['SMK {x}', 'SMK {x}', 'SMK Seri {x}'],
    ['SMK {x} Tinggi', 'SMK {x} Utama', 'Kolej {x}'],
    ['Universiti {x}', 'Universiti Teknologi {c}', 'Universiti {c}'],
    ['Seri Perdana', 'Taman Maju', 'Bukit Indah', 'Seri Utama', 'Taman Desa', 'Putra Jaya', 'Seri Mutiara', 'Taman Sentosa', 'Bandar Baru', 'Seri Kenanga', 'Taman Bahagia', 'Bukit Jaya', 'Seri Bayu', 'Taman Tun'],
  );
    static const _singapore = _Style(
    ['{x} Primary School', '{x} Primary', '{x} Pri School'],
    ['{x} Secondary School', '{x} Secondary', '{x} Sec School'],
    ['{x} Junior College', '{x} Junior College', '{x} Institution'],
    ['National University of {c}', '{c} Institute of Technology', '{c} Management University'],
    ['Raffles', 'Bukit Timah', 'Tanjong Katong', 'Queenstown', 'Pasir Ris', 'Clementi', 'Hougang', 'Bedok', 'Jurong', 'Woodlands', 'Tampines', 'Toa Payoh', 'Marsiling', 'Yishun'],
  );
    static const _filipino = _Style(
    ['{x} Elementary School', '{x} Central Elementary School', '{x} Integrated School'],
    ['{x} Junior High School', '{x} National High School (Junior)', '{x} Integrated High School'],
    ['{x} Senior High School', '{x} Science High School', '{x} National High School'],
    ['University of {c}', '{c} State University', 'Polytechnic University of {c}'],
    ['Rizal', 'Bonifacio', 'Mabini', 'Quezon', 'Aguinaldo', 'Luna', 'Del Pilar', 'Jacinto', 'Silang', 'Magsaysay', 'Laurel', 'Osmeña', 'Roxas', 'Burgos'],
  );
    static const _indonesian = _Style(
    ['SD Negeri {n} {x}', 'SD Islam {x}', 'SD Negeri {x} {n}', 'SD Swasta {x}'],
    ['SMP Negeri {n} {x}', 'SMP Islam {x}', 'SMP Negeri {x} {n}', 'SMP Katolik {x}'],
    ['SMA Negeri {n} {x}', 'SMA Islam {x}', 'SMA Negeri {x} {n}', 'SMK Negeri {n} {x}'],
    ['Universitas {x}', 'Universitas Negeri {c}', 'Institut Teknologi {c}', 'Universitas {x} {c}', 'Politeknik {c}'],
    ['Menteng', 'Cendana', 'Nusantara', 'Garuda', 'Pancasila', 'Bhakti', 'Cempaka', 'Harapan', 'Melati', 'Kenanga', 'Mawar', 'Pelita', 'Tunas Bangsa', 'Budi Utomo', 'Kartini', 'Merdeka', 'Satya Wacana', 'Bina Insani', 'Cahaya', 'Permata'],
  );
    static const _indian = _Style(
    ['{x} Primary School', '{x} Vidyalaya Primary', '{x} Convent School'],
    ['{x} Public School', '{x} Vidya Mandir', '{x} Upper Primary School'],
    ['{x} Senior Secondary School', '{x} Higher Secondary School', '{x} Public School'],
    ['University of {c}', '{c} Institute of Technology', '{c} Central University'],
    ['Saraswati', 'Kendriya', 'Delhi', 'Vidya Mandir', 'Gandhi Memorial', 'Tagore', 'Nehru', 'Ambedkar', 'Vivekananda', 'Patel', 'Bose', 'Kalam', 'Sarojini', 'Ramanujan'],
  );
    static const _southAsian = _Style(
    ['{x} Primary School', '{x} Model Primary School'],
    ['{x} Middle School', '{x} Model School'],
    ['{x} High School', '{x} Higher Secondary School', '{x} College'],
    ['{c} University', '{c} Institute of Technology', '{c} National University'],
    ['Iqbal', 'Jinnah', 'Himalaya', 'Mount Everest', 'Sagarmatha', 'Lumbini', 'Allama Iqbal', 'Annapurna', 'Karakoram', 'Kathmandu Valley', 'Ravi', 'Indus', 'Pashupati', 'Manaslu'],
  );
    static const _arabic = _Style(
    ['Al-{x} Primary School', '{x} Primary School', 'Al-{x} Model School'],
    ['Al-{x} Intermediate School', '{x} Intermediate School'],
    ['Al-{x} Secondary School', '{x} Secondary School', 'Al-{x} International School'],
    ['{c} University', '{c} Technical University', '{c} National University'],
    ['Noor', 'Amal', 'Salam', 'Huda', 'Falah', 'Najah', 'Rashid', 'Andalus', 'Sabah', 'Nour', 'Zahra', 'Yasmin', 'Ibn Sina', 'Khawarizmi', 'Farabi', 'Ghazali'],
  );
    static const _african = _Style(
    ['St. {x} Primary School', '{x} Primary Academy', '{x} Basic School'],
    ['{x} Junior Secondary School', '{x} Junior High School', '{x} Preparatory School'],
    ['{x} Senior Secondary School', '{x} Senior High School', '{x} Grammar School'],
    ['University of {c}', '{c} State University', '{c} Polytechnic', '{x} University College'],
    ['Mary\'s', 'Joseph\'s', 'Peter\'s', 'Unity', 'Freedom', 'Heritage', 'Hope', 'Nelson Mandela', 'Kilimanjaro', 'Baobab', 'Accra Heights', 'Savanna', 'Victoria', 'Nile', 'Uhuru', 'Ubuntu', 'Jomo Kenyatta', 'Kwame Nkrumah'],
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
    final templates = switch (stage) {
      SchoolStage.elementary => style.elementary,
      SchoolStage.middle => style.middle,
      SchoolStage.high => style.high,
      SchoolStage.university => style.university,
      SchoolStage.none => style.high,
    };
    final template = templates[random.nextInt(templates.length)];

    return template
        .replaceAll('{x}', style.names[random.nextInt(style.names.length)])
        .replaceAll('{c}', cityName)
        .replaceAll('{n}', '${1 + random.nextInt(30)}');
  }
}
