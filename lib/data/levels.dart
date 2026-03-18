import 'dart:ui';

import '../models/level.dart';

const _red = Color(0xFFE53935);
const _blue = Color(0xFF1E88E5);
const _green = Color(0xFF43A047);
const _orange = Color(0xFFFB8C00);
const _purple = Color(0xFF8E24AA);
const _yellow = Color(0xFFFDD835);
const _teal = Color(0xFF00897B);
const _pink = Color(0xFFD81B60);
const _maroon = Color(0xFF6D4C41);

final List<Level> allLevels = [
  // === 5x5 Levels (1-7) ===
  Level(id: 1, gridSize: 5, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(4, 4)),
    ColorPair(color: _blue, start: const Endpoint(0, 4), end: const Endpoint(4, 0)),
    ColorPair(color: _green, start: const Endpoint(2, 0), end: const Endpoint(2, 4)),
  ]),
  Level(id: 2, gridSize: 5, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 1), end: const Endpoint(3, 1)),
    ColorPair(color: _blue, start: const Endpoint(0, 3), end: const Endpoint(3, 3)),
    ColorPair(color: _green, start: const Endpoint(1, 0), end: const Endpoint(1, 4)),
    ColorPair(color: _orange, start: const Endpoint(4, 0), end: const Endpoint(4, 4)),
  ]),
  Level(id: 3, gridSize: 5, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(2, 2)),
    ColorPair(color: _blue, start: const Endpoint(0, 4), end: const Endpoint(2, 3)),
    ColorPair(color: _green, start: const Endpoint(4, 0), end: const Endpoint(3, 3)),
    ColorPair(color: _orange, start: const Endpoint(4, 4), end: const Endpoint(3, 1)),
  ]),
  Level(id: 4, gridSize: 5, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(4, 2)),
    ColorPair(color: _blue, start: const Endpoint(0, 2), end: const Endpoint(4, 4)),
    ColorPair(color: _green, start: const Endpoint(0, 4), end: const Endpoint(4, 0)),
    ColorPair(color: _orange, start: const Endpoint(2, 1), end: const Endpoint(2, 3)),
  ]),
  Level(id: 5, gridSize: 5, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(3, 0)),
    ColorPair(color: _blue, start: const Endpoint(0, 2), end: const Endpoint(3, 4)),
    ColorPair(color: _green, start: const Endpoint(1, 4), end: const Endpoint(4, 4)),
    ColorPair(color: _orange, start: const Endpoint(4, 0), end: const Endpoint(4, 2)),
    ColorPair(color: _purple, start: const Endpoint(1, 1), end: const Endpoint(2, 3)),
  ]),
  Level(id: 6, gridSize: 5, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 1), end: const Endpoint(4, 3)),
    ColorPair(color: _blue, start: const Endpoint(0, 3), end: const Endpoint(4, 1)),
    ColorPair(color: _green, start: const Endpoint(0, 0), end: const Endpoint(2, 0)),
    ColorPair(color: _orange, start: const Endpoint(2, 4), end: const Endpoint(4, 4)),
    ColorPair(color: _purple, start: const Endpoint(4, 0), end: const Endpoint(3, 2)),
  ]),
  Level(id: 7, gridSize: 5, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(1, 3)),
    ColorPair(color: _blue, start: const Endpoint(0, 4), end: const Endpoint(3, 1)),
    ColorPair(color: _green, start: const Endpoint(2, 0), end: const Endpoint(4, 2)),
    ColorPair(color: _orange, start: const Endpoint(3, 3), end: const Endpoint(4, 4)),
    ColorPair(color: _purple, start: const Endpoint(4, 0), end: const Endpoint(1, 1)),
  ]),

  // === 6x6 Levels (8-14) ===
  Level(id: 8, gridSize: 6, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(5, 5)),
    ColorPair(color: _blue, start: const Endpoint(0, 5), end: const Endpoint(5, 0)),
    ColorPair(color: _green, start: const Endpoint(0, 2), end: const Endpoint(5, 3)),
    ColorPair(color: _orange, start: const Endpoint(2, 0), end: const Endpoint(2, 5)),
  ]),
  Level(id: 9, gridSize: 6, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(3, 3)),
    ColorPair(color: _blue, start: const Endpoint(0, 5), end: const Endpoint(5, 0)),
    ColorPair(color: _green, start: const Endpoint(1, 2), end: const Endpoint(4, 5)),
    ColorPair(color: _orange, start: const Endpoint(5, 1), end: const Endpoint(5, 4)),
    ColorPair(color: _purple, start: const Endpoint(3, 0), end: const Endpoint(1, 4)),
  ]),
  Level(id: 10, gridSize: 6, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 1), end: const Endpoint(4, 1)),
    ColorPair(color: _blue, start: const Endpoint(0, 4), end: const Endpoint(4, 4)),
    ColorPair(color: _green, start: const Endpoint(1, 0), end: const Endpoint(1, 5)),
    ColorPair(color: _orange, start: const Endpoint(5, 0), end: const Endpoint(5, 5)),
    ColorPair(color: _purple, start: const Endpoint(2, 2), end: const Endpoint(2, 3)),
  ]),
  Level(id: 11, gridSize: 6, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(5, 2)),
    ColorPair(color: _blue, start: const Endpoint(0, 3), end: const Endpoint(3, 0)),
    ColorPair(color: _green, start: const Endpoint(0, 5), end: const Endpoint(5, 5)),
    ColorPair(color: _orange, start: const Endpoint(2, 1), end: const Endpoint(5, 0)),
    ColorPair(color: _purple, start: const Endpoint(2, 4), end: const Endpoint(4, 3)),
    ColorPair(color: _yellow, start: const Endpoint(4, 1), end: const Endpoint(3, 4)),
  ]),
  Level(id: 12, gridSize: 6, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(2, 3)),
    ColorPair(color: _blue, start: const Endpoint(0, 5), end: const Endpoint(3, 2)),
    ColorPair(color: _green, start: const Endpoint(1, 1), end: const Endpoint(5, 5)),
    ColorPair(color: _orange, start: const Endpoint(3, 0), end: const Endpoint(5, 0)),
    ColorPair(color: _purple, start: const Endpoint(4, 3), end: const Endpoint(4, 5)),
    ColorPair(color: _yellow, start: const Endpoint(1, 4), end: const Endpoint(5, 2)),
  ]),
  Level(id: 13, gridSize: 6, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 2), end: const Endpoint(3, 5)),
    ColorPair(color: _blue, start: const Endpoint(0, 0), end: const Endpoint(5, 4)),
    ColorPair(color: _green, start: const Endpoint(1, 1), end: const Endpoint(4, 0)),
    ColorPair(color: _orange, start: const Endpoint(2, 3), end: const Endpoint(5, 0)),
    ColorPair(color: _purple, start: const Endpoint(0, 5), end: const Endpoint(5, 5)),
    ColorPair(color: _yellow, start: const Endpoint(3, 1), end: const Endpoint(5, 2)),
  ]),
  Level(id: 14, gridSize: 6, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(4, 4)),
    ColorPair(color: _blue, start: const Endpoint(0, 3), end: const Endpoint(5, 1)),
    ColorPair(color: _green, start: const Endpoint(1, 5), end: const Endpoint(5, 5)),
    ColorPair(color: _orange, start: const Endpoint(2, 0), end: const Endpoint(3, 2)),
    ColorPair(color: _purple, start: const Endpoint(5, 0), end: const Endpoint(3, 4)),
    ColorPair(color: _yellow, start: const Endpoint(0, 5), end: const Endpoint(2, 2)),
  ]),

  // === 7x7 Levels (15-20) ===
  Level(id: 15, gridSize: 7, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(6, 6)),
    ColorPair(color: _blue, start: const Endpoint(0, 6), end: const Endpoint(6, 0)),
    ColorPair(color: _green, start: const Endpoint(0, 3), end: const Endpoint(6, 3)),
    ColorPair(color: _orange, start: const Endpoint(3, 0), end: const Endpoint(3, 6)),
    ColorPair(color: _purple, start: const Endpoint(1, 1), end: const Endpoint(5, 5)),
  ]),
  Level(id: 16, gridSize: 7, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(4, 3)),
    ColorPair(color: _blue, start: const Endpoint(0, 6), end: const Endpoint(6, 0)),
    ColorPair(color: _green, start: const Endpoint(1, 2), end: const Endpoint(5, 6)),
    ColorPair(color: _orange, start: const Endpoint(2, 0), end: const Endpoint(6, 4)),
    ColorPair(color: _purple, start: const Endpoint(3, 5), end: const Endpoint(6, 2)),
    ColorPair(color: _yellow, start: const Endpoint(0, 4), end: const Endpoint(6, 6)),
  ]),
  Level(id: 17, gridSize: 7, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 1), end: const Endpoint(6, 5)),
    ColorPair(color: _blue, start: const Endpoint(0, 5), end: const Endpoint(6, 1)),
    ColorPair(color: _green, start: const Endpoint(1, 0), end: const Endpoint(5, 0)),
    ColorPair(color: _orange, start: const Endpoint(1, 6), end: const Endpoint(5, 6)),
    ColorPair(color: _purple, start: const Endpoint(2, 2), end: const Endpoint(4, 4)),
    ColorPair(color: _yellow, start: const Endpoint(3, 1), end: const Endpoint(3, 5)),
    ColorPair(color: _teal, start: const Endpoint(0, 0), end: const Endpoint(6, 6)),
  ]),
  Level(id: 18, gridSize: 7, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(3, 3)),
    ColorPair(color: _blue, start: const Endpoint(0, 6), end: const Endpoint(6, 0)),
    ColorPair(color: _green, start: const Endpoint(1, 2), end: const Endpoint(6, 6)),
    ColorPair(color: _orange, start: const Endpoint(2, 4), end: const Endpoint(5, 1)),
    ColorPair(color: _purple, start: const Endpoint(0, 3), end: const Endpoint(4, 6)),
    ColorPair(color: _yellow, start: const Endpoint(4, 0), end: const Endpoint(6, 3)),
    ColorPair(color: _teal, start: const Endpoint(5, 4), end: const Endpoint(2, 0)),
  ]),
  Level(id: 19, gridSize: 7, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(6, 2)),
    ColorPair(color: _blue, start: const Endpoint(0, 4), end: const Endpoint(6, 6)),
    ColorPair(color: _green, start: const Endpoint(1, 1), end: const Endpoint(4, 5)),
    ColorPair(color: _orange, start: const Endpoint(1, 6), end: const Endpoint(5, 0)),
    ColorPair(color: _purple, start: const Endpoint(2, 3), end: const Endpoint(6, 0)),
    ColorPair(color: _yellow, start: const Endpoint(3, 0), end: const Endpoint(3, 6)),
    ColorPair(color: _teal, start: const Endpoint(0, 6), end: const Endpoint(5, 3)),
    ColorPair(color: _pink, start: const Endpoint(6, 4), end: const Endpoint(4, 2)),
  ]),
  Level(id: 20, gridSize: 7, colorPairs: [
    ColorPair(color: _red, start: const Endpoint(0, 0), end: const Endpoint(5, 5)),
    ColorPair(color: _blue, start: const Endpoint(0, 3), end: const Endpoint(6, 3)),
    ColorPair(color: _green, start: const Endpoint(0, 6), end: const Endpoint(6, 0)),
    ColorPair(color: _orange, start: const Endpoint(1, 1), end: const Endpoint(4, 4)),
    ColorPair(color: _purple, start: const Endpoint(2, 5), end: const Endpoint(6, 6)),
    ColorPair(color: _yellow, start: const Endpoint(3, 0), end: const Endpoint(5, 2)),
    ColorPair(color: _teal, start: const Endpoint(4, 0), end: const Endpoint(6, 4)),
    ColorPair(color: _pink, start: const Endpoint(1, 4), end: const Endpoint(5, 0)),
    ColorPair(color: _maroon, start: const Endpoint(2, 2), end: const Endpoint(4, 6)),
  ]),
];
