/// A part-time job: steady money for a few hours a week, which fits next to
/// school or university. New ones unlock as the player gets older.
class PartTimeJob {
  const PartTimeJob({
    required this.id,
    required this.title,
    required this.emoji,
    required this.minAge,
    required this.pay,
    required this.blurb,
  });

  final String id;
  final String title;
  final String emoji;
  final int minAge;

  /// Yearly pay in baseline minor units (US cents), before the country's
  /// cost of living is applied.
  final int pay;

  final String blurb;
}

abstract final class PartTimeCatalog {
  static PartTimeJob? byId(String? id) {
    if (id == null) return null;

    for (final job in all) {
      if (job.id == id) return job;
    }

    return null;
  }

  /// The next age above [age] at which a part-time job unlocks.
  static int? nextUnlockAfter(int age) {
    int? next;

    for (final job in all) {
      if (job.minAge > age && (next == null || job.minAge < next)) {
        next = job.minAge;
      }
    }

    return next;
  }

  /// The youngest age at which anyone can take a part-time job.
  static int get firstAge => all.map((job) => job.minAge).reduce(
        (a, b) => a < b ? a : b,
      );

  static const List<PartTimeJob> all = [
    // --- 14 ---------------------------------------------------------------
    PartTimeJob(
      id: 'paper_route',
      title: 'Paper Route',
      emoji: '🗞️',
      minAge: 14,
      pay: 180000,
      blurb: 'Early mornings, a bag of newspapers and a bike.',
    ),
    PartTimeJob(
      id: 'babysitter',
      title: 'Regular Babysitter',
      emoji: '🍼',
      minAge: 14,
      pay: 220000,
      blurb: 'The same family every week, and a house you know well.',
    ),
    // --- 15 ---------------------------------------------------------------
    PartTimeJob(
      id: 'grocery_bagger',
      title: 'Grocery Bagger',
      emoji: '🛒',
      minAge: 15,
      pay: 260000,
      blurb: 'Pack bags, carry them to the car, smile.',
    ),
    PartTimeJob(
      id: 'dishwasher',
      title: 'Restaurant Dishwasher',
      emoji: '🍽️',
      minAge: 15,
      pay: 280000,
      blurb: 'Steam, soap and a very long line of plates.',
    ),
    // --- 16 ---------------------------------------------------------------
    PartTimeJob(
      id: 'cashier_pt',
      title: 'Part-time Cashier',
      emoji: '🧾',
      minAge: 16,
      pay: 330000,
      blurb: 'Beep, bag and count the change.',
    ),
    PartTimeJob(
      id: 'barista_pt',
      title: 'Café Barista',
      emoji: '☕',
      minAge: 16,
      pay: 350000,
      blurb: 'Learn the machine and remember everyone\'s order.',
    ),
    PartTimeJob(
      id: 'fast_food_crew',
      title: 'Fast Food Crew',
      emoji: '🍔',
      minAge: 16,
      pay: 340000,
      blurb: 'Fries, burgers and a rush at noon.',
    ),
    PartTimeJob(
      id: 'lifeguard',
      title: 'Pool Lifeguard',
      emoji: '🏊',
      minAge: 16,
      pay: 380000,
      blurb: 'Sit high, watch closely, hope for a quiet day.',
    ),
    // --- 17 ---------------------------------------------------------------
    PartTimeJob(
      id: 'library_assistant',
      title: 'Library Assistant',
      emoji: '📚',
      minAge: 17,
      pay: 320000,
      blurb: 'Shelve books and shush with a smile.',
    ),
    PartTimeJob(
      id: 'retail_associate',
      title: 'Retail Associate',
      emoji: '👗',
      minAge: 17,
      pay: 360000,
      blurb: 'Fold clothes, help customers, restock the wall.',
    ),
    PartTimeJob(
      id: 'tutoring_center',
      title: 'Tutoring Center Helper',
      emoji: '🧑‍🏫',
      minAge: 17,
      pay: 420000,
      blurb: 'Help younger students with maths and reading.',
    ),
    // --- 18 ---------------------------------------------------------------
    PartTimeJob(
      id: 'delivery_rider',
      title: 'Delivery Rider',
      emoji: '🛵',
      minAge: 18,
      pay: 450000,
      blurb: 'Your own hours, your own scooter, other people\'s dinner.',
    ),
    PartTimeJob(
      id: 'warehouse_picker',
      title: 'Warehouse Picker',
      emoji: '📦',
      minAge: 18,
      pay: 480000,
      blurb: 'Scan, pick and pack before the truck leaves.',
    ),
    PartTimeJob(
      id: 'call_center',
      title: 'Call Center Agent',
      emoji: '🎧',
      minAge: 18,
      pay: 440000,
      blurb: 'A headset, a script and patience.',
    ),
    // --- 19-20 ------------------------------------------------------------
    PartTimeJob(
      id: 'gym_front_desk',
      title: 'Gym Front Desk',
      emoji: '🏋️',
      minAge: 19,
      pay: 430000,
      blurb: 'Check in members and keep the towels coming.',
    ),
    PartTimeJob(
      id: 'campus_assistant',
      title: 'Campus Office Assistant',
      emoji: '🏫',
      minAge: 19,
      pay: 470000,
      blurb: 'Answer questions and file forms for the faculty.',
    ),
    PartTimeJob(
      id: 'teaching_assistant',
      title: 'Teaching Assistant',
      emoji: '🧪',
      minAge: 20,
      pay: 520000,
      blurb: 'Grade papers and run the lab sessions.',
    ),
    PartTimeJob(
      id: 'it_helpdesk',
      title: 'IT Help Desk',
      emoji: '🖥️',
      minAge: 20,
      pay: 580000,
      blurb: 'Have you tried turning it off and on again?',
    ),
  ];
}
