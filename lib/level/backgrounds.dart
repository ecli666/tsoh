import 'package:flame/components.dart';
import 'package:tsoh/tsoh_game.dart';

class Backgrounds extends Component with HasGameReference<TsohGame> {
  @override
  Future<void> onLoad() async {
    final canvasSize = game.canvasSize;

    add(
      SpriteComponent(
        sprite: await game.loadSprite('level/sky.png')
          ..paint.isAntiAlias = false,
        anchor: Anchor.topLeft,
        position: Vector2.zero(),
        size: canvasSize,
      ),
    );
  }
}
