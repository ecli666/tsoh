import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tsoh/level/enemy/slime.dart';
import 'package:tsoh/level/level_scene.dart';

class Arrow extends SpriteComponent
    with HasGameReference, HasWorldReference<LevelScene>, CollisionCallbacks {
  Arrow(
    this.isFlip,
    this.uuid, {
    required super.position,
    required super.priority,
  }) : super(
         size: Vector2(32, 16),
         anchor: Anchor.center,
         scale: Vector2.all(2),
       );

  final bool isFlip;
  final String uuid;
  final double _velocity = 540;

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('chr/arrow.png');
    if (isFlip) flipHorizontally();
    add(
      RectangleHitbox(
        size: Vector2(24, 6),
        anchor: Anchor.bottomCenter,
        position: Vector2(16, 10),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final vel = isFlip ? _velocity : -_velocity;
    position.x += dt * vel;
    final bound = game.camera.visibleWorldRect;
    if ((position.x > bound.right + 32) || (position.x < bound.left - 32)) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (intersectionPoints.isNotEmpty && other is Slime) {
      world.hitEnemy(isFlip, uuid, other);
      removeFromParent();
    }
  }
}
