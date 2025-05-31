import 'package:flame/components.dart';

class Drop extends SpriteAnimationComponent {
  Drop({required super.position, required super.priority})
    : super(
        size: Vector2.all(32),
        anchor: Anchor.bottomCenter,
        removeOnFinish: true,
      );

  @override
  Future<void> onLoad() async {
    animation = await SpriteAnimation.load(
      'sfx/drop.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.06,
        textureSize: size,
        loop: false,
      ),
    );
  }
}
