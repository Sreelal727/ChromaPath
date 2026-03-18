import 'dart:ui';

import '../logic/level_generator.dart';
import '../models/level.dart';

// =========================================================================
// LEVEL DATA — 50 levels with genuine difficulty progression
//
// Difficulty comes from TWO factors:
//   1. RANDOM HAMILTONIAN PATHS — paths twist unpredictably through the
//      grid, making the correct route impossible to guess at a glance.
//   2. UNEVEN SEGMENT LENGTHS — on harder levels, some colors occupy 2
//      cells while others snake through 20+, creating deceptive puzzles.
//
// Levels 1-5:    5×5 tutorial (snake pattern, equal splits — learn rules)
// Levels 6-10:   5×5 random paths, even splits (getting harder)
// Levels 11-15:  6×6 random paths, moderate variation
// Levels 16-20:  6×6 random paths, high variation (already challenging)
// Levels 21-25:  7×7 random, high variation
// Levels 26-30:  7×7 random, extreme variation + more colors
// Levels 31-35:  8×8 random, extreme variation
// Levels 36-40:  8×8 random, extreme, many colors
// Levels 41-45:  9×9 random, extreme
// Levels 46-50:  9×9 random, maximum chaos
// =========================================================================

typedef LevelSolution = Map<Color, List<(int, int)>>;

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Level configs: (id, gridSize, numColors, difficulty, seed)
//   difficulty: 0.0 = tutorial, 0.5 = medium, 1.0 = maximum
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

const _configs = <(int, int, int, double, int)>[
  // ── 5×5 Tutorial (levels 1-5): snake paths, easy splits ──
  ( 1, 5,  3, 0.0,  1001),
  ( 2, 5,  3, 0.0,  1002),
  ( 3, 5,  4, 0.1,  1003),
  ( 4, 5,  4, 0.1,  1004),
  ( 5, 5,  4, 0.15, 1005),

  // ── 5×5 Random paths (levels 6-10): real puzzles begin ──
  ( 6, 5,  4, 0.3,  2006),
  ( 7, 5,  4, 0.4,  2007),
  ( 8, 5,  5, 0.4,  2008),
  ( 9, 5,  5, 0.5,  2009),
  (10, 5,  5, 0.5,  2010),

  // ── 6×6 Medium (levels 11-15) ──
  (11, 6,  4, 0.4,  3011),
  (12, 6,  5, 0.45, 3012),
  (13, 6,  5, 0.5,  3013),
  (14, 6,  5, 0.55, 3014),
  (15, 6,  6, 0.55, 3015),

  // ── 6×6 Hard (levels 16-20): should feel genuinely tough ──
  (16, 6,  5, 0.65, 4016),
  (17, 6,  6, 0.7,  4017),
  (18, 6,  6, 0.75, 4018),
  (19, 6,  7, 0.75, 4019),
  (20, 6,  7, 0.8,  4020),

  // ── 7×7 Hard (levels 21-25) ──
  (21, 7,  5, 0.7,  5021),
  (22, 7,  6, 0.75, 5022),
  (23, 7,  6, 0.8,  5023),
  (24, 7,  7, 0.8,  5024),
  (25, 7,  7, 0.85, 5025),

  // ── 7×7 Very hard (levels 26-30) ──
  (26, 7,  7, 0.85, 6026),
  (27, 7,  8, 0.85, 6027),
  (28, 7,  8, 0.9,  6028),
  (29, 7,  9, 0.9,  6029),
  (30, 7,  9, 0.9,  6030),

  // ── 8×8 Expert (levels 31-35) ──
  (31, 8,  6, 0.8,  7031),
  (32, 8,  7, 0.85, 7032),
  (33, 8,  7, 0.85, 7033),
  (34, 8,  8, 0.9,  7034),
  (35, 8,  8, 0.9,  7035),

  // ── 8×8 Extreme (levels 36-40) ──
  (36, 8,  9, 0.9,  8036),
  (37, 8, 10, 0.9,  8037),
  (38, 8, 10, 0.95, 8038),
  (39, 8, 11, 0.95, 8039),
  (40, 8, 11, 0.95, 8040),

  // ── 9×9 Master (levels 41-45) ──
  (41, 9,  8, 0.9,  9041),
  (42, 9,  9, 0.9,  9042),
  (43, 9, 10, 0.95, 9043),
  (44, 9, 10, 0.95, 9044),
  (45, 9, 11, 0.95, 9045),

  // ── 9×9 Grandmaster (levels 46-50) ──
  (46, 9, 11, 1.0, 10046),
  (47, 9, 12, 1.0, 10047),
  (48, 9, 12, 1.0, 10048),
  (49, 9, 13, 1.0, 10049),
  (50, 9, 13, 1.0, 10050),
];

// Generate everything at init time
final List<({Level level, LevelSolution solution})> _allData = [
  for (final (id, gs, nc, diff, seed) in _configs)
    () {
      final r = LevelGenerator.generate(
        id: id,
        gridSize: gs,
        numColors: nc,
        seed: seed,
        difficulty: diff,
      );
      return (level: r.level, solution: r.solution);
    }(),
];

/// All 50 levels.
final List<Level> allLevels = _allData.map((d) => d.level).toList();

/// Solutions keyed by level id.
final Map<int, LevelSolution> allSolutions = {
  for (final d in _allData) d.level.id: d.solution,
};

/// Total number of levels.
const int totalLevelCount = 50;
