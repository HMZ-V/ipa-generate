// ============================================================
// mock_data.dart — Static seed data ported from src/lib/data.ts
// Images reference assets/images/ folder.
// ============================================================

import '../models/models.dart';

// ── Districts ─────────────────────────────────────────────────────────────────

final List<District> mockDistricts = [
  const District(
    id: 'downtown',
    name: 'Downtown Core',
    emoji: '🏙️',
    imagePath: 'assets/images/prop-burj.jpg',
    control: 34,
    topAlliance: 'Gulf Titans',
    demand: DemandLevel.high,
    status: DistrictStatus.hot,
    rivals: [
      Rival(name: 'Gulf Titans', pct: 34),
      Rival(name: 'Atlas Capital', pct: 28),
      Rival(name: 'Old Town Co.', pct: 18),
      Rival(name: 'Others', pct: 20),
    ],
    perks: ['+12% yield boost at 50%', 'Exclusive Burj missions', 'Skyline badge'],
    about: 'Premium commercial REIT exposure. Class A office and luxury residential.',
  ),
  const District(
    id: 'marina',
    name: 'Marina Bay',
    emoji: '⛵',
    imagePath: 'assets/images/prop-marina.jpg',
    control: 22,
    topAlliance: 'Harbor Lords',
    demand: DemandLevel.high,
    status: DistrictStatus.rising,
    rivals: [
      Rival(name: 'Harbor Lords', pct: 41),
      Rival(name: 'Gulf Titans', pct: 22),
      Rival(name: 'Sunset Holdings', pct: 19),
      Rival(name: 'Others', pct: 18),
    ],
    perks: ['Waterfront yield +8%', 'Yacht-club badge'],
    about: 'Mixed-use hospitality + residential. Strong rental demand.',
  ),
  const District(
    id: 'palm',
    name: 'Palm Heights',
    emoji: '🌴',
    imagePath: 'assets/images/prop-palm.jpg',
    control: 12,
    topAlliance: 'Atlas Capital',
    demand: DemandLevel.medium,
    status: DistrictStatus.stable,
    rivals: [
      Rival(name: 'Atlas Capital', pct: 38),
      Rival(name: 'Sunset Holdings', pct: 24),
      Rival(name: 'Gulf Titans', pct: 12),
      Rival(name: 'Others', pct: 26),
    ],
    perks: ['Resort dividend bonus', 'Palm crown skin'],
    about: 'Luxury hospitality REIT. Quarterly distributions tied to occupancy.',
  ),
  const District(
    id: 'business',
    name: 'Business Bay',
    emoji: '🏢',
    imagePath: 'assets/images/prop-office.jpg',
    control: 56,
    topAlliance: 'Gulf Titans',
    demand: DemandLevel.high,
    status: DistrictStatus.rising,
    rivals: [
      Rival(name: 'Gulf Titans', pct: 56),
      Rival(name: 'Atlas Capital', pct: 18),
      Rival(name: 'Harbor Lords', pct: 14),
      Rival(name: 'Others', pct: 12),
    ],
    perks: ['DOMINATED · +15% yield', 'Boardroom mission line'],
    about: 'Commercial office REIT. Stable long-term lease income.',
  ),
  const District(
    id: 'creek',
    name: 'Old Town Quarter',
    emoji: '🕌',
    imagePath: 'assets/images/prop-creek.jpg',
    control: 8,
    topAlliance: 'Old Town Co.',
    demand: DemandLevel.medium,
    status: DistrictStatus.contested,
    rivals: [
      Rival(name: 'Old Town Co.', pct: 36),
      Rival(name: 'Harbor Lords', pct: 29),
      Rival(name: 'Gulf Titans', pct: 8),
      Rival(name: 'Others', pct: 27),
    ],
    perks: ['Heritage yield mod', 'Souk badge'],
    about: 'Heritage retail + tourism. Seasonality-driven yield.',
  ),
  const District(
    id: 'innovation',
    name: 'Innovation Hub',
    emoji: '🚀',
    imagePath: 'assets/images/prop-office.jpg',
    control: 0,
    topAlliance: '—',
    demand: DemandLevel.high,
    status: DistrictStatus.rising,
    unlockLevel: 9,
    rivals: [],
    perks: ['Tech-tower yield +20%', 'Founder badge'],
    about: 'Tech-park REIT. Unlocks at Lvl 9 after Innovation lesson.',
  ),
  const District(
    id: 'desert',
    name: 'Desert Edge',
    emoji: '🏜️',
    imagePath: 'assets/images/prop-desert.jpg',
    control: 0,
    topAlliance: '—',
    demand: DemandLevel.low,
    status: DistrictStatus.stable,
    unlockLevel: 11,
    rivals: [],
    perks: ['Land-bank speculation', 'Dune raider skin'],
    about: 'Speculative land bank. Long horizon, high upside.',
  ),
];

