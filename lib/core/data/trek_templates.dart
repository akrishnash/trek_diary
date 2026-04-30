// Curated day-wise itineraries from India Hikes / TTH sources.
// Each template auto-fills the full trek when selected on the create screen.

class StopTemplate {
  final String name;
  final int elevation; // metres
  final double distance; // km from previous stop

  const StopTemplate(this.name, this.elevation, {this.distance = 0.0});
}

class DayTemplate {
  final String title;
  final List<StopTemplate> stops;

  const DayTemplate({required this.title, required this.stops});
}

class TrekTemplate {
  final String name;
  final String region;
  final String difficulty;
  final String description;
  final List<DayTemplate> days;

  const TrekTemplate({
    required this.name,
    required this.region,
    required this.difficulty,
    required this.description,
    required this.days,
  });

  int get totalDays  => days.length;
  int get totalStops => days.fold(0, (s, d) => s + d.stops.length);

  static List<TrekTemplate> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return [];
    return all.where((t) => t.name.toLowerCase().contains(q)).toList();
  }
}

const all = <TrekTemplate>[
  // ── UTTARAKHAND ────────────────────────────────────────────────────────────

  TrekTemplate(
    name: 'Kedarkantha Trek',
    region: 'Uttarkashi, Uttarakhand',
    difficulty: 'Easy-Moderate',
    description:
        'One of the most popular winter treks in India. Known for its stunning summit views of Swargarohini, Black Peak, and Bandarpunch. Best season: December–April.',
    days: [
      DayTemplate(title: 'Sankri to Juda Ka Talab', stops: [
        StopTemplate('Sankri', 1950),
        StopTemplate('Juda Ka Talab', 2708, distance: 6),
      ]),
      DayTemplate(title: 'Juda Ka Talab to Kedarkantha Base', stops: [
        StopTemplate('Kedarkantha Base Camp', 3650, distance: 4),
      ]),
      DayTemplate(title: 'Summit Day — Base to Hargaon', stops: [
        StopTemplate('Kedarkantha Summit', 3800, distance: 2),
        StopTemplate('Hargaon Camp', 2680, distance: 4),
      ]),
      DayTemplate(title: 'Hargaon to Sankri', stops: [
        StopTemplate('Sankri', 1950, distance: 11),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Roopkund Trek',
    region: 'Chamoli, Uttarakhand',
    difficulty: 'Difficult',
    description:
        'The mystery lake trek. Roopkund sits at 5029m and holds ancient skeletal remains. Passes through the stunning bugyals of Ali and Bedni. Best season: May–June, Sep–Oct.',
    days: [
      DayTemplate(title: 'Loharjung to Didna Village', stops: [
        StopTemplate('Loharjung', 2270),
        StopTemplate('Didna Village', 2400, distance: 9),
      ]),
      DayTemplate(title: 'Didna to Ali Bugyal', stops: [
        StopTemplate('Ali Bugyal', 3629, distance: 8),
      ]),
      DayTemplate(title: 'Ali Bugyal to Ghora Lotani', stops: [
        StopTemplate('Ghora Lotani', 3480, distance: 6),
      ]),
      DayTemplate(title: 'Ghora Lotani to Bhagwabasa', stops: [
        StopTemplate('Bhagwabasa', 4400, distance: 8),
      ]),
      DayTemplate(title: 'Roopkund Summit and Back', stops: [
        StopTemplate('Roopkund Lake', 5029, distance: 4),
        StopTemplate('Bhagwabasa Camp', 4400, distance: 4),
      ]),
      DayTemplate(title: 'Bhagwabasa to Bedni Bugyal to Wan', stops: [
        StopTemplate('Bedni Bugyal', 3354, distance: 8),
        StopTemplate('Wan Village', 2430, distance: 6),
      ]),
      DayTemplate(title: 'Wan to Loharjung', stops: [
        StopTemplate('Loharjung', 2270, distance: 11),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Valley of Flowers',
    region: 'Chamoli, Uttarakhand',
    difficulty: 'Easy-Moderate',
    description:
        'A UNESCO World Heritage Site that blooms with hundreds of wildflower species. The valley is a carpet of colour from July to September. Combined with the Hemkund Sahib pilgrimage.',
    days: [
      DayTemplate(title: 'Govindghat to Ghangaria', stops: [
        StopTemplate('Govindghat', 1829),
        StopTemplate('Bhyundar Village', 2200, distance: 4),
        StopTemplate('Ghangaria', 3050, distance: 9),
      ]),
      DayTemplate(title: 'Ghangaria to Valley of Flowers', stops: [
        StopTemplate('Valley of Flowers Entry Gate', 3352, distance: 3),
        StopTemplate('Pushpawati River', 3600, distance: 5),
      ]),
      DayTemplate(title: 'Hemkund Sahib', stops: [
        StopTemplate('Hemkund Sahib Gurudwara', 4329, distance: 6),
        StopTemplate('Hemkund Lake', 4350, distance: 0.2),
      ]),
      DayTemplate(title: 'Valley Deep Exploration', stops: [
        StopTemplate('Upper Valley Meadow', 3658, distance: 5),
      ]),
      DayTemplate(title: 'Ghangaria to Govindghat', stops: [
        StopTemplate('Govindghat', 1829, distance: 13),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Brahmatal Trek',
    region: 'Chamoli, Uttarakhand',
    difficulty: 'Moderate',
    description:
        'A beautiful winter trek offering stunning views of Mt. Trishul and Nanda Ghunti. The frozen Brahmatal Lake is the highlight. Best season: December–March.',
    days: [
      DayTemplate(title: 'Lohajung to Bekaltal', stops: [
        StopTemplate('Lohajung', 2270),
        StopTemplate('Bekaltal Campsite', 2850, distance: 9),
      ]),
      DayTemplate(title: 'Bekaltal to Brahmatal', stops: [
        StopTemplate('Brahmatal', 3462, distance: 6),
      ]),
      DayTemplate(title: 'Brahmatal Peak and Tilandi', stops: [
        StopTemplate('Brahmatal Peak', 3647, distance: 3),
        StopTemplate('Tilandi Campsite', 3700, distance: 5),
      ]),
      DayTemplate(title: 'Tilandi to Wan Village', stops: [
        StopTemplate('Wan Village', 2430, distance: 8),
      ]),
      DayTemplate(title: 'Wan to Lohajung', stops: [
        StopTemplate('Lohajung', 2270, distance: 3),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Dayara Bugyal',
    region: 'Uttarkashi, Uttarakhand',
    difficulty: 'Easy',
    description:
        'One of the most beautiful alpine meadows in India, stretching across 28 sq km. Panoramic views of Bandarpunch, Srikanth, Gangotri, and Jaonli peaks. Best season: Sep–Nov, Jan–Mar.',
    days: [
      DayTemplate(title: 'Barsu to Barnala Tal', stops: [
        StopTemplate('Barsu Village', 2990),
        StopTemplate('Barnala Tal', 3200, distance: 5),
      ]),
      DayTemplate(title: 'Barnala Tal to Dayara Bugyal', stops: [
        StopTemplate('Dayara Bugyal', 3658, distance: 4),
      ]),
      DayTemplate(title: 'Dayara to Bakaria Top', stops: [
        StopTemplate('Bakaria Top', 3808, distance: 4),
        StopTemplate('Dayara Bugyal Camp', 3658, distance: 4),
      ]),
      DayTemplate(title: 'Dayara Bugyal to Barsu', stops: [
        StopTemplate('Barsu Village', 2990, distance: 5),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Har Ki Dun',
    region: 'Uttarkashi, Uttarakhand',
    difficulty: 'Easy-Moderate',
    description:
        'The "Valley of Gods" — a cradle-shaped valley at 3566m in the Govind National Park. Offers views of Swargarohini, Bandarpunch, and Black Peak. Best season: Apr–Jun, Sep–Nov.',
    days: [
      DayTemplate(title: 'Sankri to Taluka', stops: [
        StopTemplate('Sankri', 1950),
        StopTemplate('Taluka', 1900, distance: 12),
      ]),
      DayTemplate(title: 'Taluka to Osla', stops: [
        StopTemplate('Osla Village', 2560, distance: 11),
      ]),
      DayTemplate(title: 'Osla to Har Ki Dun', stops: [
        StopTemplate('Har Ki Dun', 3566, distance: 9),
      ]),
      DayTemplate(title: 'Har Ki Dun to Morinda Tal', stops: [
        StopTemplate('Morinda Tal', 3898, distance: 5),
        StopTemplate('Har Ki Dun Camp', 3566, distance: 5),
      ]),
      DayTemplate(title: 'Har Ki Dun to Taluka', stops: [
        StopTemplate('Osla Village', 2560, distance: 9),
        StopTemplate('Taluka', 1900, distance: 11),
      ]),
      DayTemplate(title: 'Taluka to Sankri', stops: [
        StopTemplate('Sankri', 1950, distance: 12),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Rupin Pass Trek',
    region: 'Uttarkashi to Kinnaur, Himachal Pradesh',
    difficulty: 'Difficult',
    description:
        'Ranked one of the best treks in India. Crosses a high-altitude pass at 4650m through the spectacular Rupin waterfall and snow bridge. Best season: May–Jun, Sep–Oct.',
    days: [
      DayTemplate(title: 'Dhaula to Sewa', stops: [
        StopTemplate('Dhaula', 1830),
        StopTemplate('Sewa', 2380, distance: 9),
      ]),
      DayTemplate(title: 'Sewa to Jiskun', stops: [
        StopTemplate('Jiskun', 2560, distance: 9),
      ]),
      DayTemplate(title: 'Jiskun to Rupin', stops: [
        StopTemplate('Rupin', 2650, distance: 9),
      ]),
      DayTemplate(title: 'Rupin to Upper Waterfall Camp', stops: [
        StopTemplate('Lower Waterfall Camp', 3300, distance: 4),
        StopTemplate('Upper Waterfall Camp', 3600, distance: 3),
      ]),
      DayTemplate(title: 'Rupin Pass Crossing to Ronti Gad', stops: [
        StopTemplate('Rupin Pass', 4650, distance: 4),
        StopTemplate('Ronti Gad', 4100, distance: 3),
      ]),
      DayTemplate(title: 'Ronti Gad to Sangla Kanda', stops: [
        StopTemplate('Sangla Kanda', 3930, distance: 7),
      ]),
      DayTemplate(title: 'Sangla Kanda to Sangla', stops: [
        StopTemplate('Sangla', 2680, distance: 12),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Chopta Tungnath Chandrashila',
    region: 'Rudraprayag, Uttarakhand',
    difficulty: 'Easy',
    description:
        'Tungnath is the highest Shiva temple in the world at 3680m. Chandrashila summit offers 360° views of Nanda Devi, Trishul, Kedar Peak, and Chaukhamba. Best season: Apr–Jun, Sep–Nov.',
    days: [
      DayTemplate(title: 'Ukhimath to Chopta', stops: [
        StopTemplate('Ukhimath', 1311),
        StopTemplate('Chopta', 2680, distance: 35),
      ]),
      DayTemplate(title: 'Chopta to Chandrashila Summit', stops: [
        StopTemplate('Tungnath Temple', 3680, distance: 3.5),
        StopTemplate('Chandrashila Summit', 4130, distance: 1.5),
        StopTemplate('Chopta', 2680, distance: 5),
      ]),
      DayTemplate(title: 'Chopta to Deoria Tal', stops: [
        StopTemplate('Deoria Tal', 2438, distance: 3),
        StopTemplate('Sari Village', 1900, distance: 2),
      ]),
    ],
  ),

  // ── HIMACHAL PRADESH ───────────────────────────────────────────────────────

  TrekTemplate(
    name: 'Hampta Pass Trek',
    region: 'Kullu / Lahaul, Himachal Pradesh',
    difficulty: 'Moderate',
    description:
        'A dramatic crossover trek from the green Kullu Valley to the barren moonscape of Lahaul. Includes the optional Chandratal Lake — one of the most stunning high-altitude lakes in India.',
    days: [
      DayTemplate(title: 'Manali to Chika Camp', stops: [
        StopTemplate('Jobra', 2940, distance: 13),
        StopTemplate('Chika Camp', 3100, distance: 3),
      ]),
      DayTemplate(title: 'Chika to Balu Ka Ghera', stops: [
        StopTemplate('Jwara', 3400, distance: 4),
        StopTemplate('Balu Ka Ghera', 3540, distance: 4),
      ]),
      DayTemplate(title: 'Hampta Pass Crossing to Shea Goru', stops: [
        StopTemplate('Hampta Pass', 4270, distance: 5),
        StopTemplate('Shea Goru Camp', 3800, distance: 6),
      ]),
      DayTemplate(title: 'Shea Goru to Chandratal Lake', stops: [
        StopTemplate('Chatru', 3360, distance: 5),
        StopTemplate('Chandratal Lake', 4300, distance: 6),
      ]),
      DayTemplate(title: 'Chandratal to Manali', stops: [
        StopTemplate('Rohtang Pass', 3978, distance: 25),
        StopTemplate('Manali', 2050, distance: 24),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Sar Pass Trek',
    region: 'Parvati Valley, Kullu, Himachal Pradesh',
    difficulty: 'Moderate',
    description:
        'A classic Himalayan pass trek through dense forests, alpine meadows and snowy slopes. Sar Pass at 4250m sits in the heart of the Parvati Valley.',
    days: [
      DayTemplate(title: 'Kasol to Grahan', stops: [
        StopTemplate('Kasol', 1640),
        StopTemplate('Grahan Village', 2100, distance: 6),
      ]),
      DayTemplate(title: 'Grahan to Min Thatch', stops: [
        StopTemplate('Min Thatch', 2900, distance: 9),
      ]),
      DayTemplate(title: 'Min Thatch to Nagaru', stops: [
        StopTemplate('Nagaru', 3650, distance: 7),
      ]),
      DayTemplate(title: 'Sar Pass Summit to Biskeri Thatch', stops: [
        StopTemplate('Sar Pass', 4250, distance: 3),
        StopTemplate('Biskeri Thatch', 3100, distance: 6),
      ]),
      DayTemplate(title: 'Biskeri Thatch to Barshaini', stops: [
        StopTemplate('Barshaini', 1850, distance: 9),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Buran Ghati Trek',
    region: 'Shimla, Himachal Pradesh',
    difficulty: 'Difficult',
    description:
        'A high-altitude pass trek at 4700m with a thrilling rappel down a snow slope. Crosses from the Shimla district to the Rohru Valley with stunning views of the Dhauladhar range.',
    days: [
      DayTemplate(title: 'Janglik to Dayara', stops: [
        StopTemplate('Janglik', 2810),
        StopTemplate('Dayara Campsite', 3660, distance: 10),
      ]),
      DayTemplate(title: 'Dayara to Litham', stops: [
        StopTemplate('Litham', 3850, distance: 5),
      ]),
      DayTemplate(title: 'Litham to Dhunda Base', stops: [
        StopTemplate('Dhunda Base Camp', 4200, distance: 8),
      ]),
      DayTemplate(title: 'Buran Ghati Pass to Tiara Dhar', stops: [
        StopTemplate('Buran Ghati', 4700, distance: 4),
        StopTemplate('Tiara Dhar', 3900, distance: 4),
      ]),
      DayTemplate(title: 'Tiara Dhar to Rohru Road', stops: [
        StopTemplate('Rohru Road', 2700, distance: 10),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Prashar Lake Trek',
    region: 'Mandi, Himachal Pradesh',
    difficulty: 'Easy',
    description:
        'A short but magical trek to a high-altitude lake at 2730m with a floating island and a 14th-century Prashar Rishi temple. Offers views of Dhauladhar and Pir Panjal ranges.',
    days: [
      DayTemplate(title: 'Baggi to Prashar Lake', stops: [
        StopTemplate('Baggi Village', 2000),
        StopTemplate('Prashar Lake', 2730, distance: 7),
      ]),
      DayTemplate(title: 'Lake Exploration and Descent', stops: [
        StopTemplate('Prashar Rishi Temple', 2730),
        StopTemplate('Baggi Village', 2000, distance: 7),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Beas Kund Trek',
    region: 'Kullu, Himachal Pradesh',
    difficulty: 'Easy',
    description:
        'A short alpine trek to the origin of the Beas River. The glacial lake sits below the Hampta Pass range, with views of Hanuman Tibba and Shitidhar peaks.',
    days: [
      DayTemplate(title: 'Solang Valley to Beas Kund Base', stops: [
        StopTemplate('Solang Valley', 2480),
        StopTemplate('Dhundi', 2530, distance: 2),
        StopTemplate('Bakarthach', 3000, distance: 4),
        StopTemplate('Beas Kund Base', 3540, distance: 4),
      ]),
      DayTemplate(title: 'Base Camp to Beas Kund Lake', stops: [
        StopTemplate('Beas Kund', 3660, distance: 3),
        StopTemplate('Base Camp', 3540, distance: 3),
      ]),
      DayTemplate(title: 'Base Camp to Solang Valley', stops: [
        StopTemplate('Dhundi', 2530, distance: 6),
        StopTemplate('Solang Valley', 2480, distance: 2),
      ]),
    ],
  ),

  // ── KASHMIR ────────────────────────────────────────────────────────────────

  TrekTemplate(
    name: 'Tarsar Marsar Trek',
    region: 'Pahalgam, Kashmir',
    difficulty: 'Moderate',
    description:
        'Two of the most beautiful alpine lakes in Kashmir — Tarsar at 3800m and Marsar at 3900m. The trek is famous for its meadows full of wildflowers and pine forests.',
    days: [
      DayTemplate(title: 'Pahalgam to Aru', stops: [
        StopTemplate('Pahalgam', 2130),
        StopTemplate('Aru Valley', 2408, distance: 11),
      ]),
      DayTemplate(title: 'Aru to Lidderwat', stops: [
        StopTemplate('Lidderwat', 3200, distance: 11),
      ]),
      DayTemplate(title: 'Lidderwat to Shekwas', stops: [
        StopTemplate('Shekwas', 3620, distance: 9),
      ]),
      DayTemplate(title: 'Shekwas to Tarsar Lake', stops: [
        StopTemplate('Tarsar Lake', 3800, distance: 5),
      ]),
      DayTemplate(title: 'Tarsar to Marsar Lake', stops: [
        StopTemplate('Sundarsar Lake', 3900, distance: 4),
        StopTemplate('Marsar Lake', 3700, distance: 4),
      ]),
      DayTemplate(title: 'Marsar to Aru', stops: [
        StopTemplate('Homwas', 2800, distance: 6),
        StopTemplate('Aru Valley', 2408, distance: 4),
      ]),
      DayTemplate(title: 'Aru to Pahalgam', stops: [
        StopTemplate('Pahalgam', 2130, distance: 11),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Kareri Lake Trek',
    region: 'Dharamsala, Himachal Pradesh',
    difficulty: 'Easy-Moderate',
    description:
        'A pristine glacial lake at 2950m near Dharamsala, known for its turquoise waters and views of the Dhauladhar range including Mun Peak. Best season: Apr–Jun, Sep–Nov.',
    days: [
      DayTemplate(title: 'Mcleodganj to Riwala Rupi', stops: [
        StopTemplate('Kareri Village', 1829, distance: 6),
        StopTemplate('Riwala Rupi Camp', 2200, distance: 3),
      ]),
      DayTemplate(title: 'Riwala Rupi to Kareri Lake', stops: [
        StopTemplate('Kareri Lake', 2950, distance: 7),
      ]),
      DayTemplate(title: 'Lake and Return', stops: [
        StopTemplate('Kareri Village', 1829, distance: 10),
        StopTemplate('Mcleodganj', 1457, distance: 6),
      ]),
    ],
  ),

  // ── LADAKH ─────────────────────────────────────────────────────────────────

  TrekTemplate(
    name: 'Chadar Trek',
    region: 'Zanskar, Ladakh',
    difficulty: 'Difficult',
    description:
        'Walk on the frozen Zanskar River — one of the most unique treks in the world. The "Chadar" (sheet of ice) forms only in January–February. This is a true wilderness experience.',
    days: [
      DayTemplate(title: 'Leh to Chilling', stops: [
        StopTemplate('Leh', 3524),
        StopTemplate('Chilling', 3150, distance: 65),
      ]),
      DayTemplate(title: 'Chilling to Tilat Sumdo', stops: [
        StopTemplate('Gyalpo', 3250, distance: 7),
        StopTemplate('Tilat Sumdo', 3350, distance: 7),
      ]),
      DayTemplate(title: 'Tilat Sumdo to Tibb Cave', stops: [
        StopTemplate('Shingra Koma', 3400, distance: 7),
        StopTemplate('Tibb Cave', 3500, distance: 7),
      ]),
      DayTemplate(title: 'Tibb Cave to Nerak', stops: [
        StopTemplate('Nerak Waterfall', 3800, distance: 7),
        StopTemplate('Nerak Village', 3820, distance: 0.5),
      ]),
      DayTemplate(title: 'Nerak Return to Tibb Cave', stops: [
        StopTemplate('Tibb Cave', 3500, distance: 7.5),
      ]),
      DayTemplate(title: 'Tibb to Chilling', stops: [
        StopTemplate('Shingra Koma', 3400, distance: 7),
        StopTemplate('Tilat Sumdo', 3350, distance: 7),
        StopTemplate('Chilling', 3150, distance: 14),
      ]),
      DayTemplate(title: 'Chilling to Leh', stops: [
        StopTemplate('Leh', 3524, distance: 65),
      ]),
    ],
  ),

  // ── WEST BENGAL / SIKKIM ───────────────────────────────────────────────────

  TrekTemplate(
    name: 'Sandakphu Trek',
    region: 'Darjeeling, West Bengal',
    difficulty: 'Moderate',
    description:
        'The highest point in West Bengal at 3636m. The only place where you can see four of the world\'s five highest peaks — Everest, Kangchenjunga, Lhotse, and Makalu — in one panorama.',
    days: [
      DayTemplate(title: 'Manebhanjan to Tumling', stops: [
        StopTemplate('Manebhanjan', 2134),
        StopTemplate('Chitre', 2336, distance: 4),
        StopTemplate('Tumling', 2970, distance: 7),
      ]),
      DayTemplate(title: 'Tumling to Kalipokhri', stops: [
        StopTemplate('Gairibas', 2620, distance: 4),
        StopTemplate('Kalipokhri', 3182, distance: 9),
      ]),
      DayTemplate(title: 'Kalipokhri to Sandakphu', stops: [
        StopTemplate('Sandakphu Summit', 3636, distance: 14),
      ]),
      DayTemplate(title: 'Sandakphu to Phalut', stops: [
        StopTemplate('Sabarkum', 3200, distance: 10),
        StopTemplate('Phalut', 3596, distance: 11),
      ]),
      DayTemplate(title: 'Phalut to Gorkhey and Rimbick', stops: [
        StopTemplate('Gorkhey', 2180, distance: 14),
        StopTemplate('Rimbick', 2286, distance: 10),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Dzongri Goecha La Trek',
    region: 'West Sikkim',
    difficulty: 'Challenging',
    description:
        'One of the most iconic high-altitude treks in eastern India. Goecha La at 4940m offers a breathtaking view of the south face of Mt. Kangchenjunga, the world\'s third-highest peak.',
    days: [
      DayTemplate(title: 'Yuksom to Sachen', stops: [
        StopTemplate('Yuksom', 1780),
        StopTemplate('Sachen', 2185, distance: 8),
      ]),
      DayTemplate(title: 'Sachen to Tshoka', stops: [
        StopTemplate('Tshoka', 3000, distance: 7),
      ]),
      DayTemplate(title: 'Tshoka to Dzongri', stops: [
        StopTemplate('Phedang Meadow', 3650, distance: 4),
        StopTemplate('Dzongri', 4020, distance: 4),
      ]),
      DayTemplate(title: 'Dzongri Top and Thansing', stops: [
        StopTemplate('Dzongri Top', 4300, distance: 2),
        StopTemplate('Thansing', 3940, distance: 9),
      ]),
      DayTemplate(title: 'Thansing to Samiti Lake to Lamuney', stops: [
        StopTemplate('Samiti Lake', 4200, distance: 4),
        StopTemplate('Lamuney', 4180, distance: 3),
      ]),
      DayTemplate(title: 'Goecha La Viewpoint and Back', stops: [
        StopTemplate('Zemathang', 4600, distance: 3),
        StopTemplate('Goecha La Viewpoint 1', 4800, distance: 2),
        StopTemplate('Goecha La', 4940, distance: 1),
        StopTemplate('Lamuney', 4180, distance: 8),
      ]),
      DayTemplate(title: 'Lamuney to Dzongri', stops: [
        StopTemplate('Thansing', 3940, distance: 7),
        StopTemplate('Dzongri', 4020, distance: 4),
      ]),
      DayTemplate(title: 'Dzongri to Tshoka', stops: [
        StopTemplate('Tshoka', 3000, distance: 8),
      ]),
      DayTemplate(title: 'Tshoka to Yuksom', stops: [
        StopTemplate('Sachen', 2185, distance: 9),
        StopTemplate('Yuksom', 1780, distance: 7),
      ]),
    ],
  ),

  TrekTemplate(
    name: 'Pin Bhaba Pass Trek',
    region: 'Kinnaur to Spiti, Himachal Pradesh',
    difficulty: 'Difficult',
    description:
        'A crossover trek from Kinnaur to Spiti across the Pin Bhaba Pass at 5319m. The landscapes shift dramatically from green Kinnaur forests to the barren high-altitude desert of Spiti.',
    days: [
      DayTemplate(title: 'Kafnu to Mulling', stops: [
        StopTemplate('Kafnu', 2800),
        StopTemplate('Mulling', 3000, distance: 10),
      ]),
      DayTemplate(title: 'Mulling to Phokchori', stops: [
        StopTemplate('Phokchori', 3450, distance: 9),
      ]),
      DayTemplate(title: 'Phokchori to Boulder Camp', stops: [
        StopTemplate('Boulder Camp', 4200, distance: 8),
      ]),
      DayTemplate(title: 'Pin Bhaba Pass Crossing', stops: [
        StopTemplate('Pin Bhaba Pass', 5319, distance: 4),
        StopTemplate('Tari Khango Camp', 4200, distance: 4),
      ]),
      DayTemplate(title: 'Tari Khango to Mudh Village', stops: [
        StopTemplate('Mudh Village', 3720, distance: 15),
      ]),
      DayTemplate(title: 'Mudh to Kaza', stops: [
        StopTemplate('Kaza', 3800, distance: 14),
      ]),
    ],
  ),
];
