import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../components/boiling_oil_component.dart';

enum DifficultyStage { easy, medium, hard }

// =========================
// GOBLIN
// =========================
class GoblinComponent extends SpriteAnimationComponent with CollisionCallbacks {
  final MyGame game;
  final Function() onBreach;
  final Function() onKilled;

  int health;
  final int maxHealth;
  double speed;

  GoblinComponent({
    required this.game,
    required this.onBreach,
    required this.onKilled,
    required super.position,
    required this.speed,
    this.maxHealth = 1,
  }) : health = maxHealth,
       super(size: Vector2(50, 50), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image = game.goblinImage;
    final frameSize = Vector2(330, 290);

    final List<Sprite> sprites = [
      Sprite(image, srcPosition: Vector2(0, 0), srcSize: frameSize),
      Sprite(image, srcPosition: Vector2(0, 290), srcSize: frameSize),
    ];

    animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: 0.15,
    );

    add(RectangleHitbox(size: size * 0.8));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= speed * dt;

    final criticalY = game.size.y * 0.45;
    if (position.y <= criticalY) {
      onBreach();
      removeFromParent();
    }
  }

  void hit() {
    health--;
    if (health <= 0) {
      onKilled();
      removeFromParent();
    }
  }
}

// =========================
// MINIBOSS
// =========================
class MiniBossComponent extends GoblinComponent {
  Paint? _hitFlashPaint;

  MiniBossComponent({
    required super.game,
    required super.onBreach,
    required super.onKilled,
    required super.position,
    required super.speed,
    super.maxHealth = 25,
  }) : super();

  @override
  Future<void> onLoad() async {
    final image = game.miniBossImage;
    final frameSize = Vector2(610, 810);

    final List<Sprite> sprites = [
      for (int i = 0; i < 4; i++)
        Sprite(image, srcPosition: Vector2(0.0, 810.0 * i), srcSize: frameSize),

    ];

    animation = SpriteAnimation.spriteList(
      sprites,
      stepTime: 0.15,
    );

    size = Vector2(160, 160);
    add(RectangleHitbox(size: size * 0.8));
  }

  @override
  void render(Canvas canvas) {
    paint = _hitFlashPaint ?? Paint();
    super.render(canvas);
  }

  @override
  void hit() {
    super.hit();
    if (health > 0) {
      _hitFlashPaint = Paint()
        ..colorFilter = ColorFilter.mode(
          Colors.red.shade100,
          BlendMode.modulate,
        );
      Future.delayed(const Duration(milliseconds: 120), () {
        _hitFlashPaint = null;
      });
    }
  }
}

// =========================
// GOBLIN SPAWNER
// =========================
class GoblinSpawner extends TimerComponent with HasGameRef<MyGame> {
  final Vector2 gameSize;
  final Function() onBreach;
  final Function() onGoblinKilled;
  final Function() onMiniBossKilled;

  DifficultyStage _currentStage = DifficultyStage.easy;
  int _killsInStage = 0;

  static const int easyToMediumLimit = 10;
  static const int mediumToHardLimit = 15;
  static const int goblinsBeforeMiniBoss = 40;

  static const Map<DifficultyStage, Map<String, double>> difficultySettings = {
    DifficultyStage.easy: {'spawn': 1.5, 'defender': 1.5, 'speed': 80.0},
    DifficultyStage.medium: {'spawn': 1.0, 'defender': 1.0, 'speed': 100.0},
    DifficultyStage.hard: {'spawn': 0.75, 'defender': 0.5, 'speed': 120.0},
  };

  final Random _rnd = Random();
  late final List<double> ropePositionsX;

  GoblinSpawner({
    required MyGame game,
    required this.gameSize,
    required this.onBreach,
    required this.onGoblinKilled,
    required this.onMiniBossKilled,
  }) : super(
         period: difficultySettings[DifficultyStage.easy]!['spawn']!,
         autoStart: true,
         repeat: true,
       ) {
    game.defenderCooldownNotifier.value =
        difficultySettings[_currentStage]!['defender']!;
    ropePositionsX = game._cauldrons
        .map((c) => c.position.x + c.size.x / 2)
        .toList();
  }

  void registerKill() {
    _killsInStage++;
    onGoblinKilled();
    final totalKills = gameRef._goblinsKilledCount;

    if (gameRef.children.whereType<MiniBossComponent>().isEmpty) {
      if (_currentStage == DifficultyStage.easy &&
          totalKills >= easyToMediumLimit) {
        _changeDifficulty(DifficultyStage.medium);
      } else if (_currentStage == DifficultyStage.medium &&
          totalKills >= easyToMediumLimit + mediumToHardLimit) {
        _changeDifficulty(DifficultyStage.hard);
      }
    }
  }

