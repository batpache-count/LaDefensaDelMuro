import 'package:defensa_del_muro/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:provider/provider.dart';
import '../game_state.dart';
import 'game/my_game.dart';

class GameScreen extends StatelessWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final game = MyGame(level: level);
    final FirebaseService firebaseService = FirebaseService();

    return Scaffold(
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'Hud': (context, game) => MyGame.hudBuilder(context, game as MyGame),

          'Victory': (context, game) => Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1B10), // Dark brown
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFC9A348), width: 3), // Gold border
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
                  const Text(
                    "¡Victoria!",
                    style: TextStyle(
                      fontFamily: 'Medieval',
                      fontSize: 40,
                      color: Color(0xFFC9A348),
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
                  const SizedBox(height: 10),
                  const Text(
                    "El muro prevalece.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Medieval',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextButton(
                    onPressed: () {
                      final gameState = Provider.of<GameState>(context, listen: false);
                      gameState.setUnlockedLevels(level + 1);

                      if (gameState.isLoggedIn) {
                        firebaseService.savePlayerData(gameState.user!.uid, gameState.toJson());
                      }
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.greenAccent),
                      ),
                    ),
                    child: const Text(
                      "Continuar",
                      style: TextStyle(
                        fontFamily: 'Medieval',
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          'GameOver': (context, game) => Center(
            child: Container(
              width: 320,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1B10), // Dark brown
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red[900]!, width: 3), // Red border
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
                  const Text(
                    "¡Derrota!",
                    style: TextStyle(
                      fontFamily: 'Medieval',
                      fontSize: 40,
                      color: Colors.red,
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
                  const SizedBox(height: 10),
                  const Text(
                    "El muro ha caído...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Medieval',
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                    child: const Text(
                      "Retirada",
                      style: TextStyle(
                        fontFamily: 'Medieval',
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        },
      ),
    );
  }
}
