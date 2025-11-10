import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int highScore = 0;
  bool running = false;
  bool _gameOver = false;

  Timer? _timer;
  final Random _rng = Random();

  String difficulty = 'Normal';

  GameController({this.rows = 20, this.cols = 20, this.speed = const Duration(milliseconds: 200)}) {
    reset();
    _loadHighScore();
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
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(speed, (_) => _tick());
  }

  void pause() {
    running = false;
    _timer?.cancel();
    notifyListeners();
  }

  void setDirection(Direction d) {
    snake.setDirection(d);
  }

  void setDifficulty(String level) {
    difficulty = level;
    switch (level) {
      case 'Easy':
        speed = const Duration(milliseconds: 300);
        break;
      case 'Hard':
        speed = const Duration(milliseconds: 120);
        break;
      default:
        speed = const Duration(milliseconds: 200);
    }
    // If game is running, restart timer with new speed
    if (running) {
      _startTimer();
    }
    notifyListeners();
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
    // Persist high score if needed (fire-and-forget)
    if (score > highScore) {
      highScore = score;
      _saveHighScore();
    }
    notifyListeners();
  }

  Future<void> _loadHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      highScore = prefs.getInt('highScore') ?? 0;
      notifyListeners();
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> _saveHighScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', highScore);
    } catch (_) {
      // ignore persistence errors
    }
  }
}
