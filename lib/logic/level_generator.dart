import 'dart:math';
import 'dart:ui';

import '../models/level.dart';

/// Generates provably solvable flow-puzzle levels with real difficulty.
///
/// **Key insight**: difficulty comes from *unpredictable path shapes*, not
/// grid size. A random Hamiltonian path through the grid creates twisting,
/// winding segments that are genuinely hard to reconstruct.
///
/// Algorithm:
/// 1. Generate a random Hamiltonian path (visits every cell exactly once)
///    using Warnsdorff's heuristic with random tie-breaking.
/// 2. Split this path into [numColors] segments.
///    - Easy mode:  roughly equal segment lengths.
///    - Hard mode:  wildly uneven lengths (some 2-cell, some huge).
/// 3. Each segment → one color-pair. Solvability guaranteed by construction.
///
/// The Warnsdorff heuristic almost always succeeds on grid graphs.
/// If it fails (stuck before covering all cells), we retry with a
/// different random seed up to 100 times, then fall back to a simple snake.
class LevelGenerator {
  static const palette = <Color>[
    Color(0xFFE53935), // red
    Color(0xFF1E88E5), // blue
    Color(0xFF43A047), // green
    Color(0xFFFB8C00), // orange
    Color(0xFF8E24AA), // purple
    Color(0xFFFDD835), // yellow
    Color(0xFF00897B), // teal
    Color(0xFFD81B60), // pink
    Color(0xFF6D4C41), // brown
    Color(0xFF546E7A), // blue-grey
    Color(0xFFFF7043), // deep orange
    Color(0xFF26C6DA), // cyan
    Color(0xFF9CCC65), // light green
    Color(0xFFAB47BC), // purple accent
  ];

  static const _dirs = [(0, 1), (0, -1), (1, 0), (-1, 0)];

