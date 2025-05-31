import 'package:flame/components.dart';
import 'package:tsoh/level/player/has_animations.dart';
import 'package:tsoh/level/player/player.dart';

final class OtherPlayer extends Player {
  OtherPlayer({
    required super.uuid,
    required super.name,
    required super.outfit,
    required super.position,
  });

  void applyState(
    bool isFlip,
    WeaponType weapon,
    Vector2 position,
    Vector2 vel,
    Ops ops,
  ) {
    if (isFlippedHorizontally != isFlip) {
      flip();
    }
    if (getWeapon() != weapon) {
      setWeapon(weapon);
    }
    this.position = position;
    velocity = vel;
    setState(ops);
  }
}
