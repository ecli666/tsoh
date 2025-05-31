import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tsoh/new/front_player.dart';
import 'package:tsoh/tsoh_game.dart';

class NewScene extends World with HasGameReference<TsohGame> {
  late final FrontPlayer _frontPlayer;

  @override
  Future<void> onLoad() async {
    final canvasSize = game.canvasSize;
    final bgSprite = await game.loadSprite('new/new_bg.png')
      ..paint.isAntiAlias = false;
    final recSize = TsohGame.chrFrontSize * 1.5;
    final recPosition = Vector2(
      canvasSize.x / 4 - recSize.x / 2,
      canvasSize.y / 2 - recSize.x / 2,
    );
    game.nextChr = nextChr;
    await game.images.loadAll(await _chrStream().toList());

    addAll([
      SpriteComponent(
        sprite: bgSprite,
        anchor: Anchor.topLeft,
        position: Vector2.zero(),
        size: canvasSize,
        priority: 1,
      ),
      RectangleComponent(
        anchor: Anchor.topLeft,
        position: recPosition,
        size: recSize,
        paint: Paint()..color = Color.fromARGB(100, 100, 100, 100),
        priority: 2,
      ),
      _frontPlayer = FrontPlayer(
        position: recPosition + TsohGame.chrFrontSize / 4,
        size: Vector2.all(64),
        priority: 5,
      ),
    ]);
  }

  @override
  void onMount() {
    game.chr = game.chr.copyWith(outfit: 0);
  }

  void nextChr() {
    _frontPlayer.nextChr();
    game.chr = game.chr.copyWith(outfit: game.chr.outfit == 0 ? 1 : 0);
  }

  Stream<String> _chrStream() async* {
    for (final fname in [0, 1].map((i) => 'chr/chr0-outfit$i-front.png')) {
      yield fname;
    }
  }
}
