import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:tsoh/level/buttons/direction_button_component.dart';
import 'package:tsoh/level/level_scene.dart';
import 'package:tsoh/level/player/player.dart';
import 'package:tsoh/tsoh_game.dart';

class Hud extends Component with HasGameReference<TsohGame> {
  late final DirectionButtonComponent _swordSwingButton;
  late final DirectionButtonComponent _bowShootButton;

  @override
  Future<void> onLoad() async {
    final canvasSize = game.canvasSize;
    final buttonSize = Vector2.all(64);
    final buttonYPos = canvasSize.y - buttonSize.y - 10;
    final leftPosition = Vector2(40, buttonYPos);
    final rightPosition = Vector2(90 + buttonSize.x * 2, buttonYPos);
    final jumpPosition = Vector2(
      canvasSize.x - (buttonSize.x + 160),
      buttonYPos,
    );
    final attackPosition = Vector2(
      canvasSize.x - (buttonSize.x + 60),
      buttonYPos,
    );
    final settingPosition = Vector2(canvasSize.x - (buttonSize.x + 10), 10);
    final inventoryPosition = Vector2(
      canvasSize.x - (buttonSize.x * 2 + 20),
      10,
    );
    final scene = (game.router.currentRoute as WorldRoute).world as LevelScene;

    _swordSwingButton = DirectionButtonComponent(
      downAction: () => scene.myPlayer.swing(),
      upAction: null,
      imageName: 'level/sword_swing_button.png',
      position: attackPosition,
      size: buttonSize,
    );
    _bowShootButton = DirectionButtonComponent(
      downAction: () => scene.myPlayer.shoot(),
      upAction: null,
      imageName: 'level/bow_shoot_button.png',
      position: attackPosition,
      size: buttonSize,
    );
    await addAll([
      DirectionButtonComponent(
        downAction: () => scene.myPlayer.moveLeftStart(),
        upAction: () => scene.myPlayer.moveLeftStop(),
        imageName: 'level/direction_button.png',
        position: leftPosition,
        size: buttonSize,
      ),
      DirectionButtonComponent(
        downAction: () => scene.myPlayer.moveRightStart(),
        upAction: () => scene.myPlayer.moveRightStop(),
        imageName: 'level/direction_button.png',
        position: rightPosition,
        size: buttonSize,
      )..flipHorizontally(),
      DirectionButtonComponent(
        downAction: () => scene.myPlayer.jump(),
        upAction: null,
        imageName: 'level/jump_button.png',
        position: jumpPosition,
        size: buttonSize,
      ),
      SpriteButtonComponent(
        button: await game.loadSprite(
            'level/back_to_start.png',
            srcSize: Vector2.all(32),
          )
          ..paint.isAntiAlias = false,
        buttonDown: await game.loadSprite(
            'level/back_to_start.png',
            srcPosition: Vector2(32, 0),
            srcSize: Vector2.all(32),
          )
          ..paint.isAntiAlias = false,
        position: settingPosition,
        size: buttonSize,
        onPressed: () async {
          await scene.leaveLevel();
          game.router.popUntilNamed('start');
        },
      ),
      SpriteButtonComponent(
        button: await game.loadSprite(
            'level/cycle_weapon.png',
            srcSize: Vector2.all(32),
          )
          ..paint.isAntiAlias = false,
        buttonDown: await game.loadSprite(
            'level/cycle_weapon.png',
            srcPosition: Vector2(32, 0),
            srcSize: Vector2.all(32),
          )
          ..paint.isAntiAlias = false,
        position: inventoryPosition,
        size: buttonSize,
        onPressed: () => scene.cycleWeapon(),
      ),
    ]);
  }

  @override
  void onMount() {
    if (game.net.userData != null) {
      refreshAttackButton(WeaponType.values[game.net.userData!.weapon]);
    }
  }

  void _swingButtonControl(bool show) {
    if (show) {
      add(_swordSwingButton);
    } else {
      if (children.contains(_swordSwingButton)) {
        remove(_swordSwingButton);
      }
    }
  }

  void _shootButtonControl(bool show) {
    if (show) {
      add(_bowShootButton);
    } else {
      if (children.contains(_bowShootButton)) {
        remove(_bowShootButton);
      }
    }
  }

  void refreshAttackButton(WeaponType weapon) {
    switch (weapon) {
      case WeaponType.none:
        _swingButtonControl(false);
        _shootButtonControl(false);
        break;
      case WeaponType.sword:
        _swingButtonControl(true);
        _shootButtonControl(false);
        break;
      case WeaponType.bow:
        _swingButtonControl(false);
        _shootButtonControl(true);
        break;
    }
  }
}