  void _changeDifficulty(DifficultyStage newStage) {
    if (newStage == _currentStage) return;
    _currentStage = newStage;

    final settings = difficultySettings[newStage]!;
    timer.stop();
    timer.limit = settings['spawn']!;
    timer.start();

    gameRef.defenderCooldownNotifier.value = settings['defender']!;

    gameRef.add(
      TextComponent(
        text: '¡OLEADA ${newStage.toString().split('.').last.toUpperCase()}!',
        position: gameRef.size / 2,
        anchor: Anchor.center,
        priority: 100,
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.yellow, fontSize: 24),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      gameRef.children
          .whereType<TextComponent>()
          .lastOrNull
          ?.removeFromParent();
    });
  }

  @override
  void onTick() {
    final totalKills = gameRef._goblinsKilledCount;
    final hasMiniBoss = gameRef.children
        .whereType<MiniBossComponent>()
        .isNotEmpty;

    if (totalKills >= goblinsBeforeMiniBoss &&
        !hasMiniBoss &&
        !gameRef._miniBossKilled) {
      timer.stop();
      gameRef.add(
        MiniBossComponent(
          game: gameRef,
          onBreach: onBreach,
          onKilled: onMiniBossKilled,
          position: Vector2(gameSize.x / 2, gameSize.y),
          speed: 40,
        ),
      );
      return;
    }

    if (hasMiniBoss) return;

    final activeEnemies = gameRef.children.whereType<GoblinComponent>().length;
    if (activeEnemies >= 10) return;

    final startX = ropePositionsX[_rnd.nextInt(ropePositionsX.length)];
    final speed = difficultySettings[_currentStage]!['speed']!;
    final newGoblin = GoblinComponent(
      game: gameRef,
      onBreach: onBreach,
      onKilled: () => registerKill(),
      position: Vector2(startX - 8, gameSize.y),
      speed: speed,
    );
    gameRef.add(newGoblin);
  }
}

// =========================
// DEFENDER COMPONENT
// =========================
class DefenderComponent extends SpriteComponent with HasGameRef<MyGame> {
  late RectangleComponent _cooldownBar;
  final ui.Image leftImage;
  final ui.Image rightImage;
  static final Vector2 defenderSize = Vector2(60, 90);
  static const double defenderYPositionRatio = 0.37;

  DefenderComponent({
    required MyGame game,
    required this.leftImage,
    required this.rightImage,
  }) : super(
         size: defenderSize,
         position: Vector2(
           game.size.x / 2,
           game.size.y * defenderYPositionRatio,
         ),
         anchor: Anchor.center,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = Sprite(rightImage);

    _cooldownBar = RectangleComponent(
      position: Vector2(-defenderSize.x / 2 + 0, -defenderSize.y / 2 + 45),
      size: Vector2(defenderSize.x, 4),
      paint: Paint()..color = Colors.red.shade900,
      priority: 1,
    );
    add(_cooldownBar);
    game.defenderCooldownNotifier.addListener(_updateCooldownBar);
  }

  void setDirection(bool isLeft) {
    sprite = Sprite(isLeft ? leftImage : rightImage);
  }

  void _updateCooldownBar() {
    final currentStage =
        game.children.whereType<GoblinSpawner>().firstOrNull?._currentStage ??
            DifficultyStage.easy;
    final maxCd = GoblinSpawner.difficultySettings[currentStage]!['defender']!;
    final progress = 1 - (game._lastShotTime / maxCd).clamp(0.0, 1.0);

    _cooldownBar.size.x = defenderSize.x * progress;
    _cooldownBar.paint.color = progress >= 0.99
        ? Colors.green
        : Colors.red.shade900;
  }

  @override
  void onRemove() {
    super.onRemove();
    game.defenderCooldownNotifier.removeListener(_updateCooldownBar);
  }
}

