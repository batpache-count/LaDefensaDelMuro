import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../screens/game/my_game.dart';

class BoilingOilComponent extends Component with HasGameRef<MyGame> {
  final int totalFrames = 21;
  final double frameTime = 0.15;
  late final List<Sprite> sprites;
  final double damage;

  BoilingOilComponent({this.damage = 5});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Tamaño de cada frame
    final frameSize = Vector2(50, 300);
    final displaySize = Vector2(90, 620);

    // Cortar los frames del spritesheet
    sprites = List.generate(totalFrames, (i) {
      return Sprite(
        gameRef.boilingOilImage,
        srcPosition: Vector2(0, i * frameSize.y),
        srcSize: frameSize,
      );
    });

    // Crear animación
    final animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: frameTime,
      loop: false,
    );

    // Mostrar animación sobre cada caldero
    for (final cald in gameRef.cauldrons) {
      final animComp = SpriteAnimationComponent(
        animation: animation,
        size: displaySize,
        anchor: Anchor.bottomCenter,
        position: Vector2(
          cald.position.x + cald.size.x / 2, // centrar sobre el hitbox
          cald.position.y + cald.size.y,
        ),
      );
      add(animComp);

      // Quitar la animación al terminar
      Future.delayed(Duration(
        milliseconds: (frameTime * totalFrames * 1000).ceil(),
      ), () {
        animComp.removeFromParent();
      });
    }

    // Aplicar daño instantáneo a los goblins que estén dentro de los hitboxes
    for (final cald in gameRef.cauldrons) {
      final caldRect = cald.toRect();
      for (final goblin in gameRef.children.whereType<GoblinComponent>()) {
        if (goblin.toRect().overlaps(caldRect)) {
          goblin.hit();
          gameRef.onGoblinKilledByOil();
        }
      }

      for (final miniboss in gameRef.children.whereType<MiniBossComponent>()) {
        if (miniboss.toRect().overlaps(caldRect)) {
          miniboss.hit();
          gameRef.onMiniBossKilledByOil();
        }
      }
    }

    // Quitar este componente después de la duración de la animación
    Future.delayed(Duration(
      milliseconds: (frameTime * totalFrames * 1000).ceil(),
    ), () {
      removeFromParent();
    });
  }
}