// ── Blocks ────────────────────────────────────────────────────────────────────

final List<Block> mockBlocks = [
  const Block(
    id: 'burj-4a',
    name: 'Burj Horizon 4A',
    district: 'Downtown Core',
    districtId: 'downtown',
    imagePath: 'assets/images/prop-burj.jpg',
    priceSTK: 120,
    yieldPct: 7.2,
    occupancy: DemandLevel.high,
    risk: Risk.low,
    rarity: Rarity.legendary,
    available: 3,
    total: 50,
    isHot: true,
  ),
  const Block(
    id: 'burj-7c',
    name: 'Burj Vista 7C',
    district: 'Downtown Core',
    districtId: 'downtown',
    imagePath: 'assets/images/prop-burj.jpg',
    priceSTK: 340,
    yieldPct: 7.4,
    occupancy: DemandLevel.high,
    risk: Risk.low,
    rarity: Rarity.legendary,
    available: 12,
    total: 80,
    isHot: true,
  ),
  const Block(
    id: 'marina-gate',
    name: 'Marina Gate Block',
    district: 'Marina Bay',
    districtId: 'marina',
    imagePath: 'assets/images/prop-marina.jpg',
    priceSTK: 220,
    yieldPct: 6.8,
    occupancy: DemandLevel.high,
    risk: Risk.medium,
    rarity: Rarity.epic,
    available: 18,
    total: 60,
    isHot: true,
  ),
  const Block(
    id: 'creek-harbor',
    name: 'Creek Harbor Tower',
    district: 'Old Town Quarter',
    districtId: 'creek',
    imagePath: 'assets/images/prop-creek.jpg',
    priceSTK: 195,
    yieldPct: 7.9,
    occupancy: DemandLevel.medium,
    risk: Risk.medium,
    rarity: Rarity.rare,
    available: 22,
    total: 70,
    isContested: true,
  ),
  const Block(
    id: 'bay-square',
    name: 'Bay Square Office',
    district: 'Business Bay',
    districtId: 'business',
    imagePath: 'assets/images/prop-office.jpg',
    priceSTK: 145,
    yieldPct: 8.9,
    occupancy: DemandLevel.high,
    risk: Risk.low,
    rarity: Rarity.rare,
    available: 9,
    total: 45,
  ),
  const Block(
    id: 'blvd-loft',
    name: 'Boulevard Loft',
    district: 'Downtown Core',
    districtId: 'downtown',
    imagePath: 'assets/images/prop-office.jpg',
    priceSTK: 265,
    yieldPct: 6.2,
    occupancy: DemandLevel.high,
    risk: Risk.low,
    rarity: Rarity.epic,
    available: 14,
    total: 55,
  ),
  const Block(
    id: 'palm-shore',
    name: 'Palm Shoreline Suites',
    district: 'Palm Heights',
    districtId: 'palm',
    imagePath: 'assets/images/prop-palm.jpg',
    priceSTK: 445,
    yieldPct: 5.6,
    occupancy: DemandLevel.medium,
    risk: Risk.medium,
    rarity: Rarity.legendary,
    available: 6,
    total: 40,
  ),
  const Block(
    id: 'marina-loft',
    name: 'Marina Loft 12B',
    district: 'Marina Bay',
    districtId: 'marina',
    imagePath: 'assets/images/prop-marina.jpg',
    priceSTK: 175,
    yieldPct: 6.4,
    occupancy: DemandLevel.high,
    risk: Risk.low,
    rarity: Rarity.rare,
    available: 28,
    total: 90,
  ),
  const Block(
    id: 'souk-arcade',
    name: 'Souk Arcade',
    district: 'Old Town Quarter',
    districtId: 'creek',
    imagePath: 'assets/images/prop-creek.jpg',
    priceSTK: 98,
    yieldPct: 8.4,
    occupancy: DemandLevel.medium,
    risk: Risk.high,
    rarity: Rarity.common,
    available: 0,
    total: 30,
    isContested: true,
  ),
];

