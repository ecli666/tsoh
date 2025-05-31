import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tsoh/tsoh_game.dart';

enum Block { ground1, ground2 }

class GroundTile extends SpriteComponent with HasGameReference<TsohGame> {
  GroundTile({required this.gridPosition, required this.block})
    : super(anchor: Anchor.bottomLeft);

  final Vector2 gridPosition;
  final Block block;

  @override
  Future<void> onLoad() async {
    final Vector2 srcSize = Vector2.all(16);
    final double scale = 3;

    sprite =
        block == Block.ground1
              ? await game.loadSprite('level/tile0-1.png', srcSize: srcSize)
              : await game.loadSprite(
                'level/tile0-1.png',
                srcPosition: Vector2(0, srcSize.y),
                srcSize: srcSize,
              )
          ..paint.isAntiAlias = false;
    position = Vector2(
      gridPosition.x * srcSize.x * scale,
      game.canvasSize.y - (gridPosition.y * srcSize.y * scale),
    );
    size = srcSize * scale;

    add(RectangleHitbox(collisionType: CollisionType.passive));
  }
}
