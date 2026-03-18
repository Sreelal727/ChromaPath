import 'package:flutter_test/flutter_test.dart';
import 'package:chromapath/data/levels.dart';

void main() {
  test('All ${allLevels.length} levels have valid solutions', () {
    expect(allLevels.length, totalLevelCount);

    for (final level in allLevels) {
      final solution = allSolutions[level.id];
      expect(solution, isNotNull, reason: 'Level ${level.id} missing solution');

      final gridSize = level.gridSize;
      final totalCells = gridSize * gridSize;
      final allCells = <(int, int)>{};

      for (final entry in solution!.entries) {
        final path = entry.value;

        // Path has at least 2 cells
        expect(path.length, greaterThanOrEqualTo(2),
            reason: 'Level ${level.id}: path too short');

        // All steps adjacent
        for (int i = 1; i < path.length; i++) {
          final prev = path[i - 1];
          final curr = path[i];
          final dist =
              (curr.$1 - prev.$1).abs() + (curr.$2 - prev.$2).abs();
          expect(dist, 1,
              reason: 'Level ${level.id}: non-adjacent at $prev->$curr');
        }

        // All cells in bounds
        for (final (r, c) in path) {
          expect(r >= 0 && r < gridSize, true);
          expect(c >= 0 && c < gridSize, true);
        }

        // No duplicates within path
        expect(path.toSet().length, path.length,
            reason: 'Level ${level.id}: duplicate cells in path');

        // No overlap with other paths
        for (final cell in path) {
          expect(allCells.contains(cell), false,
              reason: 'Level ${level.id}: cell $cell overlaps');
          allCells.add(cell);
        }
      }

      // Total coverage
      expect(allCells.length, totalCells,
          reason: 'Level ${level.id}: covers ${allCells.length}/$totalCells');
    }
  });
}
