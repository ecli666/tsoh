import 'package:flame/components.dart';
import 'package:tsoh/tsoh_game.dart';

enum FrontOutfit { outfit0, outfit1 }

class FrontPlayer extends PositionComponent with HasGameReference<TsohGame> {
  FrontPlayer({super.position, super.size, super.priority})
    : super(anchor: Anchor.topLeft);

  late final SpriteAnimationGroupComponent _outfit;

  @override
  Future<void> onLoad() async {
    final data = SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: 0.6,
      textureSize: Vector2.all(32),
    );

    final outfit0 = SpriteAnimation.fromFrameData(
      game.images.fromCache('chr/chr0-outfit0-front.png'),
      data,
    );
    final outfit1 = SpriteAnimation.fromFrameData(
      game.images.fromCache('chr/chr0-outfit1-front.png'),
      data,
    );
    _outfit = SpriteAnimationGroupComponent<FrontOutfit>(
      animations: {FrontOutfit.outfit0: outfit0, FrontOutfit.outfit1: outfit1},
      current: FrontOutfit.outfit0,
      size: size,
      anchor: anchor,
      priority: priority + 1,
    )..paint.isAntiAlias = false;

    add(_outfit);
  }

  void nextChr() {
    _outfit.current =
        (_outfit.current == FrontOutfit.outfit0)
            ? FrontOutfit.outfit1
            : FrontOutfit.outfit0;
  }
}
