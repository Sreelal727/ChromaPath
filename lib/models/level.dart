import 'dart:ui';

class Endpoint {
  final int row;
  final int col;

  const Endpoint(this.row, this.col);
}

class ColorPair {
  final Color color;
  final Endpoint start;
  final Endpoint end;

  const ColorPair({
    required this.color,
    required this.start,
    required this.end,
  });
}

class Level {
  final int id;
  final int gridSize;
  final List<ColorPair> colorPairs;

  const Level({
    required this.id,
    required this.gridSize,
    required this.colorPairs,
  });

  int get totalCells => gridSize * gridSize;
}
