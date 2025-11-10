import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Focus node to capture keyboard input (arrow keys/WASD if desired)
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Request focus after the first frame so the RawKeyboardListener receives events
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, RawKeyEvent event) {
    // Only handle key down to avoid duplicate handling on key up
    if (event is! RawKeyDownEvent) return KeyEventResult.ignored;
    final controller = context.read<GameController>();
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      controller.setDirection(Direction.up);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      controller.setDirection(Direction.down);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      controller.setDirection(Direction.left);
      return KeyEventResult.handled;
    } else if (key == LogicalKeyboardKey.arrowRight) {
      controller.setDirection(Direction.right);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

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
                Row(children: [
                  Text('Score: ${controller.score}'),
                  const SizedBox(width: 12),
                  Text('High: ${controller.highScore}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
                Row(children: [
                  DropdownButton<String>(
                    value: controller.difficulty,
                    items: const [
                      DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                      DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                    ],
                    onChanged: (v) {
                      if (v != null) controller.setDifficulty(v);
                    },
                  ),
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
            child: Focus(
              focusNode: _focusNode,
              onKey: _handleKey,
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
