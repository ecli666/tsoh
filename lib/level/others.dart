import 'package:commons/commons.dart';
import 'package:flame/components.dart';
import 'package:tsoh/level/player/has_animations.dart';
import 'package:tsoh/level/player/other_player.dart';
import 'package:tsoh/level/player/player.dart';
import 'package:tsoh/tsoh_game.dart';

class Others extends Component with HasGameReference<TsohGame> {
  @override
  void onRemove() {
    children.whereType<OtherPlayer>().forEach(remove);
    super.onRemove();
  }

  Future<void> addOther(IdUserData other) async {
    final position = game.util.gridPositionToPosition(
      Vector2(other.user.gridX, other.user.gridY),
    );
    final otherPlayer = OtherPlayer(
      uuid: other.uuid,
      name: other.user.name,
      outfit: other.user.outfit == 0 ? 'outfit0' : 'outfit1',
      position: position,
    );
    await add(otherPlayer);
    if (other.user.isFlip) {
      otherPlayer.flip();
    }
    otherPlayer.setWeapon(WeaponType.values[other.user.weapon]);
  }

  void removeOther(String uuid) {
    children
        .where((child) => ((child as OtherPlayer).uuid == uuid))
        .forEach(remove);
  }

  void userSync(IdUserSync userSync) {
    final other = findOther(userSync.uuid);
    if (other != null) {
      final position = game.util.gridPositionToPosition(
        Vector2(userSync.gridX, userSync.gridY),
      );
      other.applyState(
        userSync.isFlip,
        WeaponType.values[userSync.weapon],
        position,
        Vector2(userSync.velX, userSync.velY),
        Ops.values[userSync.ops],
      );
    }
  }

  OtherPlayer? findOther(String uuid) {
    try {
      final other = children.firstWhere(
        (child) => ((child is OtherPlayer) && child.uuid == uuid),
      );
      return (other as OtherPlayer);
    } catch (_) {
      return null;
    }
  }
}