  /// Generate a level with its solution.
  ///
  /// [difficulty] 0.0 = easy (equal segments, snake fallback ok),
  ///              1.0 = maximum (uneven segments, random Hamiltonian only).
  static ({Level level, Map<Color, List<(int, int)>> solution}) generate({
    required int id,
    required int gridSize,
    required int numColors,
    required int seed,
    double difficulty = 0.5,
  }) {
    final rng = Random(seed);
    final totalCells = gridSize * gridSize;

    assert(numColors >= 2);
    assert(numColors * 2 <= totalCells);

    // 1. Generate a random Hamiltonian path
    List<(int, int)>? fullPath;
    for (int attempt = 0; attempt < 100; attempt++) {
      fullPath = _tryHamiltonianPath(gridSize, Random(seed + attempt * 7919));
      if (fullPath != null) break;
    }
    // Fallback for very rare failure cases
    fullPath ??= _horizontalSnake(gridSize);

    assert(fullPath.length == totalCells);

    // 2. Split into segments with difficulty-based length distribution
    final segmentLengths = _splitSegments(
      totalCells: totalCells,
      numSegments: numColors,
      difficulty: difficulty,
      rng: rng,
    );

    // 3. Build color pairs + solution map
    final solution = <Color, List<(int, int)>>{};
    final colorPairs = <ColorPair>[];
    int offset = 0;

    for (int i = 0; i < numColors; i++) {
      final color = palette[i % palette.length];
      final segment = fullPath.sublist(offset, offset + segmentLengths[i]);
      offset += segmentLengths[i];

      solution[color] = segment;
      colorPairs.add(ColorPair(
        color: color,
        start: Endpoint(segment.first.$1, segment.first.$2),
        end: Endpoint(segment.last.$1, segment.last.$2),
      ));
    }

    return (
      level: Level(id: id, gridSize: gridSize, colorPairs: colorPairs),
      solution: solution,
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  RANDOM HAMILTONIAN PATH  (Warnsdorff's rule)
  // ──────────────────────────────────────────────────────────────

  /// Try to build a Hamiltonian path from a random starting cell.
  /// Returns null if the heuristic gets stuck before visiting all cells.
  static List<(int, int)>? _tryHamiltonianPath(int size, Random rng) {
    final total = size * size;
    final visited = List.generate(size, (_) => List.filled(size, false));
    final path = <(int, int)>[];

    // Random starting cell
    final sr = rng.nextInt(size);
    final sc = rng.nextInt(size);
    path.add((sr, sc));
    visited[sr][sc] = true;

    while (path.length < total) {
      final (cr, cc) = path.last;
      final neighbors = <(int, int)>[];

      for (final (dr, dc) in _dirs) {
        final nr = cr + dr;
        final nc = cc + dc;
        if (nr >= 0 && nr < size && nc >= 0 && nc < size && !visited[nr][nc]) {
          neighbors.add((nr, nc));
        }
      }

      if (neighbors.isEmpty) return null; // stuck

      // Warnsdorff: pick the neighbor with the FEWEST onward moves.
      // Shuffle first so ties are broken randomly.
      neighbors.shuffle(rng);
      neighbors.sort((a, b) {
        return _countUnvisited(a.$1, a.$2, size, visited)
            .compareTo(_countUnvisited(b.$1, b.$2, size, visited));
      });

      final next = neighbors.first;
      path.add(next);
      visited[next.$1][next.$2] = true;
    }

    return path;
  }

  /// Count unvisited orthogonal neighbors of (r,c).
  static int _countUnvisited(
      int r, int c, int size, List<List<bool>> visited) {
    int count = 0;
    for (final (dr, dc) in _dirs) {
      final nr = r + dr;
      final nc = c + dc;
      if (nr >= 0 && nr < size && nc >= 0 && nc < size && !visited[nr][nc]) {
        count++;
      }
    }
    return count;
  }

  // ──────────────────────────────────────────────────────────────
  //  SEGMENT SPLITTING
  // ──────────────────────────────────────────────────────────────

  /// Split [totalCells] into [numSegments] lengths.
  ///
  /// At low difficulty: segments are roughly equal.
  /// At high difficulty: segments vary wildly — some are 2 cells,
  /// others are very long, making the puzzle much harder.
  static List<int> _splitSegments({
    required int totalCells,
    required int numSegments,
    required double difficulty,
    required Random rng,
  }) {
    final minLen = 2;
    final lengths = List.filled(numSegments, minLen);
    var remaining = totalCells - numSegments * minLen;

    if (difficulty < 0.3) {
      // Easy: distribute evenly with small random perturbation
      final base = remaining ~/ numSegments;
      var leftover = remaining - base * numSegments;
      for (int i = 0; i < numSegments; i++) {
        lengths[i] += base;
        if (leftover > 0) {
          lengths[i]++;
          leftover--;
        }
      }
      // Small shuffle: swap 1-2 cells between random pairs
      for (int i = 0; i < numSegments ~/ 2; i++) {
        final a = rng.nextInt(numSegments);
        final b = rng.nextInt(numSegments);
        if (a != b && lengths[a] > minLen) {
          lengths[a]--;
          lengths[b]++;
        }
      }
    } else if (difficulty < 0.7) {
      // Medium: random distribution
      while (remaining > 0) {
        final idx = rng.nextInt(numSegments);
        final give = min(remaining, 1 + rng.nextInt(4));
        lengths[idx] += give;
        remaining -= give;
      }
    } else {
      // Hard: create extreme variation
      // Give most extra cells to a few random segments
      final favorites = <int>{};
      final numFav = max(1, numSegments ~/ 3);
      while (favorites.length < numFav) {
        favorites.add(rng.nextInt(numSegments));
      }

      while (remaining > 0) {
        int idx;
        if (rng.nextDouble() < 0.75 && favorites.isNotEmpty) {
          // 75% chance: give to a favorite (creates long paths)
          idx = favorites.elementAt(rng.nextInt(favorites.length));
        } else {
          idx = rng.nextInt(numSegments);
        }
        final give = min(remaining, 1 + rng.nextInt(6));
        lengths[idx] += give;
        remaining -= give;
      }
    }

    return lengths;
  }

  // ──────────────────────────────────────────────────────────────
  //  FALLBACK: simple horizontal snake
  // ──────────────────────────────────────────────────────────────

  static List<(int, int)> _horizontalSnake(int size) {
    final path = <(int, int)>[];
    for (int r = 0; r < size; r++) {
      if (r.isEven) {
        for (int c = 0; c < size; c++) {
          path.add((r, c));
        }
      } else {
        for (int c = size - 1; c >= 0; c--) {
          path.add((r, c));
        }
      }
    }
    return path;
  }
}
