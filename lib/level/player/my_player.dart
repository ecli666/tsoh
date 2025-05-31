import 'package:flame/components.dart';
import 'package:tsoh/level/player/has_animations.dart';
import 'package:tsoh/level/player/player.dart';
import 'package:tsoh/tsoh_game.dart';

final class MyPlayer extends Player with HasGameReference<TsohGame> {
  MyPlayer({
    required super.uuid,
    required super.name,
    required super.outfit,
    required super.position,
  }) : super(priority: 50);

  bool _leftPressed = false;
  bool _rightPressed = false;
  bool _swinging = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animationTickers?[Ops.swing0]?.onFrame = (index) {
      if (index == 1) {
        world.hitCheck();
      }
    };
    animationTickers?[Ops.swing1]?.onFrame = (index) {
      if (index == 1) {
        world.hitCheck();
      }
    };
    animationTickers?[Ops.swing1]?.onComplete = () {
      _swinging = false;
      backToNormal();
    };
    animationTickers?[Ops.shoot]?.onComplete = () {
      backToNormal();
    };
  }

  @override
  void backToNormal() {
    _swinging = false;
    if (_leftPressed) {
      _moveLeft();
    } else if (_rightPressed) {
      _moveRight();
    } else {
      _moveStop();
    }
  }

  void _sendSync() {
    game.net.sendUserSync(
      isFlippedHorizontally,
      getWeapon(),
      position,
      velocity,
      current!,
    );
  }

  void _moveLeft() {
    if (isFlippedHorizontally) {
      flip();
    }
    velocity.x = -Player.walkSpeed;
    setState(Ops.walk);
    _sendSync();
  }

  void _moveRight() {
    if (!isFlippedHorizontally) {
      flip();
    }
    velocity.x = Player.walkSpeed;
    setState(Ops.walk);
    _sendSync();
  }

  void _moveStop() {
    velocity.x = 0;
    setState(Ops.idle);
    _sendSync();
  }

  bool _canMove() {
    if ((current == Ops.jump) ||
        (current == Ops.swing0) ||
        (current == Ops.swing1) ||
        (current == Ops.shoot)) {
      return false;
    }
    return true;
  }

  void moveLeftStart() {
    _leftPressed = true;
    if (!_canMove()) return;
    _moveLeft();
  }

  void moveLeftStop() {
    _leftPressed = false;
    if (!_canMove()) return;
    _moveStop();
  }

  void moveRightStart() {
    _rightPressed = true;
    if (!_canMove()) return;
    _moveRight();
  }

  void moveRightStop() {
    _rightPressed = false;
    if (!_canMove()) return;
    _moveStop();
  }

  void jump() {
    if (current == Ops.jump) return;
    velocity.y = -TsohGame.gravity / 2;
    setState(Ops.jump);
    _sendSync();
  }

  void swing() {
    if (current == Ops.jump) return;
    if (!_swinging) {
      velocity = Vector2.zero();
      animationTickers?[Ops.swing0]?.onComplete = () {
        _swinging = false;
        backToNormal();
        _sendSync();
      };
      setState(Ops.swing0);
      _swinging = true;
    } else {
      if (current == Ops.swing0) {
        if (isFlippedHorizontally) {
          velocity.x = Player.walkSpeed / 4;
        } else {
          velocity.x = -Player.walkSpeed / 4;
        }
        animationTickers?[Ops.swing0]?.onComplete = () {
          setState(Ops.swing1);
          _sendSync();
        };
      }
    }
    _sendSync();
  }

  void shoot() {
    if (current == Ops.jump) return;
    _swinging = false;
    setState(Ops.shoot);
    velocity = Vector2.zero();
    _sendSync();
  }

  WeaponType changeWeapon() {
    WeaponType type = WeaponType.none;
    if (sword.isVisible) {
      sword.isVisible = false;
      bow.isVisible = true;
      type = WeaponType.bow;
    } else if (bow.isVisible) {
      bow.isVisible = false;
      type = WeaponType.none;
    } else {
      sword.isVisible = true;
      type = WeaponType.sword;
    }
    _sendSync();
    return type;
  }
}
