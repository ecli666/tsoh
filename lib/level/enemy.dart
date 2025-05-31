import 'package:commons/commons.dart';
import 'package:flame/components.dart';
import 'package:tsoh/level/enemy/slime.dart';
import 'package:tsoh/level/level_scene.dart';
import 'package:tsoh/tsoh_game.dart';
import 'package:uuid/uuid.dart';

class Enemy extends Component
    with HasGameReference<TsohGame>, HasWorldReference<LevelScene> {
  static const name = 'persimmon';

  @override
  Future<void> onLoad() async {
    if (!game.net.isConnected()) {
      _addSlimes([Vector2(11, 2), Vector2(16, 2), Vector2(18, 5)]);
    }
  }

  @override
  void onRemove() {
    if (game.net.isConnected()) {
      children.whereType<Slime>().forEach(remove);
    }
    super.onRemove();
  }

  void _addSlimes(List<Vector2> gridPositions) {
    for (final gridPosition in gridPositions) {
      final position = game.util.gridPositionToPosition(gridPosition);
      add(
        Slime(
          uuid: const Uuid().v4(),
          name: name,
          isFlip: false,
          life: 5,
          position: position,
        ),
      );
    }
  }

  void addSlimesByServer(List<IdPositionEnemy> slimes) {
    for (final slime in slimes) {
      final position = game.util.gridPositionToPosition(
        Vector2(slime.gridX, slime.gridY),
      );
      add(
        Slime(
          uuid: slime.uuid,
          name: name,
          isFlip: slime.isFlip,
          life: slime.life,
          position: position,
          attackerUuid: slime.attackerUuid,
        ),
      );
    }
  }

  void hit(bool isFlip, PositionComponent attacker, String uuid) {
    try {
      final comp = children.firstWhere(
        (child) => ((child is Slime) && (child.uuid == uuid)),
      );
      (comp as Slime).hit(isFlip, attacker);
    } catch (_) {}
  }

  void setPosition(String uuid, Vector2 position) {
    try {
      final comp = children.firstWhere(
        (child) => ((child is Slime) && (child.uuid == uuid)),
      );
      (comp as Slime).position = position;
    } catch (_) {}
  }
}
