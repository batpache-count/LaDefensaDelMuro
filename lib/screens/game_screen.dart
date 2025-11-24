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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "¡Nivel completado!",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final gameState = Provider.of<GameState>(context, listen: false);
                    gameState.setUnlockedLevels(level + 1);

                    if (gameState.isLoggedIn) {
                      firebaseService.savePlayerData(gameState.user!.uid, gameState.toJson());
                    }
                    Navigator.pop(context);
                  },
                  child: const Text("Regresar"),
                ),
              ],
            ),
          ),

          'GameOver': (context, game) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "GAME OVER",
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Intentar de nuevo"),
                ),
              ],
            ),
          ),
        },
      ),
    );
  }
}
