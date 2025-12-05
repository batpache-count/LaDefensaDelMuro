// lib/screens/game/level2_game.dart

import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

enum DifficultyStage2 { easy, medium, hard }

/// =======================================================
/// ENEMIGO VOLADOR
/// =======================================================
class FlyingEnemyComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<Level2Game> {
  final Function() onKilled;
  int health;
  double speed;
  int direction = 1;

  FlyingEnemyComponent({
    required this.onKilled,
    required super.position,
    this.health = 1,
    this.speed = 80.0,
  }) : super(size: Vector2(48, 48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // IMAGEN CARGADA DEL GAME
    sprite = Sprite(await gameRef.images.load('GoblinBack.png'));

    // HITBOX CORRECTO
    add(RectangleHitbox(size: size * 0.8));
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.x += direction * speed * dt;

    final leftBound = size.x / 2;
    final rightBound = gameRef.size.x - size.x / 2;

    if (position.x <= leftBound) {
      direction = 1;
      position.x = leftBound;
    } else if (position.x >= rightBound) {
      direction = -1;
      position.x = rightBound;
    }
  }

  void hit(int damage) {
    health -= damage;
    if (health <= 0) {
      onKilled();
      gameRef.scoreNotifier.value += 10;
      removeFromParent();
    }
  }
}

/// =======================================================
/// MINIBOSS
/// =======================================================
class FlyingBossComponent extends FlyingEnemyComponent {
  FlyingBossComponent({
    required Function() onKilled,
    required Vector2 position,
    double speed = 60,
  }) : super(
          onKilled: onKilled,
          position: position,
          health: 25,
          speed: speed,
        ) {
    size = Vector2(120, 120);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = Sprite(await gameRef.images.load('GoblinBack.png'));

    add(RectangleHitbox(size: size * 0.9));
  }
}

/// =======================================================
/// SPAWNER
/// =======================================================
class FlyingSpawner extends TimerComponent with HasGameRef<Level2Game> {
  final Vector2 gameSize;
  final Function() onEnemyKilled;
  final Function() onBossKilled;

  DifficultyStage2 _currentStage = DifficultyStage2.easy;

  static const int easyToMediumLimit = 10;
  static const int mediumToHardLimit = 15;
  static const int killsBeforeBoss = 40;

  static const Map<DifficultyStage2, Map<String, double>> difficulty = {
    DifficultyStage2.easy: {'spawn': 1.5, 'speed': 80.0},
    DifficultyStage2.medium: {'spawn': 1.0, 'speed': 110.0},
    DifficultyStage2.hard: {'spawn': 0.7, 'speed': 150.0},
  };

  final Random _rnd = Random();

  FlyingSpawner({
    required this.gameSize,
    required this.onEnemyKilled,
    required this.onBossKilled,
  }) : super(
          period: difficulty[DifficultyStage2.easy]!['spawn']!,
          repeat: true,
          autoStart: true,
        );

  void registerKill() {
    onEnemyKilled();

    final kills = gameRef.enemiesKilledCount;

    if (_currentStage == DifficultyStage2.easy &&
        kills >= easyToMediumLimit) {
      _changeDifficulty(DifficultyStage2.medium);
    } else if (_currentStage == DifficultyStage2.medium &&
        kills >= easyToMediumLimit + mediumToHardLimit) {
      _changeDifficulty(DifficultyStage2.hard);
    }
  }

  void _changeDifficulty(DifficultyStage2 newStage) {
    if (newStage == _currentStage) return;
    _currentStage = newStage;

    timer.stop();
    timer.limit = difficulty[newStage]!['spawn']!;
    timer.start();

    final txt = TextComponent(
      text: "OLEADA ${newStage.name.toUpperCase()}",
      anchor: Anchor.center,
      position: gameRef.size / 2,
      priority: 200,
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.yellow, fontSize: 22),
      ),
    );

    gameRef.add(txt);

    Future.delayed(const Duration(seconds: 2), () => txt.removeFromParent());
  }

  @override
  void onTick() {
    final kills = gameRef.enemiesKilledCount;
    final hasBoss =
        gameRef.children.whereType<FlyingBossComponent>().isNotEmpty;

    if (kills >= killsBeforeBoss && !hasBoss && !gameRef.bossKilled) {
      timer.stop();
      gameRef.add(
        FlyingBossComponent(
          onKilled: onBossKilled,
          position: Vector2(gameSize.x / 2, gameSize.y * 0.15),
          speed: difficulty[_currentStage]!['speed']! * 0.6,
        ),
      );
      return;
    }

    if (hasBoss) return;

    final count = gameRef.children.whereType<FlyingEnemyComponent>().length;
    if (count >= 10) return;

    final x = _rnd.nextDouble() * (gameSize.x - 60) + 30;
    final y = gameSize.y * 0.12 + _rnd.nextDouble() * (gameSize.y * 0.2);

    final e = FlyingEnemyComponent(
      onKilled: registerKill,
      position: Vector2(x, y),
      speed: difficulty[_currentStage]!['speed']!,
    );

    e.direction = _rnd.nextBool() ? 1 : -1;
    gameRef.add(e);
  }
}

