// ============================================================
// app_state.dart — Riverpod StateNotifier, ported from
// src/lib/store.ts (Zustand + persist middleware)
//
// Depends on:
//   - lib/models/models.dart
//   - lib/providers/mock_data.dart
// ============================================================

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';
import 'mock_data.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class GameState {
  final int stk;
  final int xp;
  final int level;
  final int streak;
  final List<Holding> holdings;
  final Map<String, int> districtControl;

  /// Increments every time a buy succeeds — widgets watch this to
  /// trigger the HUD flash animation (mirrors Zustand `flash` field).
  final int flashCount;

  const GameState({
    required this.stk,
    required this.xp,
    required this.level,
    required this.streak,
    required this.holdings,
    required this.districtControl,
    required this.flashCount,
  });

  GameState copyWith({
    int? stk,
    int? xp,
    int? level,
    int? streak,
    List<Holding>? holdings,
    Map<String, int>? districtControl,
    int? flashCount,
  }) {
    return GameState(
      stk: stk ?? this.stk,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      holdings: holdings ?? this.holdings,
      districtControl: districtControl ?? this.districtControl,
      flashCount: flashCount ?? this.flashCount,
    );
  }

  // ── Serialisation (replaces zustand/middleware persist) ───────────────────

  Map<String, dynamic> toJson() => {
        'stk': stk,
        'xp': xp,
        'level': level,
        'streak': streak,
        'holdings': holdings.map((h) => h.toJson()).toList(),
        'districtControl': districtControl,
        'flashCount': flashCount,
      };

  factory GameState.fromJson(Map<String, dynamic> j) => GameState(
        stk: j['stk'] as int,
        xp: j['xp'] as int,
        level: j['level'] as int,
        streak: j['streak'] as int,
        holdings: (j['holdings'] as List)
            .map((e) => Holding.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        districtControl: Map<String, int>.from(j['districtControl'] as Map),
        flashCount: j['flashCount'] as int,
      );

  // ── Computed: total portfolio value in AED ────────────────────────────────

  int get portfolioValueAED {
    int total = aedFromStk(stk);
    for (final h in holdings) {
      final block = mockBlocks.firstWhere(
        (b) => b.id == h.blockId,
        orElse: () => mockBlocks.first,
      );
      total += (block.priceSTK * h.units * 3.4).round();
    }
    return total;
  }

  // ── Computed: XP progress fraction 0.0–1.0 ───────────────────────────────
  double get xpFraction => xp / seedUser.xpMax;
}

// ── StateNotifier ─────────────────────────────────────────────────────────────

class GameStateNotifier extends StateNotifier<GameState> {
  static const _prefsKey = 'stackup-state-v1';

  GameStateNotifier() : super(_initial());

  // Build the initial state from seed data
  static GameState _initial() => GameState(
        stk: seedUser.stk,
        xp: seedUser.xp,
        level: seedUser.level,
        streak: seedUser.streak,
        holdings: List.from(seedHoldings),
        districtControl: seedDistrictControl,
        flashCount: 0,
      );

  // ── Persistence ───────────────────────────────────────────────────────────

  /// Call once at startup (inside main.dart after WidgetsFlutterBinding).
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return;
    try {
      state = GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt data — stay with initial state
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Mirrors buyBlock() in store.ts.
  /// Returns true on success, false if insufficient STK or block not found.
  bool buyBlock(String blockId, int units) {
    final block = mockBlocks.where((b) => b.id == blockId).firstOrNull;
    if (block == null) return false;

    final cost = block.priceSTK * units;
    if (state.stk < cost) return false;

    // Territory calculation  (units / block.total) * 6 → capped at 100
    final territoryAdd = ((units / block.total) * 6).round();

    // XP + level-up (2400 XP per level, mirrors store.ts)
    int newXp = state.xp + (30 * units);
    int newLevel = state.level;
    if (newXp >= 2400) {
      newXp -= 2400;
      newLevel += 1;
    }

    // Update holdings list
    final updatedHoldings = List<Holding>.from(state.holdings);
    final existingIdx = updatedHoldings.indexWhere((h) => h.blockId == blockId);
    if (existingIdx >= 0) {
      final old = updatedHoldings[existingIdx];
      updatedHoldings[existingIdx] = old.copyWith(units: old.units + units);
    } else {
      updatedHoldings.add(Holding(blockId: blockId, units: units));
    }

    // Update district control map
    final newControl = Map<String, int>.from(state.districtControl);
    final current = newControl[block.districtId] ?? 0;
    newControl[block.districtId] = (current + territoryAdd).clamp(0, 100);

    state = state.copyWith(
      stk: state.stk - cost,
      holdings: updatedHoldings,
      districtControl: newControl,
      xp: newXp,
      level: newLevel,
      flashCount: state.flashCount + 1, // triggers HUD glow animation
    );

    _persist(); // fire-and-forget
    return true;
  }

  /// Resets to the original seed state (mirrors store.ts reset()).
  Future<void> reset() async {
    state = _initial();
    await _persist();
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Main game state — used by every screen that reads or mutates game data.
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

// ── Compare State ─────────────────────────────────────────────────────────────
// Mirrors src/lib/compare.ts — max 3 block IDs can be queued for comparison.

class CompareNotifier extends StateNotifier<List<String>> {
  CompareNotifier() : super([]);

  void toggle(String blockId) {
    if (state.contains(blockId)) {
      state = state.where((id) => id != blockId).toList();
    } else if (state.length < 3) {
      state = [...state, blockId];
    }
  }

  void clear() => state = [];
}

final compareProvider =
    StateNotifierProvider<CompareNotifier, List<String>>((ref) {
  return CompareNotifier();
});

// ── Countdown State ───────────────────────────────────────────────────────────
// Mirrors useCountdown() in compare.ts.
// A stream that ticks every second, yielding a Duration to the event end.

final countdownProvider = StreamProvider<Duration>((ref) async* {
  final end = DateTime.now().add(const Duration(hours: 2, minutes: 14));
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    final remaining = end.difference(DateTime.now());
    yield remaining.isNegative ? Duration.zero : remaining;
  }
});
