import 'package:flame/components.dart';
import 'package:flame/flame.dart';

enum Ops { idle, walk, jump, swing0, swing1, shoot }

mixin HasAnimations on SpriteAnimationGroupComponent<Ops> {
  final _imageSize = Vector2.all(64);

  Future<Map<Ops, SpriteAnimation>> _loadCommons(String name) async {
    final moveImageName = 'chr/chr0-$name-walk-idle.png';
    final walk0Sprite = await Sprite.load(
        moveImageName,
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final walk1Sprite = await Sprite.load(
        moveImageName,
        srcPosition: Vector2(0, _imageSize.y),
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final idle0Sprite = await Sprite.load(
        moveImageName,
        srcPosition: Vector2(_imageSize.x, 0),
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final idle1Sprite = await Sprite.load(
        moveImageName,
        srcPosition: _imageSize,
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;

    final jumpImageName = 'chr/chr0-$name-jump.png';
    final jump0Sprite = await Sprite.load(
        jumpImageName,
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final jump1Sprite = await Sprite.load(
        jumpImageName,
        srcPosition: Vector2(_imageSize.x, 0),
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;

    final idleAnimation = SpriteAnimation.spriteList([
      idle0Sprite,
      idle1Sprite,
    ], stepTime: 0.6);
    final walkAnimation = SpriteAnimation.spriteList([
      walk0Sprite,
      idle0Sprite,
      walk1Sprite,
      idle0Sprite,
    ], stepTime: 0.19);
    final jumpAnimation = SpriteAnimation.spriteList(
      [jump0Sprite, jump1Sprite],
      stepTime: 0.5,
      loop: false,
    );

    return {
      Ops.idle: idleAnimation,
      Ops.walk: walkAnimation,
      Ops.jump: jumpAnimation,
    };
  }

  Future<Map<Ops, SpriteAnimation>> _loadSwings(String name) async {
    final swingImageName = 'chr/chr0-$name-swing.png';
    final swing00Sprite = await Sprite.load(
        swingImageName,
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final swing01Sprite = await Sprite.load(
        swingImageName,
        srcPosition: Vector2(_imageSize.x, 0),
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final swing10Sprite = await Sprite.load(
        swingImageName,
        srcPosition: Vector2(0, _imageSize.y),
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final swing11Sprite = await Sprite.load(
        swingImageName,
        srcPosition: _imageSize,
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;

    final swing0Animation = SpriteAnimation.spriteList(
      [swing00Sprite, swing01Sprite],
      stepTime: 0.3,
      loop: false,
    );
    final swing1Animation = SpriteAnimation.spriteList(
      [swing10Sprite, swing11Sprite],
      stepTime: 0.34,
      loop: false,
    );

    return {Ops.swing0: swing0Animation, Ops.swing1: swing1Animation};
  }

  Future<Map<Ops, SpriteAnimation>> _loadShoots(String name) async {
    final shootImageName = 'chr/chr0-$name-shoot.png';
    final shoot0Sprite = await Sprite.load(
        shootImageName,
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final shoot1Sprite = await Sprite.load(
        shootImageName,
        srcPosition: Vector2(_imageSize.x, 0),
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;
    final shoot2Sprite = await Sprite.load(
        shootImageName,
        srcPosition: Vector2(_imageSize.x * 2, 0),
        srcSize: _imageSize,
        images: Flame.images,
      )
      ..paint.isAntiAlias = false;

    final shootAnimation = SpriteAnimation.spriteList(
      [shoot0Sprite, shoot1Sprite, shoot2Sprite],
      stepTime: 0.38,
      loop: false,
    );

    return {Ops.shoot: shootAnimation};
  }

  Future<void> loadPlayerAnimations(String name) async {
    final common = await _loadCommons(name);
    final swing = await _loadSwings(name);
    final shoot = await _loadShoots(name);
    animations = {...common, ...swing, ...shoot};
    current = Ops.idle;
  }

  Future<void> loadSwingAnimations(String name) async {
    final common = await _loadCommons(name);
    final swing = await _loadSwings(name);
    animations = {...common, ...swing};
    current = Ops.idle;
  }

  Future<void> loadShootAnimations(String name) async {
    final common = await _loadCommons(name);
    final shoot = await _loadShoots(name);
    animations = {...common, ...shoot};
    current = Ops.idle;
  }
}