// =========================
// MYGAME
// =========================
class MyGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final int level;
  MyGame({this.level = 1});

  List<RectangleComponent> get cauldrons => _cauldrons;

  late final ui.Image goblinImage;
  late final ui.Image miniBossImage;
  late final ui.Image defenderLeftImage;
  late final ui.Image defenderRightImage;
  late final ui.Image boilingOilImage;

  DefenderComponent? _defender;
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> breachesNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> defenderCooldownNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> abilityCooldownNotifier = ValueNotifier<double>(0.0);

  static const int maxBreaches = 5;

  double _lastShotTime = 0.0;
  double _abilityCooldownTimer = 0.0;
  bool _isGameOver = false;
  int _goblinsKilledCount = 0;
  bool _miniBossKilled = false;

  GoblinSpawner? _spawner;
  final List<RectangleComponent> _cauldrons = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    boilingOilImage = await images.load('cauldron_spritesheet.png');
    goblinImage = await images.load('GoblinBack.png');
    miniBossImage = await images.load('MiniBoss_Lvl1.png');
    defenderLeftImage = await images.load('Defensor-Izq.png');
    defenderRightImage = await images.load('Defensor-Der.png');

    add(
      SpriteComponent()
        ..sprite = await loadSprite('Fondo_Nvl1.jpg')
        ..size = size
        ..position = Vector2(0, -100)
        ..priority = -10,
    );

    final muroImage = await images.load('Muro_Nvl1.png');
    final frameSize = Vector2(1050, 1600);
    final muroSprites = [
      Sprite(muroImage, srcPosition: Vector2(0, 0), srcSize: frameSize),
      Sprite(muroImage, srcPosition: Vector2(0, 1600), srcSize: frameSize),
      Sprite(muroImage, srcPosition: Vector2(0, 3200), srcSize: frameSize),
    ];
    final muroAnimation = SpriteAnimation.spriteList(muroSprites, stepTime: 0.25);
    add(
      SpriteAnimationComponent()
        ..animation = muroAnimation
        ..size = Vector2(1050, 1600)
        ..scale = Vector2.all(size.x / 1050)
        ..position = Vector2(0, size.y - (1600 * (size.x / 1050)))
        ..priority = -5,
    );

    _defender = DefenderComponent(
      game: this,
      leftImage: defenderLeftImage,
      rightImage: defenderRightImage,
    );
    add(_defender!);

    final caldY = size.y * 0.42;
    final spacing = size.x / 5;
    for (int i = 1; i <= 4; i++) {
      final caldX = spacing * i - 30 / 2;
      final cald = RectangleComponent(
        position: Vector2(caldX - 21, caldY),
        size: Vector2(70, 600),
        paint: Paint()..color = Colors.transparent,
      );
      _cauldrons.add(cald);
      add(cald);

      final rope = RectangleComponent(
        position: Vector2(caldX + 10, caldY + 12),
        size: Vector2(6, size.y * 0.75),
        paint: Paint()..color = Colors.brown,
      );
      add(rope);
    }

    _spawner = GoblinSpawner(
      game: this,
      gameSize: size,
      onBreach: _handleBreach,
      onGoblinKilled: _handleGoblinKilled,
      onMiniBossKilled: _handleMiniBossKilled,
    );
    add(_spawner!);

    overlays.add('Hud');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_abilityCooldownTimer > 0) {
      _abilityCooldownTimer = (_abilityCooldownTimer - dt).clamp(0, double.infinity);
      abilityCooldownNotifier.value = _abilityCooldownTimer;
    }

    if (_isGameOver) return;
    if (_lastShotTime > 0) {
      _lastShotTime -= dt;
      if (_lastShotTime < 0) _lastShotTime = 0;
    }
    defenderCooldownNotifier.value = _lastShotTime;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isGameOver) return;
    if (_lastShotTime > 0) return;

    final tapPosition = event.canvasPosition;
    final tapped = componentsAtPoint(tapPosition);

    final isLeftHalf = tapPosition.x < size.x / 2;
    _defender?.setDirection(isLeftHalf);

    for (final c in tapped.whereType<GoblinComponent>()) {
      _handleAttack(c);

      final currentStage = _spawner?._currentStage ?? DifficultyStage.easy;
      _lastShotTime =
          GoblinSpawner.difficultySettings[currentStage]!['defender']!;
      return;
    }
  }

  void _handleAttack(GoblinComponent goblin) {
    goblin.hit();
    scoreNotifier.value += 10;
  }

  void _handleGoblinKilled() {
    _goblinsKilledCount++;
  }

  void _handleMiniBossKilled() {
    _miniBossKilled = true;
    _showVictoryOverlay();
  }

  void activateBoilingOil() {
    if (_abilityCooldownTimer > 0) return;
    add(BoilingOilComponent(damage: 5));
    _abilityCooldownTimer = 5;
    abilityCooldownNotifier.value = 5;
  }

  void _handleBreach() {
    breachesNotifier.value++;
    if (breachesNotifier.value >= maxBreaches) endGame(false);
  }

  void _showVictoryOverlay() {
    pauseEngine();
    overlays.remove('Hud');
    overlays.add('Victory');
  }

  void endGame(bool victory) {
    if (_isGameOver) return;
    _isGameOver = true;
    pauseEngine();
    overlays.remove('Hud');
    overlays.add('GameOver');
  }

  static Widget hudBuilder(BuildContext context, MyGame game) {
    return IgnorePointer(
      ignoring: false,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: game.scoreNotifier,
                          builder: (_, score, __) => Text(
                            'PUNTAJE: $score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<int>(
                          valueListenable: game.breachesNotifier,
                          builder: (_, breaches, __) => Text(
                            'BREACHES: $breaches / ${MyGame.maxBreaches}',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'HABILIDAD',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<double>(
                          valueListenable: game.abilityCooldownNotifier,
                          builder: (_, cooldown, __) {
                            final isReady = cooldown <= 0;
                            final text = isReady
                                ? 'ACEITE HIRVIENDO (LISTO)'
                                : 'ACEITE HIRVIENDO (CD: ${cooldown.toStringAsFixed(1)}s)';

                            return Text(
                              text,
                              style: TextStyle(
                                color: isReady
                                    ? Colors.lightBlueAccent
                                    : Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 4),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<double>(
              valueListenable: game.abilityCooldownNotifier,
              builder: (_, cooldown, __) {
                final isReady = cooldown <= 0;
                final opacity = isReady ? 1.0 : 0.4;
                final color = isReady ? Colors.orangeAccent : Colors.grey;

                return Positioned(
                  right: 16,
                  bottom: 16,
                  child: GestureDetector(
                    onTap: isReady ? game.activateBoilingOil : null,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(4, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'OIL',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
