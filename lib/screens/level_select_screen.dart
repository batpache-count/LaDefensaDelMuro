import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Future<void> _showConfirmationDialog(BuildContext context, int level) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Jugar Nivel?'),
          content: Text('¿Estás seguro de que quieres jugar el nivel $level?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Regresar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Jugar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameScreen(level: level)),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _handleLevelTap(int level, bool unlocked) {
    if (unlocked) {
      if (level == 2) {
        // Nivel 2 no hace nada
        return;
      }
      _showConfirmationDialog(context, level);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          final unlockedLevels = gameState.unlockedLevels;
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/fondos/level_select_bg.png",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 650,
                left: 200,
                child: LevelButton(
                  level: 1,
                  unlocked: unlockedLevels >= 1,
                  onTap: () => _handleLevelTap(1, unlockedLevels >= 1),
                ),
              ),
              Positioned(
                top: 415,
                left: 10,
                child: LevelButton(
                  level: 2,
                  unlocked: unlockedLevels >= 2,
                  onTap: () => _handleLevelTap(2, unlockedLevels >= 2),
                ),
              ),
              Positioned(
                top: 235,
                left: 155,
                child: LevelButton(
                  level: 3,
                  unlocked: unlockedLevels >= 3,
                  onTap: () => _handleLevelTap(3, unlockedLevels >= 3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LevelButton extends StatelessWidget {
  final int level;
  final bool unlocked;
  final VoidCallback onTap;

  const LevelButton({
    super.key,
    required this.level,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(
              unlocked
                  ? 'assets/botones/PlayButton.gif'
                  : 'assets/botones/PlayButton.gif',
            ),
            fit: BoxFit.cover,
            colorFilter: unlocked
                ? null
                : const ColorFilter.matrix(<double>[
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      1, 0,
                  ]),
          ),
          boxShadow: [
            BoxShadow(
              color: unlocked
                  ? Colors.amber.withOpacity(0.7)
                  : Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: unlocked
              ? Text(
                  'Nivel $level',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                )
              : const Icon(Icons.lock, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}
