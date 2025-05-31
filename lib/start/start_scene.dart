import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:tsoh/start/rounded_button.dart';
import 'package:tsoh/tsoh_game.dart';

class StartScene extends World with HasGameReference<TsohGame> {
  RoundedButton? _continueButton;

  @override
  Future<void> onLoad() async {
    final canvasSize = game.canvasSize;
    final bgSprite1 = await game.loadSprite('start/start_bg1.png')
      ..paint.isAntiAlias = false;
    final bgSprite2 = await game.loadSprite('start/start_bg2.png')
      ..paint.isAntiAlias = false;
    final parallax = await game.loadParallaxComponent(
      [ParallaxImageData('start/clouds.png')],
      baseVelocity: Vector2(6, 0),
      fill: LayerFill.width,
      filterQuality: FilterQuality.none,
      priority: 1,
      alignment: Alignment.topLeft,
      position: Vector2(0, 0),
    );
    addAll([
      SpriteComponent(
        sprite: bgSprite1,
        anchor: Anchor.topLeft,
        position: Vector2.zero(),
        size: canvasSize,
        autoResize: false,
      ),
      parallax,
      SpriteComponent(
        sprite: bgSprite2,
        anchor: Anchor.topLeft,
        position: Vector2.zero(),
        size: canvasSize,
        autoResize: false,
        priority: 2,
      ),
    ]);
    if (!game.net.isConnected()) {
      addAll([
        TextComponent(
          text: 'Not Connected..',
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 118, 0, 0),
              fontWeight: FontWeight.bold,
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          anchor: Anchor.center,
          position: Vector2(canvasSize.x / 2 + 160, canvasSize.y / 3 + 220),
        ),
      ]);
    }
  }

  @override
  void onMount() {
    game.net.requestUserData();
    super.onMount();
    game.overlays.remove('gen-l10n');
  }

  void refreshContinue() {
    if (game.net.userData != null) {
      add(_continueButton!);
    }
  }

  void l10nLoad() {
    final canvasSize = game.canvasSize;
    addAll([
      TextComponent(
        text: game.trTitle,
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 64,
            color: Color.fromARGB(255, 171, 70, 7),
            fontWeight: FontWeight.w700,
            fontFamily: 'gamja',
            shadows: [
              Shadow(
                color: Color.fromARGB(255, 252, 17, 0),
                offset: Offset(2, 2),
                blurRadius: 3,
              ),
              Shadow(
                color: Color.fromARGB(255, 255, 249, 195),
                offset: Offset(4, 4),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        position: Vector2(canvasSize.x / 2, canvasSize.y / 3),
        anchor: Anchor.center,
        children: [
          ScaleEffect.to(
            Vector2.all(1.04),
            EffectController(duration: 1.6, alternate: true, infinite: true),
          ),
        ],
        priority: 3,
      ),
      RoundedButton(
        text: game.trNewGame!,
        action: () {
          game.router.pushNamed('new');
          game.overlays.add('chr-edit');
        },
        position: Vector2(canvasSize.x / 2, canvasSize.y / 3 + 100),
        color: const Color(0xffadde6c),
        borderColor: const Color(0xffedffab),
      ),
    ]);
    _continueButton = RoundedButton(
      text: game.trContinue!,
      action: () {
        game.router.pushNamed('level');
      },
      position: Vector2(canvasSize.x / 2, canvasSize.y / 3 + 160),
      color: const Color(0xffadde6c),
      borderColor: const Color(0xffedffab),
    );
    if (!game.net.isConnected()) {
      add(_continueButton!);
    }
  }
}
