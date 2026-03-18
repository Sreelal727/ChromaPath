// Run with: dart run tool/validate_levels.dart
// Validates every level's solution covers all cells exactly once,
// all paths are adjacency-connected, and there are no overlaps.

import '../lib/data/levels.dart';

void main() {
  bool allPassed = true;

  for (final level in allLevels) {
    final solution = allSolutions[level.id];
    if (solution == null) {
      print('Level ${level.id}: FAIL — no solution found');
      allPassed = false;
      continue;
    }

    final gridSize = level.gridSize;
    final totalCells = gridSize * gridSize;
    final allCells = <(int, int)>{};
    final errors = <String>[];

    for (final entry in solution.entries) {
      final path = entry.value;

      // Check adjacency
      for (int i = 1; i < path.length; i++) {
        final prev = path[i - 1];
        final curr = path[i];
        final dist = (curr.$1 - prev.$1).abs() + (curr.$2 - prev.$2).abs();
        if (dist != 1) {
          errors.add('  Color ${entry.key}: non-adjacent at $i: $prev -> $curr');
        }
      }

      // Check bounds
      for (final cell in path) {
        if (cell.$1 < 0 || cell.$1 >= gridSize ||
            cell.$2 < 0 || cell.$2 >= gridSize) {
          errors.add('  Color ${entry.key}: out of bounds $cell');
        }
      }

      // Check path has at least 2 cells
      if (path.length < 2) {
        errors.add('  Color ${entry.key}: path too short (${path.length})');
      }

      // Check duplicates within path
      final pathSet = path.toSet();
      if (pathSet.length != path.length) {
        errors.add('  Color ${entry.key}: has duplicates');
      }

      // Check overlap
      for (final cell in path) {
        if (allCells.contains(cell)) {
          errors.add('  Color ${entry.key}: cell $cell overlaps');
        }
      }
      allCells.addAll(pathSet);
    }

    // Check total coverage
    if (allCells.length != totalCells) {
      final missing = <(int, int)>[];
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (!allCells.contains((r, c))) missing.add((r, c));
        }
      }
      errors.add('  Coverage: ${allCells.length}/$totalCells. Missing: $missing');
    }

    // Check endpoint consistency
    for (final pair in level.colorPairs) {
      final path = solution[pair.color];
      if (path == null) {
        errors.add('  Color ${pair.color}: missing from solution');
        continue;
      }
      final pStart = (pair.start.row, pair.start.col);
      final pEnd = (pair.end.row, pair.end.col);
      if (path.first != pStart || path.last != pEnd) {
        errors.add('  Color ${pair.color}: endpoints mismatch '
            'level=${pStart}->${pEnd} vs solution=${path.first}->${path.last}');
      }
    }

    if (errors.isEmpty) {
      print('Level ${level.id} (${gridSize}x$gridSize, '
          '${level.colorPairs.length} colors): PASS');
    } else {
      print('Level ${level.id} (${gridSize}x$gridSize): FAIL');
      for (final e in errors) print(e);
      allPassed = false;
    }
  }

  print('');
  if (allPassed) {
    print('=== ALL ${allLevels.length} LEVELS PASSED ===');
  } else {
    print('=== SOME LEVELS FAILED ===');
  }
}
