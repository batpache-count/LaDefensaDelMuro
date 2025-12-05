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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C1B10), // Dark brown
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFC9A348), // Gold
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nivel $level',
                  style: const TextStyle(
                    fontFamily: 'Medieval',
                    fontSize: 32,
                    color: Color(0xFFC9A348), // Gold
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 2.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  '¿Estás listo para la batalla?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Medieval',
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Play Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => GameScreen(level: level)),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.greenAccent),
                        ),
                      ),
                      child: const Text(
                        '¡Al Ataque!',
                        style: TextStyle(
                          fontFamily: 'Medieval',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red[900],
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                      ),
                      child: const Text(
                        'En otro momento',
                        style: TextStyle(
                          fontFamily: 'Medieval',
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      backgroundColor: Colors.black,
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
    // Seleccionar imagen según el nivel
    String imagePath;
    switch (level) {
      case 1:
        imagePath = 'assets/botones/Boton_1.png';
        break;
      case 2:
        imagePath = 'assets/botones/Boton_2.png';
        break;
      case 3:
        imagePath = 'assets/botones/Boton_3.png';
        break;
      default:
        imagePath = 'assets/botones/Boton_1.png';
    }

    return GestureDetector(
      onTap: unlocked ? onTap : null,
      child: Opacity(
        opacity: unlocked ? 1.0 : 0.4, // Bloqueados se ven apagados
        child: Image.asset(imagePath, width: 120, height: 120),
      ),
    );
  }
}
