import 'dart:math';
import 'dart:ui';

import '../models/level.dart';

/// Generates provably solvable flow-puzzle levels.
///
/// Algorithm (guaranteed correct):
/// 1. Generate a space-filling path that visits every cell exactly once
///    using one of 4 patterns (horizontal snake, vertical snake,
///    clockwise spiral, counter-clockwise spiral).
/// 2. Split this single path into [numColors] segments of random lengths
///    (each segment ≥ 2 cells).
/// 3. Each segment becomes a color-pair; endpoints are first/last cell.
///
/// Because the full path is a single chain of adjacent cells covering the
/// entire grid, every segment is also a chain of adjacent cells, and the
/// union of all segments covers the grid with zero gaps or overlaps.
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

  /// Generate a level with its solution.
  static ({Level level, Map<Color, List<(int, int)>> solution}) generate({
    required int id,
    required int gridSize,
    required int numColors,
    required int seed,
  }) {
    final rng = Random(seed);
    final totalCells = gridSize * gridSize;

    assert(numColors >= 2);
    assert(numColors * 2 <= totalCells); // each color needs ≥ 2 cells

    // 1. Pick a random space-filling pattern
    final patternType = rng.nextInt(4);
    final fullPath = _generateFullPath(gridSize, patternType);

    assert(fullPath.length == totalCells);

    // 2. Split into segments
    final segmentLengths = _randomSegmentLengths(
      totalCells: totalCells,
      numSegments: numColors,
      rng: rng,
    );

    // 3. Build color pairs + solution
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

  /// Generate a full path visiting every cell exactly once.
  static List<(int, int)> _generateFullPath(int size, int pattern) {
    switch (pattern) {
      case 0:
        return _horizontalSnake(size);
      case 1:
        return _verticalSnake(size);
      case 2:
        return _spiralClockwise(size);
      case 3:
        return _spiralCounterClockwise(size);
      default:
        return _horizontalSnake(size);
    }
  }

  /// Rows left-right, right-left alternating.
  static List<(int, int)> _horizontalSnake(int size) {
    final path = <(int, int)>[];
    for (int r = 0; r < size; r++) {
      if (r.isEven) {
        for (int c = 0; c < size; c++) path.add((r, c));
      } else {
        for (int c = size - 1; c >= 0; c--) path.add((r, c));
      }
    }
    return path;
  }

  /// Columns top-bottom, bottom-top alternating.
  static List<(int, int)> _verticalSnake(int size) {
    final path = <(int, int)>[];
    for (int c = 0; c < size; c++) {
      if (c.isEven) {
        for (int r = 0; r < size; r++) path.add((r, c));
      } else {
        for (int r = size - 1; r >= 0; r--) path.add((r, c));
      }
    }
    return path;
  }

  /// Spiral inward clockwise.
  static List<(int, int)> _spiralClockwise(int size) {
    final path = <(int, int)>[];
    int top = 0, bottom = size - 1, left = 0, right = size - 1;

    while (top <= bottom && left <= right) {
      for (int c = left; c <= right; c++) path.add((top, c));
      top++;
      for (int r = top; r <= bottom; r++) path.add((r, right));
      right--;
      if (top <= bottom) {
        for (int c = right; c >= left; c--) path.add((bottom, c));
        bottom--;
      }
      if (left <= right) {
        for (int r = bottom; r >= top; r--) path.add((r, left));
        left++;
      }
    }
    return path;
  }

  /// Spiral inward counter-clockwise (reverse of clockwise).
  static List<(int, int)> _spiralCounterClockwise(int size) {
    return _spiralClockwise(size).reversed.toList();
  }

  /// Split [totalCells] into [numSegments] random lengths, each ≥ 2.
  static List<int> _randomSegmentLengths({
    required int totalCells,
    required int numSegments,
    required Random rng,
  }) {
    // Start with minimum of 2 per segment
    final lengths = List.filled(numSegments, 2);
    var remaining = totalCells - numSegments * 2;

    // Distribute remaining cells randomly
    while (remaining > 0) {
      final idx = rng.nextInt(numSegments);
      final give = min(remaining, 1 + rng.nextInt(3)); // give 1-3 extra cells
      lengths[idx] += give;
      remaining -= give;
    }

    return lengths;
  }
}