// ── Missions ──────────────────────────────────────────────────────────────────

final List<Mission> mockMissions = [
  const Mission(id: 1, title: 'Buy 1 new block', progress: 0, total: 1, xpReward: 150, stkReward: 12, kind: MissionKind.daily),
  const Mission(id: 2, title: 'Complete a REIT lesson', progress: 1, total: 1, xpReward: 80, stkReward: 6, kind: MissionKind.daily),
  const Mission(id: 3, title: 'Compare 3 assets', progress: 2, total: 3, xpReward: 50, stkReward: 4, kind: MissionKind.daily),
  const Mission(id: 4, title: 'Reach 40% control in Downtown', progress: 34, total: 40, xpReward: 600, stkReward: 80, kind: MissionKind.weekly),
  const Mission(id: 5, title: 'Win an Alliance event', progress: 0, total: 1, xpReward: 1200, stkReward: 200, kind: MissionKind.weekly),
  const Mission(id: 6, title: 'Stake 500 STK', progress: 220, total: 500, xpReward: 300, stkReward: 40, kind: MissionKind.weekly),
];

// ── Lessons ───────────────────────────────────────────────────────────────────

final List<Lesson> mockLessons = [
  const Lesson(id: 'reit-101', title: 'What is a REIT?', emoji: '🏛️', mins: 4, isDone: true, unlocks: 'Marina Bay'),
  const Lesson(id: 'yield', title: 'Yield & Dividends', emoji: '💸', mins: 5, isDone: true, unlocks: 'Business Bay'),
  const Lesson(id: 'diversify', title: 'Diversification', emoji: '🧩', mins: 6, isDone: true, unlocks: '—'),
  const Lesson(id: 'risk', title: 'Risk Levels', emoji: '⚠️', mins: 5, isDone: false, unlocks: 'Innovation Hub'),
  const Lesson(id: 'stk', title: 'STK Tokenomics', emoji: '🪙', mins: 7, isDone: false, unlocks: 'Staking +1%'),
  const Lesson(id: 'compound', title: 'Compounding', emoji: '📈', mins: 6, isDone: false, unlocks: 'Desert Edge'),
  const Lesson(id: 'fraud', title: 'Fraud Awareness', emoji: '🛡️', mins: 5, isDone: false, unlocks: 'Veteran badge'),
];

// ── Transactions ──────────────────────────────────────────────────────────────

final List<Transaction> mockTransactions = [
  const Transaction(id: 1, type: TransactionType.buy, label: 'Bought Burj Horizon 4A', stk: -120, time: '2m ago'),
  const Transaction(id: 2, type: TransactionType.yield_, label: 'Quarterly payout · Marina Gate', stk: 18.4, time: '1h ago'),
  const Transaction(id: 3, type: TransactionType.stake, label: 'Staking reward', stk: 4.2, time: '3h ago'),
  const Transaction(id: 4, type: TransactionType.mission, label: 'Mission reward', stk: 6, time: 'yesterday'),
  const Transaction(id: 5, type: TransactionType.buy, label: 'Bought Bay Square Office', stk: -145, time: 'yesterday'),
];

