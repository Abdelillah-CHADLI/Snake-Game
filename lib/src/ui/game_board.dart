import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/position.dart';

class GameBoard extends StatelessWidget {
  final GameController controller;

  const GameBoard({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _GamePainter(
            rows: controller.rows,
            cols: controller.cols,
            snake: List.of(controller.snake.body),
            food: controller.food,
          ),
        );
      },
    );
  }
}

class _GamePainter extends CustomPainter {
  final int rows;
  final int cols;
  final List<Position> snake;
  final Position food;

  _GamePainter({required this.rows, required this.cols, required this.snake, required this.food});

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()..color = Colors.grey.shade300;
    final paintSnake = Paint()..color = Colors.green.shade700;
    final paintHead = Paint()..color = Colors.green.shade900;
    final paintFood = Paint()..color = Colors.redAccent;

    final cellW = size.width / cols;
    final cellH = size.height / rows;

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.grey.shade100);

    // Optional grid lines
    for (int c = 0; c <= cols; c++) {
      final x = c * cellW;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
    }
    for (int r = 0; r <= rows; r++) {
      final y = r * cellH;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // Draw food
    final fRect = Rect.fromLTWH(food.x * cellW, food.y * cellH, cellW, cellH).deflate(cellW * 0.08);
    canvas.drawRRect(RRect.fromRectAndRadius(fRect, const Radius.circular(4)), paintFood);

    // Draw snake body
    for (int i = 0; i < snake.length; i++) {
      final p = snake[i];
      final rect = Rect.fromLTWH(p.x * cellW, p.y * cellH, cellW, cellH).deflate(cellW * 0.06);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), i == 0 ? paintHead : paintSnake);
    }
  }

  @override
  bool shouldRepaint(covariant _GamePainter old) {
    return old.snake != snake || old.food != food;
  }
}
