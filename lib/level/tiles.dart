import 'package:flame/components.dart' hide Block;
import 'package:tsoh/level/tiles/ground_tile.dart';

class Tiles extends Component {
  @override
  Future<void> onLoad() async {
    addAll([
      for (double i = 0; i < 40; i++)
        GroundTile(gridPosition: Vector2(i, 0), block: Block.ground2),
    ]);
    addAll([
      for (double i = 0; i < 40; i++)
        GroundTile(gridPosition: Vector2(i, 1), block: Block.ground1),
    ]);
    addAll([
      for (double i = 8; i < 25; i++)
        GroundTile(gridPosition: Vector2(i, 4), block: Block.ground1),
    ]);
  }
}
