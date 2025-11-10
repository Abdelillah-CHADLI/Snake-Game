import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'position.dart';
import 'direction.dart';
import 'snake.dart';

class GameController extends ChangeNotifier {
  final int rows;
  final int cols;
  Duration speed;

  late Snake snake;
  late Position food;
  int score = 0;
  bool running = false;
  bool _gameOver = false;

  Timer? _timer;
  final Random _rng = Random();

  GameController({this.rows = 20, this.cols = 20, this.speed = const Duration(milliseconds: 200)}) {
    reset();
  }

  bool get isGameOver => _gameOver;

  void reset() {
    _timer?.cancel();
    score = 0;
    _gameOver = false;
    running = false;
    final startX = cols ~/ 2;
    final startY = rows ~/ 2;
    snake = Snake(
      initialBody: [
        Position(startX, startY),
        Position(startX - 1, startY),
        Position(startX - 2, startY),
      ],
      direction: Direction.right,
    );
    _spawnFood();
    notifyListeners();
  }

  void start() {
    if (running || _gameOver) return;
    running = true;
    _timer = Timer.periodic(speed, (_) => _tick());
    notifyListeners();
  }

  void pause() {
    running = false;
    _timer?.cancel();
    notifyListeners();
  }

  void setDirection(Direction d) {
    snake.setDirection(d);
  }

  void _tick() {
    if (!running) return;
    final next = _nextHeadPosition();

    // Check wall collision
    if (next.x < 0 || next.x >= cols || next.y < 0 || next.y >= rows) {
      _endGame();
      return;
    }

    // Move snake
    snake.move(next);

    // Check self collision
    if (snake.hitsSelf()) {
      _endGame();
      return;
    }

    // Check food
    if (snake.head == food) {
      snake.grow();
      score += 1;
      _spawnFood();
    }

    notifyListeners();
  }

  Position _nextHeadPosition() {
    final offset = snake.direction.offset();
    return Position(snake.head.x + offset.x, snake.head.y + offset.y);
  }

  void _spawnFood() {
    Position p;
    do {
      p = Position(_rng.nextInt(cols), _rng.nextInt(rows));
    } while (snake.contains(p));
    food = p;
  }

  void _endGame() {
    _timer?.cancel();
    _gameOver = true;
    running = false;
    notifyListeners();
  }
}
