import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/levels.dart';
import '../logic/game_controller.dart';
import '../models/level.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/grid_painter.dart';

class GameScreen extends StatefulWidget {
  final Level level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameController _controller;
  late AnimationController _solveAnimController;
  bool _showSolveOverlay = false;

  @override
  void initState() {
    super.initState();
    _controller = GameController(widget.level);
    _solveAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _solveAnimController.dispose();
    super.dispose();
  }

  void _onSolved() async {
    await ProgressService.markCompleted(widget.level.id);
    setState(() => _showSolveOverlay = true);
    _solveAnimController.forward();
  }

  void _resetLevel() {
    setState(() {
      _controller.reset();
      _showSolveOverlay = false;
      _solveAnimController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = widget.level.gridSize;

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level.id}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetLevel,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatChip(
                  Icons.route_rounded,
                  'Flows: ${_controller.flowsCompleted}/${widget.level.colorPairs.length}',
                ),
                _buildStatChip(
                  Icons.grid_4x4_rounded,
                  'Cells: ${_controller.filledCells}/${widget.level.totalCells}',
                ),
                _buildGridSizeChip(),
              ],
            ),
          ),
          const Spacer(),
          // Game grid
          _buildGrid(gridSize),
          const Spacer(),
          // Color legend
          _buildColorLegend(),
          const SizedBox(height: 24),
          // Solve overlay
          if (_showSolveOverlay) _buildSolveOverlay(),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSizeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE94560).withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${widget.level.gridSize}×${widget.level.gridSize}',
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE94560),
        ),
      ),
    );
  }

  Widget _buildGrid(int gridSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = constraints.maxWidth - 32;
        final cellSize = maxSize / gridSize;
        final gridPixelSize = cellSize * gridSize;

        return Center(
          child: Container(
            width: gridPixelSize,
            height: gridPixelSize,
            decoration: BoxDecoration(
              color: AppTheme.gridBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.gridLine, width: 2),
            ),
            child: GestureDetector(
              onPanStart: (details) => _handlePan(details.localPosition, cellSize),
              onPanUpdate: (details) => _handlePanUpdate(details.localPosition, cellSize, gridPixelSize),
              onPanEnd: (_) => _handlePanEnd(),
              child: CustomPaint(
                painter: GridPainter(
                  state: _controller.state,
                  cellSize: cellSize,
                ),
                size: Size(gridPixelSize, gridPixelSize),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePan(Offset position, double cellSize) {
    final col = (position.dx / cellSize).floor();
    final row = (position.dy / cellSize).floor();
    final gridSize = widget.level.gridSize;
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      setState(() => _controller.onCellDown(row, col));
    }
  }

  void _handlePanUpdate(Offset position, double cellSize, double gridPixelSize) {
    if (position.dx < 0 || position.dy < 0 ||
        position.dx >= gridPixelSize || position.dy >= gridPixelSize) return;
    final col = (position.dx / cellSize).floor();
    final row = (position.dy / cellSize).floor();
    final gridSize = widget.level.gridSize;
    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      final prevState = _controller.state;
      _controller.onCellEnter(row, col);
      if (_controller.state != prevState) {
        setState(() {});
        if (_controller.state.isSolved) {
          _onSolved();
        }
      }
    }
  }

  void _handlePanEnd() {
    setState(() => _controller.onCellUp());
  }

  Widget _buildColorLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: widget.level.colorPairs.map((pair) {
          final isConnected = _isColorConnected(pair.color);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: pair.color.withAlpha(isConnected ? 255 : 128),
              shape: BoxShape.circle,
              border: Border.all(
                color: isConnected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              boxShadow: isConnected
                  ? [
                      BoxShadow(
                        color: pair.color.withAlpha(128),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: isConnected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          );
        }).toList(),
      ),
    );
  }

  bool _isColorConnected(Color color) {
    final pair = widget.level.colorPairs.firstWhere((p) => p.color == color);
    final path = _controller.state.paths[color];
    if (path == null || path.length < 2) return false;
    final start = (pair.start.row, pair.start.col);
    final end = (pair.end.row, pair.end.col);
    return (path.first == start && path.last == end) ||
        (path.first == end && path.last == start);
  }

  Widget _buildSolveOverlay() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Text(
            'Solved!',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF43A047),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scaleXY(begin: 0.5, end: 1.0),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Levels'),
              ),
              const SizedBox(width: 16),
              if (widget.level.id < 20)
                ElevatedButton.icon(
                  onPressed: _nextLevel,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                  ),
                ),
            ],
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }

  void _nextLevel() {
    final nextId = widget.level.id + 1;
    try {
      final nextLevel = allLevels.firstWhere((l) => l.id == nextId);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GameScreen(level: nextLevel),
        ),
      );
    } catch (_) {
      Navigator.pop(context);
    }
  }
}
