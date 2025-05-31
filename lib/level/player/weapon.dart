import 'package:flame/components.dart';
import 'package:tsoh/level/player/has_animations.dart';
import 'package:tsoh/level/player/player.dart';

class Weapon extends SpriteAnimationGroupComponent<Ops>
    with HasAnimations, HasVisibility {
  Weapon({
    required super.position,
    required super.priority,
    required this.name,
    required this.weapon,
  }) : super(anchor: Anchor.bottomCenter);

  final String name;
  final WeaponType weapon;

  @override
  Future<void> onLoad() async {
    if (weapon == WeaponType.sword) await loadSwingAnimations(name);
    if (weapon == WeaponType.bow) await loadShootAnimations(name);
  }
}
