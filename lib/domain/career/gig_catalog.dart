import '../event/life_event.dart';

/// A one-off way to earn a little money: something a young person can do
/// for a few hours. Gigs unlock with age, from 12 to adulthood.
class GigDefinition {
  const GigDefinition({
    required this.id,
    required this.title,
    required this.emoji,
    required this.minAge,
    required this.blurb,
    required this.stat,
    required this.minPay,
    required this.maxPay,
    required this.win,
    required this.lose,
  });

  final String id;
  final String title;
  final String emoji;
  final int minAge;

  /// One line in the list.
  final String blurb;

  /// The stat that decides how well the gig goes.
  final StatKey stat;

  /// Pay range in baseline minor units (US cents), before the country's
  /// cost of living is applied.
  final int minPay;
  final int maxPay;

  /// What happens when it goes well, and when it does not.
  final String win;
  final String lose;
}

abstract final class GigCatalog {
  /// Gigs a player can do in one year. Without a limit, gigs would be an
  /// endless money machine.
  static const int perYear = 3;

  static GigDefinition? byId(String id) {
    for (final gig in all) {
      if (gig.id == id) return gig;
    }

    return null;
  }

  /// The lowest age at which a gig unlocks, above [age], or null when
  /// everything is already unlocked.
  static int? nextUnlockAfter(int age) {
    int? next;

    for (final gig in all) {
      if (gig.minAge > age && (next == null || gig.minAge < next)) {
        next = gig.minAge;
      }
    }

    return next;
  }

