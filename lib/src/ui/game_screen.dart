import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_controller.dart';
import 'game_board.dart';
import '../game/direction.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Offset? _dragStart;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final dx = details.delta.dx;
    if (dx.abs() < 6) return;
    final controller = context.read<GameController>();
    if (dx > 0) {
      controller.setDirection(Direction.right);
    } else {
      controller.setDirection(Direction.left);
    }
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final dy = details.delta.dy;
    if (dy.abs() < 6) return;
    final controller = context.read<GameController>();
    if (dy > 0) {
      controller.setDirection(Direction.down);
    } else {
      controller.setDirection(Direction.up);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Play')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Score: ${controller.score}'),
                Row(children: [
                  IconButton(
                    icon: Icon(controller.running ? Icons.pause : Icons.play_arrow),
                    onPressed: () => controller.running ? controller.pause() : controller.start(),
                    tooltip: controller.running ? 'Pause' : 'Start',
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: controller.reset,
                    tooltip: 'Restart',
                  ),
                ])
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: _onHorizontalDragUpdate,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.cols / controller.rows,
                  child: GameBoard(controller: controller),
                ),
              ),
            ),
          ),
          if (controller.isGameOver)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Game Over — Score: ${controller.score}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
