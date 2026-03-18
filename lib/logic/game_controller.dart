import 'dart:ui';

import '../models/game_state.dart';
import '../models/level.dart';

class GameController {
  GameState state;

  GameController(Level level) : state = GameState.fromLevel(level);

  void reset() {
    state = GameState.fromLevel(state.level);
  }

  /// Start drawing from an endpoint or continue a path
  void onCellDown(int row, int col) {
    final cell = state.grid[row][col];
    if (cell.isEndpoint && cell.color != null) {
      final color = cell.color!;
      // Clear the existing path for this color
      _clearPath(color);
      // Start a new path from this endpoint
      final newPaths = Map<Color, List<(int, int)>>.from(state.paths);
      newPaths[color] = [(row, col)];
      state = state.copyWith(activeColor: color, paths: newPaths);
      _rebuildGrid();
    }
  }

  /// Extend the active path to an adjacent cell
  void onCellEnter(int row, int col) {
    final activeColor = state.activeColor;
    if (activeColor == null) return;

    final path = state.paths[activeColor];
    if (path == null || path.isEmpty) return;

    final (lastRow, lastCol) = path.last;

    // Must be adjacent (not diagonal)
    if ((row - lastRow).abs() + (col - lastCol).abs() != 1) return;

    // Check if backtracking (going back to previous cell)
    if (path.length >= 2 && path[path.length - 2] == (row, col)) {
      final newPaths = Map<Color, List<(int, int)>>.from(state.paths);
      newPaths[activeColor] = List.from(path)..removeLast();
      state = state.copyWith(paths: newPaths);
      _rebuildGrid();
      return;
    }

    // Don't revisit cells already in this path
    if (path.contains((row, col))) return;

    final targetCell = state.grid[row][col];

    // If the target cell is the OTHER endpoint of the same color, connect!
    if (targetCell.isEndpoint && targetCell.color == activeColor) {
      final newPaths = Map<Color, List<(int, int)>>.from(state.paths);
      newPaths[activeColor] = List.from(path)..add((row, col));
      state = state.copyWith(paths: newPaths);
      _rebuildGrid();
      _checkSolved();
      return;
    }

    // If the cell is an endpoint of a different color, block
    if (targetCell.isEndpoint && targetCell.color != activeColor) return;

    // If the cell belongs to another path, clear that path
    if (targetCell.color != null && targetCell.color != activeColor) {
      _clearPath(targetCell.color!);
    }

    // Extend path
    final newPaths = Map<Color, List<(int, int)>>.from(state.paths);
    newPaths[activeColor] = List.from(path)..add((row, col));
    state = state.copyWith(paths: newPaths);
    _rebuildGrid();
  }

  /// End the current drawing action
  void onCellUp() {
    if (state.activeColor != null) {
      state = state.copyWith(clearActiveColor: true);
    }
  }

  void _clearPath(Color color) {
    final newPaths = Map<Color, List<(int, int)>>.from(state.paths);
    newPaths[color] = [];
    state = state.copyWith(paths: newPaths);
    _rebuildGrid();
  }

  void _rebuildGrid() {
    final size = state.level.gridSize;
    final grid = List.generate(
      size,
      (_) => List.generate(size, (_) => const CellState()),
    );

    // Place endpoints
    for (final pair in state.level.colorPairs) {
      grid[pair.start.row][pair.start.col] = CellState(
        color: pair.color,
        isEndpoint: true,
      );
      grid[pair.end.row][pair.end.col] = CellState(
        color: pair.color,
        isEndpoint: true,
      );
    }

    // Place paths
    for (final entry in state.paths.entries) {
      for (final (r, c) in entry.value) {
        if (!grid[r][c].isEndpoint) {
          grid[r][c] = CellState(color: entry.key);
        }
      }
    }

    state = state.copyWith(grid: grid);
  }

  void _checkSolved() {
    final size = state.level.gridSize;

    // All cells must be filled
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (state.grid[r][c].color == null) return;
      }
    }

    // All paths must connect both endpoints
    for (final pair in state.level.colorPairs) {
      final path = state.paths[pair.color];
      if (path == null || path.isEmpty) return;
      if (path.first != (pair.start.row, pair.start.col) &&
          path.first != (pair.end.row, pair.end.col)) return;
      if (path.last != (pair.start.row, pair.start.col) &&
          path.last != (pair.end.row, pair.end.col)) return;
    }

    state = state.copyWith(isSolved: true, clearActiveColor: true);
  }

  /// Apply a full solution path for a given color (used by hint system).
  void applyPath(Color color, List<(int, int)> solutionPath) {
    // First clear any cells occupied by this color's current path
    _clearPath(color);
    // Also clear any other paths that overlap with the solution path
    for (final cell in solutionPath) {
      for (final entry in state.paths.entries) {
        if (entry.key != color && entry.value.contains(cell)) {
          _clearPath(entry.key);
        }
      }
    }
    // Set the full solution path
    final newPaths = Map<Color, List<(int, int)>>.from(state.paths);
    newPaths[color] = List.from(solutionPath);
    state = state.copyWith(paths: newPaths, clearActiveColor: true);
    _rebuildGrid();
    _checkSolved();
  }

  int get filledCells {
    int count = 0;
    for (final row in state.grid) {
      for (final cell in row) {
        if (cell.color != null) count++;
      }
    }
    return count;
  }

  int get flowsCompleted {
    int count = 0;
    for (final pair in state.level.colorPairs) {
      final path = state.paths[pair.color];
      if (path == null || path.length < 2) continue;
      final start = (pair.start.row, pair.start.col);
      final end = (pair.end.row, pair.end.col);
      if ((path.first == start && path.last == end) ||
          (path.first == end && path.last == start)) {
        count++;
      }
    }
    return count;
  }
}
