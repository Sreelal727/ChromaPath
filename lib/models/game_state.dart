import 'dart:ui';

import 'level.dart';

class CellState {
  final Color? color;
  final bool isEndpoint;

  const CellState({this.color, this.isEndpoint = false});

  CellState copyWith({Color? color, bool? isEndpoint}) {
    return CellState(
      color: color ?? this.color,
      isEndpoint: isEndpoint ?? this.isEndpoint,
    );
  }
}

class GameState {
  final Level level;
  final List<List<CellState>> grid;
  final Map<Color, List<(int, int)>> paths;
  final Color? activeColor;
  final bool isSolved;

  GameState({
    required this.level,
    required this.grid,
    required this.paths,
    this.activeColor,
    this.isSolved = false,
  });

  factory GameState.fromLevel(Level level) {
    final grid = List.generate(
      level.gridSize,
      (_) => List.generate(
        level.gridSize,
        (_) => const CellState(),
      ),
    );

    final paths = <Color, List<(int, int)>>{};

    for (final pair in level.colorPairs) {
      grid[pair.start.row][pair.start.col] = CellState(
        color: pair.color,
        isEndpoint: true,
      );
      grid[pair.end.row][pair.end.col] = CellState(
        color: pair.color,
        isEndpoint: true,
      );
      paths[pair.color] = [];
    }

    return GameState(
      level: level,
      grid: grid,
      paths: paths,
    );
  }

  GameState copyWith({
    List<List<CellState>>? grid,
    Map<Color, List<(int, int)>>? paths,
    Color? activeColor,
    bool clearActiveColor = false,
    bool? isSolved,
  }) {
    return GameState(
      level: level,
      grid: grid ?? this.grid,
      paths: paths ?? this.paths,
      activeColor: clearActiveColor ? null : (activeColor ?? this.activeColor),
      isSolved: isSolved ?? this.isSolved,
    );
  }
}
