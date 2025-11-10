// Minimal Flutter entry and route to the game screen.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/game/game_controller.dart';
import 'src/ui/game_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snake Game')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (_) => GameController(),
                child: const GameScreen(),
              ),
            ),
          ),
          child: const Text('Start'),
        ),
      ),
    );
  }
}
