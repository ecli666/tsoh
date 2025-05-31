import 'package:commons/commons.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:tsoh/level/backgrounds.dart';
import 'package:tsoh/level/enemy.dart';
import 'package:tsoh/level/enemy/slime.dart';
import 'package:tsoh/level/hud.dart';
import 'package:tsoh/level/others.dart';
import 'package:tsoh/level/player/my_player.dart';
import 'package:tsoh/level/player/player.dart';
import 'package:tsoh/level/tiles.dart';
import 'package:tsoh/tsoh_game.dart';

class LevelScene extends World with HasGameReference<TsohGame> {
  late final Backgrounds _backgrounds;
  late final ParallaxComponent _parallax;
  late final Hud _hud;
  late final Enemy _enemy;
  late final MyPlayer myPlayer;
  late final Others others;

  final _maxDistance = 56.0;
  late final Vector2 _offsetToCamera;
  late final double _initialHeight;

  @override
  Future<void> onLoad() async {
    _initialHeight = game.canvasSize.y - 96;
    _offsetToCamera = Vector2(game.canvasSize.x / 2, _initialHeight);

    _backgrounds = Backgrounds();
    _parallax = await game.loadParallaxComponent(
      [ParallaxImageData('level/level_clouds.png')],
      baseVelocity: Vector2(12, 0),
      fill: LayerFill.none,
      filterQuality: FilterQuality.none,
      priority: 1,
      alignment: Alignment.topLeft,
      position: Vector2(0, 0),
    );
    _hud = Hud();

    await addAll([
      Tiles()..priority = 10,
      _enemy = Enemy()..priority = 30,
      myPlayer = MyPlayer(
        uuid: game.net.getUuid(),
        name: game.chr.name,
        outfit: game.chr.outfit == 0 ? 'outfit0' : 'outfit1',
        position: Vector2.zero(),
      ),
      others = Others()..priority = 50,
    ]);
  }

  @override
  void update(double dt) {
    Vector2 offset = myPlayer.position - _offsetToCamera;
    if (offset.x < 0) offset.x = 0;
    game.camera.moveTo(offset);
  }

  @override
  void onMount() {
    if (game.net.userData != null) {
      if (game.net.userData!.isFlip) {
        myPlayer.flip();
      }
      myPlayer.setWeapon(WeaponType.values[game.net.userData!.weapon]);
      Vector2 pos = Vector2(game.net.userData!.gridX, game.net.userData!.gridY);
      if (pos.x == 0 && pos.y == 0) {
        pos = Vector2(250, _initialHeight);
      } else {
        pos = game.util.gridPositionToPosition(pos);
      }
      myPlayer.position = pos;
    } else {
      myPlayer.flip();
      myPlayer.position = Vector2(250, _initialHeight);
    }
    game.net.requestOthers();
    game.camera.backdrop.add(_backgrounds);
    game.camera.backdrop.add(_parallax);
    game.camera.viewport.add(_hud);
    super.onMount();
  }

  @override
  void onRemove() {
    game.camera.backdrop.remove(_parallax);
    game.camera.backdrop.remove(_backgrounds);
    game.camera.viewport.remove(_hud);
    game.camera.moveTo(Vector2.zero());
    super.onRemove();
  }

  Future<void> leaveLevel() async {
    await game.net.leaveLevel(
      myPlayer.isFlippedHorizontally,
      myPlayer.getWeapon(),
      myPlayer.position,
    );
  }

  Future<void> addOthers(List<IdUserData> others) async {
    for (final other in others) {
      await this.others.addOther(other);
    }
    final gridPosition = game.util.positionToGridPosition(myPlayer.position);
    game.net.enterLevel(
      UserData(
        name: game.chr.name,
        outfit: game.chr.outfit,
        isFlip: myPlayer.isFlippedHorizontally,
        weapon: myPlayer.getWeapon().index,
        gridX: gridPosition.x,
        gridY: gridPosition.y,
      ),
    );
  }

  void enemiesByServer(List<IdPositionEnemy> idPositionEnemy) {
    _enemy.addSlimesByServer(idPositionEnemy);
  }

  void hitCheck() {
    final isFlip = myPlayer.isFlippedHorizontally;
    final ray =
        isFlip
            ? Ray2(
              origin: myPlayer.position + Vector2(0, -17),
              direction: Vector2(1, 0),
            )
            : Ray2(
              origin: myPlayer.position + Vector2(0, -17),
              direction: Vector2(-1, 0),
            );
    final result = RaycastResult<ShapeHitbox>();
    game.collisionDetection.raycast(
      ray,
      maxDistance: _maxDistance,
      hitboxFilter: (hitbox) => hitbox.parent is Slime,
      ignoreHitboxes: [myPlayer.rectBox],
      out: result,
    );
    if ((result.isActive) &&
        (result.hitbox != null) &&
        (result.hitbox?.parent is Slime)) {
      final slime = result.hitbox?.parent as Slime;
      hitEnemy(isFlip, myPlayer.uuid, slime);
    }
  }

  void hitEnemy(bool isFlip, String attackerUuid, Slime slime) {
    if (attackerUuid != myPlayer.uuid) return;
    _enemy.hit(isFlip, myPlayer, slime.uuid);
    game.net.sendEnemyHitSync(isFlip, attackerUuid, slime.uuid, slime.position);
  }

  void hitEnemyByServer(EnemyHitSync sync) {
    final other = others.findOther(sync.attackerUuid);
    if (other != null) {
      _enemy.hit(sync.isFlip, other, sync.slimeUuid);
    }
    final position = game.util.gridPositionToPosition(
      Vector2(sync.gridX, sync.gridY),
    );
    _enemy.setPosition(sync.slimeUuid, position);
  }

  void cycleWeapon() {
    final weapon = myPlayer.changeWeapon();
    _hud.refreshAttackButton(weapon);
  }
}