/// =======================================================
/// DEFENSOR
/// =======================================================
class DefenderBottomComponent extends SpriteComponent
    with HasGameRef<Level2Game> {
  late RectangleComponent _cooldownBar;

  final ui.Image leftImg;
  final ui.Image rightImg;

  DefenderBottomComponent({
    required this.leftImg,
    required this.rightImg,
  }) : super(size: Vector2(64, 96), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    position = Vector2(gameRef.size.x / 2, gameRef.size.y * 0.88);

    sprite = Sprite(rightImg);

    _cooldownBar = RectangleComponent(
      size: Vector2(64, 6),
      position: Vector2(-32, -54),
      paint: Paint()..color = Colors.red.shade900,
    );

    add(_cooldownBar);

    gameRef.defenderCooldownNotifier.addListener(_updateBar);
  }

  void setDirection(bool left) {
    sprite = Sprite(left ? leftImg : rightImg);
  }

  void _updateBar() {
    final cd = 1 - (gameRef._lastShotTime / gameRef._defenderMaxCd)
    .clamp(0, 1)
    .toDouble();

    _cooldownBar.size.x = 64 * cd;
    _cooldownBar.paint.color = cd >= 0.99 ? Colors.green : Colors.red.shade900;
  }

  @override
  void onRemove() {
    gameRef.defenderCooldownNotifier.removeListener(_updateBar);
    super.onRemove();
  }
}

/// =======================================================
/// SCREEN SWEEP (HABILIDAD ESPECIAL)
/// =======================================================
class ScreenSweepComponent extends PositionComponent
    with HasGameRef<Level2Game> {
  final double width;
  final double durationSeconds;
  final int damage;

  ScreenSweepComponent({
    this.width = 40,
    this.durationSeconds = 0.6,
    this.damage = 999,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2(width, gameRef.size.y * 0.4);
    anchor = Anchor.topLeft;
    position = Vector2(-width, gameRef.size.y * 0.12);

    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.orange.withOpacity(0.25),
    ));

    final dx = gameRef.size.x + width - position.x;
    final speed = dx / durationSeconds;

    add(
      TimerComponent(
        period: 1 / 60,
        repeat: true,
        onTick: () {
          position.x += speed / 60;
          _damageEnemies();

          if (position.x > gameRef.size.x) removeFromParent();
        },
      ),
    );
  }

  void _damageEnemies() {
    final left = position.x;
    final right = left + size.x;

    for (final e in gameRef.children.whereType<FlyingEnemyComponent>()) {
      final exL = e.position.x - e.size.x / 2;
      final exR = e.position.x + e.size.x / 2;
      if (exR >= left && exL <= right) e.hit(damage);
    }

    for (final b in gameRef.children.whereType<FlyingBossComponent>()) {
      final bxL = b.position.x - b.size.x / 2;
      final bxR = b.position.x + b.size.x / 2;
      if (bxR >= left && bxL <= right) {
        b.hit(damage);
        if (b.health <= 0) gameRef.onBossKilledBySweep();
      }
    }
  }
}

/// =======================================================
/// GAME PRINCIPAL NIVEL 2
/// =======================================================
class Level2Game extends FlameGame
    with TapCallbacks, HasCollisionDetection {
  int enemiesKilledCount = 0;
  bool bossKilled = false;

  final scoreNotifier = ValueNotifier<int>(0);
  final defenderCooldownNotifier = ValueNotifier<double>(0);
  final abilityCooldownNotifier = ValueNotifier<double>(0);

  double _lastShotTime = 0;
  final double _defenderMaxCd = 1.5;

  double _abilityTimer = 0;
  final double _abilityCooldown = 6;

  DefenderBottomComponent? defender;
  FlyingSpawner? spawner;

  late final ui.Image defenderLeft;
  late final ui.Image defenderRight;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    defenderLeft = await images.load('Defensor-Izq.png');
    defenderRight = await images.load('Defensor-Der.png');

    add(SpriteComponent()
      ..sprite = await loadSprite('Fondo_Nvl2.jpg')
      ..size = size
      ..priority = -10);

    defender = DefenderBottomComponent(
      leftImg: defenderLeft,
      rightImg: defenderRight,
    );
    add(defender!);

    spawner = FlyingSpawner(
      gameSize: size,
      onEnemyKilled: () => enemiesKilledCount++,
      onBossKilled: () => bossKilled = true,
    );
    add(spawner!);

    overlays.add('Hud');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_lastShotTime > 0) _lastShotTime -= dt;
    if (_lastShotTime < 0) _lastShotTime = 0;
    defenderCooldownNotifier.value = _lastShotTime;

    if (_abilityTimer > 0) {
      _abilityTimer -= dt;
      if (_abilityTimer < 0) _abilityTimer = 0;
      abilityCooldownNotifier.value = _abilityTimer;
    }
  }

  @override
  void onTapDown(TapDownEvent e) {
    if (_lastShotTime > 0) return;

    final isLeft = e.canvasPosition.x < size.x / 2;
    defender?.setDirection(isLeft);

    final tapped = componentsAtPoint(e.canvasPosition);

    for (final enemy in tapped.whereType<FlyingEnemyComponent>()) {
      enemy.hit(1);
      _lastShotTime = _defenderMaxCd;
      return;
    }

    for (final boss in tapped.whereType<FlyingBossComponent>()) {
      boss.hit(1);
      _lastShotTime = _defenderMaxCd;
      return;
    }
  }

  void activateScreenSweep() {
    if (_abilityTimer > 0) return;

    add(ScreenSweepComponent(
      width: size.x * 0.12,
      durationSeconds: 0.7,
    ));

    _abilityTimer = _abilityCooldown;
    abilityCooldownNotifier.value = _abilityTimer;
  }

  void onBossKilledBySweep() {
    bossKilled = true;
  }
}
