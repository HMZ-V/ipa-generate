// ============================================================
// models.dart — Dart equivalents of all TypeScript types in
// src/lib/data.ts and src/lib/store.ts
// ============================================================

// ── Enums ────────────────────────────────────────────────────────────────────

enum Risk { low, medium, high }

enum Rarity { common, rare, epic, legendary }

enum DistrictStatus { stable, rising, hot, contested }

enum DemandLevel { low, medium, high }

enum MissionKind { daily, weekly }

enum TransactionType { buy, yield_, stake, mission }

// ── District ─────────────────────────────────────────────────────────────────

class Rival {
  final String name;
  final int pct;

  const Rival({required this.name, required this.pct});
}

class District {
  final String id;
  final String name;
  final String emoji;
  final String imagePath;     // local assets/images/ path
  final int control;          // your % ownership
  final String topAlliance;
  final DemandLevel demand;
  final DistrictStatus status;
  final int? unlockLevel;     // null = unlocked from start
  final List<Rival> rivals;
  final List<String> perks;
  final String about;

  const District({
    required this.id,
    required this.name,
    required this.emoji,
    required this.imagePath,
    required this.control,
    required this.topAlliance,
    required this.demand,
    required this.status,
    this.unlockLevel,
    required this.rivals,
    required this.perks,
    required this.about,
  });

  bool get isLocked => unlockLevel != null;
}

// ── Block (property block / REIT unit) ───────────────────────────────────────

class Block {
  final String id;
  final String name;
  final String district;      // human-readable district name
  final String districtId;    // FK to District.id
  final String imagePath;
  final int priceSTK;
  final double yieldPct;
  final DemandLevel occupancy;
  final Risk risk;
  final Rarity rarity;
  final int available;        // units still for sale
  final int total;            // total units that exist
  final bool isHot;
  final bool isContested;

  const Block({
    required this.id,
    required this.name,
    required this.district,
    required this.districtId,
    required this.imagePath,
    required this.priceSTK,
    required this.yieldPct,
    required this.occupancy,
    required this.risk,
    required this.rarity,
    required this.available,
    required this.total,
    this.isHot = false,
    this.isContested = false,
  });

  bool get isSoldOut => available == 0;

  /// Quarterly estimated payout per unit in STK
  double get quarterlyEstSTK => priceSTK * yieldPct / 100 / 4;
}

// ── Holding ──────────────────────────────────────────────────────────────────

class Holding {
  final String blockId;
  final int units;

  const Holding({required this.blockId, required this.units});

  Holding copyWith({String? blockId, int? units}) => Holding(
        blockId: blockId ?? this.blockId,
        units: units ?? this.units,
      );

  /// Serialise to/from SharedPreferences JSON
  Map<String, dynamic> toJson() => {'blockId': blockId, 'units': units};

  factory Holding.fromJson(Map<String, dynamic> j) =>
      Holding(blockId: j['blockId'] as String, units: j['units'] as int);
}

// ── Mission ───────────────────────────────────────────────────────────────────

class Mission {
  final int id;
  final String title;
  final int progress;
  final int total;
  final int xpReward;
  final int stkReward;
  final MissionKind kind;

  const Mission({
    required this.id,
    required this.title,
    required this.progress,
    required this.total,
    required this.xpReward,
    required this.stkReward,
    required this.kind,
  });

  double get progressFraction => total > 0 ? progress / total : 0;
  bool get isComplete => progress >= total;
}

// ── Lesson ────────────────────────────────────────────────────────────────────

class Lesson {
  final String id;
  final String title;
  final String emoji;
  final int mins;
  final bool isDone;
  final String unlocks;

  const Lesson({
    required this.id,
    required this.title,
    required this.emoji,
    required this.mins,
    required this.isDone,
    required this.unlocks,
  });
}

// ── Transaction ───────────────────────────────────────────────────────────────

class Transaction {
  final int id;
  final TransactionType type;
  final String label;
  final double stk;           // negative = spend, positive = receive
  final String time;

  const Transaction({
    required this.id,
    required this.type,
    required this.label,
    required this.stk,
    required this.time,
  });

  bool get isPositive => stk >= 0;
}

// ── Alliance ──────────────────────────────────────────────────────────────────

class AllianceMember {
  final String name;
  final int rank;
  final int pts;
  final bool isYou;

  const AllianceMember({
    required this.name,
    required this.rank,
    required this.pts,
    this.isYou = false,
  });
}

class Alliance {
  final String tag;
  final String name;
  final String motto;
  final int rank;
  final int rankDelta;
  final int members;
  final int maxMembers;
  final int blocks;
  final int districtsControlled;
  final int treasury;
  final int seasonPts;
  final int yourContribution;
  final List<AllianceMember> topMembers;

  const Alliance({
    required this.tag,
    required this.name,
    required this.motto,
    required this.rank,
    required this.rankDelta,
    required this.members,
    required this.maxMembers,
    required this.blocks,
    required this.districtsControlled,
    required this.treasury,
    required this.seasonPts,
    required this.yourContribution,
    required this.topMembers,
  });
}

class AllianceLeaderboardEntry {
  final int rank;
  final String name;
  final int pts;
  final int delta;
  final bool isYou;

  const AllianceLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.pts,
    required this.delta,
    this.isYou = false,
  });
}

// ── Notification ──────────────────────────────────────────────────────────────

class AppNotification {
  final int id;
  final String kind;   // alert | yield | event | alliance | lesson
  final String title;
  final String body;
  final String time;

  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.time,
  });
}

// ── User (static profile data) ────────────────────────────────────────────────

class UserProfile {
  final String name;
  final String username;
  final int level;
  final int xp;
  final int xpMax;
  final int rank;
  final int streak;
  final int stk;
  final double cashAED;
  final double pendingAED;
  final double portfolioAED;
  final double portfolioDelta;
  final double portfolioWeekAED;
  final int ownedBlocksCount;
  final int districtsControlled;
  final int staked;

  const UserProfile({
    required this.name,
    required this.username,
    required this.level,
    required this.xp,
    required this.xpMax,
    required this.rank,
    required this.streak,
    required this.stk,
    required this.cashAED,
    required this.pendingAED,
    required this.portfolioAED,
    required this.portfolioDelta,
    required this.portfolioWeekAED,
    required this.ownedBlocksCount,
    required this.districtsControlled,
    required this.staked,
  });
}

// ── Constants ─────────────────────────────────────────────────────────────────

const double kStkRate = 3.67; // 1 STK = 3.67 AED

int aedFromStk(num stk) => (stk * kStkRate).round();