// ── Alliance ──────────────────────────────────────────────────────────────────

const Alliance mockAlliance = Alliance(
  tag: 'GULF',
  name: 'Gulf Titans',
  motto: 'Hold the skyline. Earn the city.',
  rank: 3,
  rankDelta: 2,
  members: 18,
  maxMembers: 20,
  blocks: 847,
  districtsControlled: 3,
  treasury: 12400,
  seasonPts: 28420,
  yourContribution: 4180,
  topMembers: [
    AllianceMember(name: 'Layla A.', rank: 1, pts: 4820),
    AllianceMember(name: 'Omar K.', rank: 2, pts: 3210),
    AllianceMember(name: 'You (Hamza)', rank: 3, pts: 4180, isYou: true),
    AllianceMember(name: 'Yusuf M.', rank: 4, pts: 1940),
    AllianceMember(name: 'Hessa S.', rank: 5, pts: 1520),
  ],
);

final List<AllianceLeaderboardEntry> mockLeaderboard = [
  const AllianceLeaderboardEntry(rank: 1, name: 'Atlas Capital', pts: 42180, delta: 0),
  const AllianceLeaderboardEntry(rank: 2, name: 'Harbor Lords', pts: 38920, delta: 1),
  const AllianceLeaderboardEntry(rank: 3, name: 'Gulf Titans', pts: 28420, delta: 2, isYou: true),
  const AllianceLeaderboardEntry(rank: 4, name: 'Old Town Co.', pts: 22640, delta: -1),
  const AllianceLeaderboardEntry(rank: 5, name: 'Sunset Holdings', pts: 15220, delta: 0),
];

// ── Notifications ─────────────────────────────────────────────────────────────

final List<AppNotification> mockNotifications = [
  const AppNotification(id: 1, kind: 'alert', title: 'Downtown Core under threat', body: 'Atlas Capital captured 3 parcels this hour.', time: '12m'),
  const AppNotification(id: 2, kind: 'yield', title: 'Dividend received', body: '+18.4 STK from Marina Gate Block', time: '1h'),
  const AppNotification(id: 3, kind: 'event', title: 'LAND GRAB starts in 30m', body: 'Discounted blocks in Marina Bay.', time: '2h'),
  const AppNotification(id: 4, kind: 'alliance', title: 'Gulf Titans climbed +2', body: "You're now Rank #3 this season.", time: '5h'),
  const AppNotification(id: 5, kind: 'lesson', title: 'New lesson unlocked', body: 'STK Tokenomics is available.', time: '1d'),
];

// ── User Profile Seed ─────────────────────────────────────────────────────────

const UserProfile seedUser = UserProfile(
  name: 'Hamza',
  username: '@hamza',
  level: 12,
  xp: 1840,
  xpMax: 2400,
  rank: 412,
  streak: 23,
  stk: 12450,
  cashAED: 6400,
  pendingAED: 312.5,
  portfolioAED: 48230,
  portfolioDelta: 4.6,
  portfolioWeekAED: 2120,
  ownedBlocksCount: 30,
  districtsControlled: 1,
  staked: 1200,
);

// ── Initial Holdings ──────────────────────────────────────────────────────────

const List<Holding> seedHoldings = [
  Holding(blockId: 'burj-4a', units: 12),
  Holding(blockId: 'marina-gate', units: 8),
  Holding(blockId: 'bay-square', units: 10),
];

// ── Initial District Control Map ──────────────────────────────────────────────

Map<String, int> get seedDistrictControl => {
  for (final d in mockDistricts) d.id: d.control,
};
