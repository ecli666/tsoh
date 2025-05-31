import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HpBar extends PositionComponent {
  HpBar({required this.maxHp, required this.currentHp, super.priority})
    : super(anchor: Anchor.bottomCenter);

  late final RectangleComponent _bgBar;
  late final RectangleComponent _currentBar;
  final int maxHp;
  int currentHp;
  final double _maxWidth = 15;

  @override
  Future<void> onLoad() async {
    await addAll([
      _bgBar = RectangleComponent(
        priority: priority + 1,
        size: Vector2(_maxWidth, 3),
        anchor: Anchor.bottomLeft,
        position: Vector2(8, 6),
        paint: Paint()..color = Color.fromARGB(255, 255, 16, 16),
      ),
      _currentBar = RectangleComponent(
        priority: priority + 2,
        size: Vector2(_maxWidth, 3),
        anchor: Anchor.bottomLeft,
        position: Vector2(8, 6),
        paint: Paint()..color = Color.fromARGB(255, 124, 255, 16),
      ),
    ]);
    _refresh();
  }

  void _refresh() {
    _currentBar.size.x = (currentHp / maxHp) * _maxWidth;
  }

  void hit() {
    if (--currentHp < 0) return;
    _refresh();
  }

  void flip() {
    flipHorizontally();
    if (isFlippedHorizontally) {
      _bgBar.position = Vector2(-25, 6);
      _currentBar.position = Vector2(-25, 6);
    } else {
      _bgBar.position = Vector2(8, 6);
      _currentBar.position = Vector2(8, 6);
    }
  }
}
