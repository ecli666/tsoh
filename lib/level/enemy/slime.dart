import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_noise/flame_noise.dart';
import 'package:tsoh/level/enemy/hp_bar.dart';
import 'package:tsoh/level/level_scene.dart';
import 'package:tsoh/level/sfx/drop.dart';
import 'package:tsoh/level/tiles/ground_tile.dart';
import 'package:tsoh/tsoh_game.dart';

enum _Act { idle, hit }

class Slime extends SpriteAnimationGroupComponent<_Act>
    with
        HasGameReference<TsohGame>,
        HasWorldReference<LevelScene>,
        CollisionCallbacks {
  Slime({
    required this.uuid,
    required this.name,
    required this.isFlip,
    required this.life,
    required super.position,
    this.attackerUuid,
  }) : super(anchor: Anchor.bottomLeft, scale: Vector2.all(2));

  final String uuid;
  final String name;
  final bool isFlip;
  int life;
  String? attackerUuid;

  PositionComponent? _attacker;
  final double _distanceToAttacker = 24;
  Vector2 _velocity = Vector2.zero();
  static const double followSpeed = 118;
  late final HpBar _hpBar;

  @override
  Future<void> onLoad() async {
    await addAll([
      RectangleHitbox(
        size: Vector2(16, 16),
        anchor: Anchor.bottomCenter,
        position: Vector2(16, 32),
      ),
      _hpBar = HpBar(maxHp: 5, currentHp: life, priority: priority + 1),
    ]);
    if (isFlip) {
      _flip();
    }

    final imageSize = Vector2.all(32);
    final imageName = 'enemy/$name-idle-hit.png';
    final idle0Sprite = await Sprite.load(
        imageName,
        srcSize: imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final idle1Sprite = await Sprite.load(
        imageName,
        srcPosition: Vector2(imageSize.x, 0),
        srcSize: imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final hit0Sprite = await Sprite.load(
        imageName,
        srcPosition: Vector2(0, imageSize.y),
        srcSize: imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final hit1Sprite = await Sprite.load(
        imageName,
        srcPosition: imageSize,
        srcSize: imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;

    final idleAnimation = SpriteAnimation.spriteList([
      idle0Sprite,
      idle1Sprite,
    ], stepTime: 0.4);
    final hitAnimation = SpriteAnimation.spriteList(
      [hit0Sprite, hit1Sprite],
      stepTime: 0.12,
      loop: false,
    );

    animations = {_Act.idle: idleAnimation, _Act.hit: hitAnimation};
    current = _Act.idle;

    animationTickers?[_Act.hit]?.onComplete = () {
      current = _Act.idle;
    };
  }

  @override
  void update(double dt) {
    if (dt > 0.1) dt = 0.1;
    if (children.query<Effect>().isEmpty) {
      if (_attacker != null) {
        _velocity.y += TsohGame.gravity * dt;
        final len = (_attacker!.position - position).length;
        if (len > _distanceToAttacker) {
          if (_attacker!.position.x >= position.x) {
            if (!isFlippedHorizontally) {
              _flip();
            }
            _velocity.x = followSpeed;
          } else {
            if (isFlippedHorizontally) {
              _flip();
            }
            _velocity.x = -followSpeed;
          }
        }
        position += _velocity * dt;
      } else {
        if (attackerUuid != null) {
          final scene =
              (game.router.currentRoute as WorldRoute).world as LevelScene;
          _attacker = scene.others.findOther(attackerUuid!);
          attackerUuid = null;
        }
      }
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (intersectionPoints.isNotEmpty && other is GroundTile) {
      if (_velocity.y > TsohGame.dropVelocity) {
        add(Drop(position: Vector2(16, 32), priority: priority + 3));
      }
      _velocity = Vector2.zero();
      position.y = intersectionPoints.map((v) => v.y).reduce(min);
    }
  }

  void _flip() {
    flipHorizontally();
    _hpBar.flip();
  }

  void hit(bool isFlip, PositionComponent comp) {
    _hpBar.hit();
    if (--life <= 0) {
      _attacker = null;
      addAll([
        OpacityEffect.fadeOut(
          EffectController(duration: 1.0),
          onComplete: () {
            removeFromParent();
          },
        ),
        MoveEffect.by(
          Vector2(20, 20),
          NoiseEffectController(
            duration: 0.5,
            noise: PerlinNoise(frequency: 400),
          ),
        ),
      ]);
    }
    if (isFlip == isFlippedHorizontally) {
      _flip();
    }
    current = _Act.hit;
    _attacker = comp;
    if (children.query<Effect>().isEmpty) {
      final double vel = isFlippedHorizontally ? -28 : 28;
      add(MoveByEffect(Vector2(vel, 0), EffectController(duration: 0.08)));
    }
  }
}
