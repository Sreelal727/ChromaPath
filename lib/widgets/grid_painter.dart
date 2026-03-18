import 'package:flutter/material.dart';

import '../models/game_state.dart';

class GridPainter extends CustomPainter {
  final GameState state;
  final double cellSize;

  GridPainter({required this.state, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final gridSize = state.level.gridSize;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF2A2A4A)
      ..strokeWidth = 1.0;

    for (int i = 1; i < gridSize; i++) {
      final pos = i * cellSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), gridPaint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), gridPaint);
    }

    // Draw filled cells (path backgrounds)
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        final cell = state.grid[r][c];
        if (cell.color != null && !cell.isEndpoint) {
          final rect = Rect.fromLTWH(
            c * cellSize + 2,
            r * cellSize + 2,
            cellSize - 4,
            cellSize - 4,
          );
          final paint = Paint()
            ..color = cell.color!.withAlpha(64)
            ..style = PaintingStyle.fill;
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            paint,
          );
        }
      }
    }

    // Draw path lines
    for (final entry in state.paths.entries) {
      final color = entry.key;
      final path = entry.value;
      if (path.length < 2) continue;

      final pathPaint = Paint()
        ..color = color
        ..strokeWidth = cellSize * 0.3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final linePath = Path();
      final first = path.first;
      linePath.moveTo(
        first.$2 * cellSize + cellSize / 2,
        first.$1 * cellSize + cellSize / 2,
      );

      for (int i = 1; i < path.length; i++) {
        final point = path[i];
        linePath.lineTo(
          point.$2 * cellSize + cellSize / 2,
          point.$1 * cellSize + cellSize / 2,
        );
      }

      // Draw glow
      final glowPaint = Paint()
        ..color = color.withAlpha(51)
        ..strokeWidth = cellSize * 0.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(linePath, glowPaint);

      // Draw main path
      canvas.drawPath(linePath, pathPaint);
    }

    // Draw endpoints
    for (final pair in state.level.colorPairs) {
      _drawEndpoint(canvas, pair.start.row, pair.start.col, pair.color);
      _drawEndpoint(canvas, pair.end.row, pair.end.col, pair.color);
    }
  }

  void _drawEndpoint(Canvas canvas, int row, int col, Color color) {
    final center = Offset(
      col * cellSize + cellSize / 2,
      row * cellSize + cellSize / 2,
    );
    final radius = cellSize * 0.32;

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withAlpha(77)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, radius + 4, glowPaint);

    // Main circle
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);

    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(64)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      center - Offset(radius * 0.2, radius * 0.2),
      radius * 0.4,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
