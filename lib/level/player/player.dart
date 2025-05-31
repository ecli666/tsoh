import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:tsoh/level/level_scene.dart';
import 'package:tsoh/level/player/arrow.dart';
import 'package:tsoh/level/player/has_animations.dart';
import 'package:tsoh/level/player/weapon.dart';
import 'package:tsoh/level/sfx/drop.dart';
import 'package:tsoh/level/tiles/ground_tile.dart';
import 'package:tsoh/tsoh_game.dart';

enum WeaponType { none, sword, bow }

base class Player extends SpriteAnimationGroupComponent<Ops>
    with HasWorldReference<LevelScene>, HasAnimations, CollisionCallbacks {
  Player({
    required this.uuid,
    required this.name,
    required this.outfit,
    required super.position,
    super.priority,
  }) : super(anchor: Anchor.bottomCenter, scale: Vector2.all(2));

  static const double walkSpeed = 124;
  final String uuid;
  final String name;
  final String outfit;
  final Vector2 _arrowOffset = Vector2(0, -24);
  Vector2 velocity = Vector2.zero();

  late final TextComponent _nameComponent;
  late final Weapon sword;
  late final Weapon bow;
  late final RectangleHitbox rectBox;

  @override
  Future<void> onLoad() async {
    await loadPlayerAnimations(outfit);
    await addAll([
      _nameComponent = TextComponent(
        text: name,
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: 8,
            color: BasicPalette.white.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.bottomCenter,
        position: Vector2(32, 24),
      ),
      sword = Weapon(
        position: Vector2(32, 64),
        priority: priority + 1,
        name: 'sword0',
        weapon: WeaponType.sword,
      )..isVisible = false,
      bow = Weapon(
        position: Vector2(32, 64),
        priority: priority + 1,
        name: 'bow0',
        weapon: WeaponType.bow,
      )..isVisible = false,
      rectBox = RectangleHitbox(
        size: Vector2(16, 32),
        anchor: Anchor.bottomCenter,
        position: Vector2(32, 64),
      ),
    ]);
    animationTickers?[Ops.shoot]?.onFrame = (index) {
      if (index == 2) {
        FlameAudio.play('sfx/sword-sound-2.mp3');
        world.add(
          Arrow(
            isFlippedHorizontally,
            uuid,
            position: position + _arrowOffset,
            priority: priority + 2,
          ),
        );
      }
    };
  }

  @override
  void update(double dt) {
    if (dt > 0.1) dt = 0.1;
    velocity.y += TsohGame.gravity * dt;
    position += velocity * dt;
    super.update(dt);
  }

  void backToNormal() {
    setState(Ops.idle);
  }

  void flip() {
    flipHorizontally();
    _nameComponent.flipHorizontally();
  }

  void setState(Ops ops) {
    current = ops;
    if (ops != Ops.shoot) {
      sword.current = ops;
    }
    if ((ops != Ops.swing0) && (ops != Ops.swing1)) {
      bow.current = ops;
    }
    switch (ops) {
      case Ops.swing0:
      case Ops.swing1:
        FlameAudio.play('sfx/axe-slash-1.mp3');
        break;
      default:
        break;
    }
  }

  WeaponType getWeapon() {
    if (sword.isVisible) {
      return WeaponType.sword;
    } else if (bow.isVisible) {
      return WeaponType.bow;
    } else {
      return WeaponType.none;
    }
  }

  void setWeapon(WeaponType weapon) {
    switch (weapon) {
      case WeaponType.none:
        sword.isVisible = false;
        bow.isVisible = false;
      case WeaponType.sword:
        sword.isVisible = true;
        bow.isVisible = false;
      case WeaponType.bow:
        sword.isVisible = false;
        bow.isVisible = true;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (intersectionPoints.isNotEmpty && other is GroundTile) {
      final plb = Vector2(position.x - 24, position.y);
      final prb = Vector2(position.x + 24, position.y);
      final plt = Vector2(position.x - 24, position.y - 64);
      final prt = Vector2(position.x + 24, position.y - 64);

      final lv = (plb + plt) / 2;
      final tv = (plt + prt) / 2;
      final rv = (prb + prt) / 2;
      final bv = (plb + prb) / 2;
      final ql = [lv, tv, rv, bv]; // left, top, right, bottom

      final iv =
          intersectionPoints.reduce((a, b) => a + b) /
          intersectionPoints.length.toDouble();

      final qll = ql.map((elem) => (elem - iv).length);
      final qm = qll.reduce(min);
      final idx = qll.toList().indexOf(qm);

      if (velocity.y >= 0) {
        if ((idx == 0) || (idx == 2)) {
          velocity = Vector2.zero();
          if (idx == 0) {
            // left
            position.x = intersectionPoints.map((v) => v.x).reduce(max) + 1;
          } else {
            // right
            position.x = intersectionPoints.map((v) => v.x).reduce(min) - 1;
          }
        } else if (idx == 3) {
          // bottom
          velocity.y = 0;
          position.y = intersectionPoints.map((v) => v.y).reduce(min);
          if (velocity.y > TsohGame.dropVelocity) {
            add(Drop(position: Vector2(32, 64), priority: priority + 3));
          }
          if (current == Ops.jump) {
            backToNormal();
          }
        }
      }
    }
  }
}