  static const List<GigDefinition> all = [
    // --- 12 ---------------------------------------------------------------
    GigDefinition(
      id: 'mow_lawns',
      title: 'Mow the neighbours\' lawns',
      emoji: '🌱',
      minAge: 12,
      blurb: 'Push a mower up and down the street.',
      stat: StatKey.fitness,
      minPay: 2000,
      maxPay: 4500,
      win: 'I mowed three lawns before lunch. The neighbours tipped me and one even offered lemonade.',
      lose: 'I mowed straight over the garden hose. The neighbour was kind about it, but I got paid half.',
    ),
    GigDefinition(
      id: 'walk_dogs',
      title: 'Walk the neighbourhood dogs',
      emoji: '🐕',
      minAge: 12,
      blurb: 'Hold a lot of leashes at once.',
      stat: StatKey.fitness,
      minPay: 1500,
      maxPay: 3500,
      win: 'Four dogs, four leashes, zero tangles. The owners already want me back next week.',
      lose: 'A squirrel appeared and the dogs left without me. I caught up eventually, out of breath and out of pay.',
    ),
    GigDefinition(
      id: 'wash_cars',
      title: 'Wash cars on the driveway',
      emoji: '🚗',
      minAge: 12,
      blurb: 'A bucket, a sponge and a sunny afternoon.',
      stat: StatKey.willpower,
      minPay: 2000,
      maxPay: 4000,
      win: 'The cars sparkled and the customers paid in cash. My arms ache, but my pockets feel good.',
      lose: 'It rained halfway through and washed away my customers with the soap.',
    ),
    GigDefinition(
      id: 'lemonade_stand',
      title: 'Run a lemonade stand',
      emoji: '🍋',
      minAge: 12,
      blurb: 'Sell cold drinks to anyone who walks by.',
      stat: StatKey.charisma,
      minPay: 1000,
      maxPay: 3000,
      win: 'A hot day and a friendly smile sold out every cup before three.',
      lose: 'Nobody walked by. I drank most of the stock myself.',
    ),
    // --- 13 ---------------------------------------------------------------
    GigDefinition(
      id: 'hand_out_flyers',
      title: 'Hand out flyers',
      emoji: '📄',
      minAge: 13,
      blurb: 'Spread the word for a local shop.',
      stat: StatKey.charisma,
      minPay: 2500,
      maxPay: 5000,
      win: 'I handed out every last flyer and the shop owner paid on the spot.',
      lose: 'The wind took half the flyers down the street. I was paid for what was left.',
    ),
    GigDefinition(
      id: 'babysit_evening',
      title: 'Babysit for an evening',
      emoji: '🍼',
      minAge: 13,
      blurb: 'Keep the kids fed, happy and in bed.',
      stat: StatKey.willpower,
      minPay: 3000,
      maxPay: 6500,
      win: 'The kids were asleep by nine and the parents left a generous tip on the table.',
      lose: 'The kids stayed up until eleven and drew on the wall. I was paid, but not rebooked.',
    ),
    GigDefinition(
      id: 'pet_sitting',
      title: 'Look after a neighbour\'s pets',
      emoji: '🐱',
      minAge: 13,
      blurb: 'Feed the cat and water the plants.',
      stat: StatKey.willpower,
      minPay: 2500,
      maxPay: 5500,
      win: 'The cat survived, the plants survived, and the neighbour came home to a clean kitchen.',
      lose: 'I forgot to water the plants once. The cat judged me for it.',
    ),
    // --- 14 ---------------------------------------------------------------
    GigDefinition(
      id: 'yard_work',
      title: 'Help with yard work',
      emoji: '🍂',
      minAge: 14,
      blurb: 'Rake, trim and haul away the leaves.',
      stat: StatKey.fitness,
      minPay: 4000,
      maxPay: 8000,
      win: 'The whole yard looked brand new by evening, and the owner paid a little extra.',
      lose: 'I raked the same pile twice because the wind kept winning.',
    ),
    GigDefinition(
      id: 'tutor_kids',
      title: 'Tutor younger kids',
      emoji: '✏️',
      minAge: 14,
      blurb: 'Help someone smaller with their homework.',
      stat: StatKey.intelligence,
      minPay: 4000,
      maxPay: 8500,
      win: 'My student finally understood fractions, and her mother paid me with a proud smile.',
      lose: 'I could not explain it any better than the textbook. The lesson ended early.',
    ),
    GigDefinition(
      id: 'sell_crafts',
      title: 'Sell handmade crafts',
      emoji: '🧶',
      minAge: 14,
      blurb: 'Turn a hobby into a small market stall.',
      stat: StatKey.creativity,
      minPay: 3000,
      maxPay: 9000,
      win: 'Someone bought three of my pieces and asked if I take orders.',
      lose: 'Lots of people looked, nobody bought. At least the stall was fun to decorate.',
    ),
    // --- 15 ---------------------------------------------------------------
    GigDefinition(
      id: 'event_setup',
      title: 'Set up chairs at an event',
      emoji: '🪑',
      minAge: 15,
      blurb: 'Carry, stack and arrange for a local event.',
      stat: StatKey.fitness,
      minPay: 5000,
      maxPay: 10000,
      win: 'The hall was ready an hour early. The organiser shook my hand and paid in full.',
      lose: 'I stacked the chairs in the wrong hall. We fixed it, but I was paid by the hour.',
    ),
    GigDefinition(
      id: 'bike_repair',
      title: 'Fix bikes for the neighbours',
      emoji: '🚲',
      minAge: 15,
      blurb: 'Patch tyres and tighten chains.',
      stat: StatKey.intelligence,
      minPay: 4500,
      maxPay: 11000,
      win: 'Three bikes rolling again by sunset. Word travels fast around here.',
      lose: 'I fixed the chain and broke the bell. The owner laughed and paid me less.',
    ),
    GigDefinition(
      id: 'shop_social_posts',
      title: 'Post for a local shop online',
      emoji: '📱',
      minAge: 15,
      blurb: 'Take photos and write the captions.',
      stat: StatKey.creativity,
      minPay: 5000,
      maxPay: 11000,
      win: 'One of my posts got a hundred shares, and the shop had a queue on Saturday.',
      lose: 'My best post got four likes, and two of them were my mother.',
    ),
    // --- 16 ---------------------------------------------------------------
    GigDefinition(
      id: 'car_detailing',
      title: 'Detail cars properly',
      emoji: '✨',
      minAge: 16,
      blurb: 'Wax, polish and vacuum for real customers.',
      stat: StatKey.willpower,
      minPay: 8000,
      maxPay: 16000,
      win: 'The owner could not believe it was the same car. He paid, tipped and booked me again.',
      lose: 'I left a streak across the windshield. I had to redo the whole thing for free.',
    ),
    GigDefinition(
      id: 'moving_help',
      title: 'Help a family move house',
      emoji: '📦',
      minAge: 16,
      blurb: 'Lift boxes, carry sofas, drink water.',
      stat: StatKey.fitness,
      minPay: 8000,
      maxPay: 15000,
      win: 'Everything made it up three flights of stairs, including the piano. Almost.',
      lose: 'A box labelled "books" was labelled wrong. My back reminded me about it all week.',
    ),
    GigDefinition(
      id: 'photo_assistant',
      title: 'Assist at a photo shoot',
      emoji: '📸',
      minAge: 16,
      blurb: 'Hold the reflector and carry the gear.',
      stat: StatKey.creativity,
      minPay: 7000,
      maxPay: 15000,
      win: 'The photographer used my lighting idea, and said so out loud.',
      lose: 'I stood in the shot twice. The photographer was patient, but only barely.',
    ),
    // --- 17 ---------------------------------------------------------------
    GigDefinition(
      id: 'exam_tutor',
      title: 'Tutor classmates before exams',
      emoji: '📚',
      minAge: 17,
      blurb: 'Turn what you know into pocket money.',
      stat: StatKey.intelligence,
      minPay: 10000,
      maxPay: 20000,
      win: 'Three classmates passed their test, and all three said it was thanks to me.',
      lose: 'My student still failed. I gave a partial refund and a lot of encouragement.',
    ),
    GigDefinition(
      id: 'freelance_writing',
      title: 'Write a short freelance article',
      emoji: '📝',
      minAge: 17,
      blurb: 'Words for an online magazine.',
      stat: StatKey.creativity,
      minPay: 9000,
      maxPay: 22000,
      win: 'The editor loved it and printed it without changing a single word.',
      lose: 'The editor asked for four rewrites. I got paid, eventually, but not a lot.',
    ),
    GigDefinition(
      id: 'sell_merch',
      title: 'Sell my own designs on shirts',
      emoji: '👕',
      minAge: 17,
      blurb: 'Print it, post it, hope someone wears it.',
      stat: StatKey.creativity,
      minPay: 7000,
      maxPay: 25000,
      win: 'A small order turned into a big order. Someone wore my design to school.',
      lose: 'The print came out crooked. I sold the whole batch at a discount.',
    ),
    // --- 18 ---------------------------------------------------------------
    GigDefinition(
      id: 'courier_run',
      title: 'Courier deliveries',
      emoji: '🛵',
      minAge: 18,
      blurb: 'Drop parcels across the city.',
      stat: StatKey.fitness,
      minPay: 15000,
      maxPay: 28000,
      win: 'Every parcel arrived on time and the app gave me a gold badge.',
      lose: 'I got lost twice and one customer was already asleep. I earned less than the petrol cost.',
    ),
    GigDefinition(
      id: 'freelance_design',
      title: 'Freelance design job',
      emoji: '🎨',
      minAge: 18,
      blurb: 'A logo, a poster, a client with opinions.',
      stat: StatKey.creativity,
      minPay: 15000,
      maxPay: 35000,
      win: 'The client approved the first draft. I almost asked if they were feeling okay.',
      lose: 'The client wanted "something like Apple, but different". It took nine drafts.',
    ),
    GigDefinition(
      id: 'data_entry',
      title: 'Data entry project',
      emoji: '⌨️',
      minAge: 18,
      blurb: 'A mountain of spreadsheets, a deadline.',
      stat: StatKey.intelligence,
      minPay: 12000,
      maxPay: 26000,
      win: 'I finished early and found two mistakes in the original file. The company noticed.',
      lose: 'I mixed up two columns on page forty. Redoing it ate my whole weekend.',
    ),
    GigDefinition(
      id: 'event_staff',
      title: 'Work as event staff',
      emoji: '🎪',
      minAge: 18,
      blurb: 'A long night at a concert or a wedding.',
      stat: StatKey.charisma,
      minPay: 14000,
      maxPay: 30000,
      win: 'The guests were happy, the organiser was happy, and I went home with a full envelope.',
      lose: 'Someone spilled a drink on the guest list, and I spent the night apologising.',
    ),
    GigDefinition(
      id: 'freelance_coding',
      title: 'Small freelance coding job',
      emoji: '💻',
      minAge: 18,
      blurb: 'Fix a website for a small business.',
      stat: StatKey.intelligence,
      minPay: 20000,
      maxPay: 45000,
      win: 'The bug was one missing bracket. The client thought I was a genius, and I let them.',
      lose: 'I fixed one bug and found three more. I charged for one.',
    ),
  ];
}
