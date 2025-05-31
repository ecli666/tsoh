import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:tsoh/tsoh_game.dart';

enum DirectionButtonState { unpressed, pressed }

class DirectionButtonComponent
    extends SpriteGroupComponent<DirectionButtonState>
    with HasGameReference<TsohGame>, TapCallbacks {
  DirectionButtonComponent({
    required this.downAction,
    required this.upAction,
    required this.imageName,
    required super.position,
    required super.size,
  });

  final void Function() downAction;
  final void Function()? upAction;
  final String imageName;

  @override
  Future<void> onLoad() async {
    final unpressedSprite = await game.loadSprite(
        imageName,
        srcSize: Vector2.all(32),
      )
      ..paint.isAntiAlias = false;
    final pressedSprite = await game.loadSprite(
        imageName,
        srcPosition: Vector2(32, 0),
        srcSize: Vector2.all(32),
      )
      ..paint.isAntiAlias = false;

    sprites = {
      DirectionButtonState.unpressed: unpressedSprite,
      DirectionButtonState.pressed: pressedSprite,
    };
    current = DirectionButtonState.unpressed;

    anchor = Anchor.topLeft;
  }

  @override
  void onTapDown(_) {
    downAction();
    current = DirectionButtonState.pressed;
  }

  @override
  void onTapUp(_) {
    upAction?.call();
    current = DirectionButtonState.unpressed;
  }

  @override
  void onTapCancel(_) {
    upAction?.call();
    current = DirectionButtonState.unpressed;
  }
}
