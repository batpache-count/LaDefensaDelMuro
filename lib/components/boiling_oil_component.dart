import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../screens/game/my_game.dart';

class BoilingOilComponent extends PositionComponent with HasGameRef<MyGame> {
  final double damage;
  bool _cleanupDone = false; // 🔒 evita múltiples limpiezas

  BoilingOilComponent({this.damage = 5});

  late final List<double> ropePositionsX;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    ropePositionsX = [
      size.x * 1 / 5,
      size.x * 2 / 5,
      size.x * 3 / 5,
      size.x * 4 / 5,
    ];

    // ⏸️ Pausar spawn temporalmente
    gameRef.pauseSpawning();

    final wallY = gameRef.size.y * 0.42;
    final canvasWidth = gameRef.size.x;

    // 🟩 Crear 4 calderos verdes bien distribuidos
    final int calderoCount = 4;
    final double spacing = canvasWidth / (calderoCount + 1);
    final List<RectangleComponent> cauldrons = [];

    for (int i = 0; i < calderoCount; i++) {
      final x = spacing * (i + 1);

      final caldero = RectangleComponent(
        position: Vector2(x, wallY - 35),
        size: Vector2(40, 40),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.greenAccent,
      );

      cauldrons.add(caldero);
      add(caldero);
    }

    // ⏳ Derramar aceite después de 1 segundo (TODOS a la vez)
    Future.delayed(const Duration(seconds: 1), () async {
      // 🔥 Todos los calderos sueltan aceite simultáneamente
      for (final caldero in cauldrons) {
        _spawnOilFrom(caldero);
      }

      // ⏳ Después de 1.2 segundos: limpiar todo
      Future.delayed(const Duration(milliseconds: 1200), _cleanup);
    });
  }

  void _spawnOilFrom(RectangleComponent caldero) {
    final wallY = gameRef.size.y * 0.40;
    final oilHeight = gameRef.size.y - wallY;

    final oil = RectangleComponent(
      position: Vector2(caldero.position.x, wallY),
      size: Vector2(gameRef.size.x / 3.5, oilHeight),
      anchor: Anchor.topCenter,
      paint: Paint()..color = Colors.orangeAccent.withOpacity(0.9),
    );
    add(oil);

    // DAÑO: cada caldero aplica su propio daño
    for (final goblin in gameRef.children.whereType<GoblinComponent>()) {
      final goblinLeft = goblin.position.x;
      final goblinRight = goblin.position.x + goblin.size.x;
      final oilLeft = oil.position.x - oil.size.x / 2;
      final oilRight = oil.position.x + oil.size.x / 2;

      // Solo si el goblin está bajo el aceite de este caldero
      if (goblinRight >= oilLeft && goblinLeft <= oilRight) {
        goblin.health -= damage.toInt();

        if (goblin.health <= 0) {
          goblin.removeFromParent();
          gameRef.scoreNotifier.value += 10;

          if (goblin is MiniBossComponent) {
            gameRef.onMiniBossKilledByOil();
          } else {
            gameRef.onGoblinKilledByOil();
          }
        }
      }
    }

    // Retirar el aceite tras 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      oil.removeFromParent();
    });
  }

  void _cleanup() {
    if (_cleanupDone) return; // evitar repeticiones
    _cleanupDone = true;

    // 🔥 Quitar todos los calderos y el componente
    for (final c in children.whereType<RectangleComponent>().toList()) {
      c.removeFromParent();
    }
    removeFromParent();

    // ▶️ Reanudar spawn
    gameRef.resumeSpawning();
  }
}
