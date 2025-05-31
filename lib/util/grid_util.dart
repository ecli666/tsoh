import 'package:flame/components.dart';

final class GridUtil extends Component with HasGameReference {
  static final Vector2 _tileImageSize = Vector2.all(16);
  static const double _tileScale = 3;

  Vector2 positionToGridPosition(Vector2 pos) {
    return Vector2(
      pos.x / _tileImageSize.x / _tileScale,
      (game.canvasSize.y - pos.y) / _tileImageSize.y / _tileScale,
    );
  }

  Vector2 gridPositionToPosition(Vector2 pos) {
    return Vector2(
      pos.x * _tileImageSize.x * _tileScale,
      game.canvasSize.y - (pos.y * _tileImageSize.y * _tileScale),
    );
  }
}
