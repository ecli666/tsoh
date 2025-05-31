import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:tsoh/new/chr_edit.dart';
import 'package:tsoh/start/load_l10n.dart';
import 'package:tsoh/tsoh_game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  runApp(
    SafeArea(
      child: GameWidget<TsohGame>.controlled(
        gameFactory: TsohGame.new,
        overlayBuilderMap: {
          'gen-l10n': (_, game) => LoadL10n(game: game),
          'chr-edit': (_, game) => ChrEdit(game: game),
        },
        initialActiveOverlays: const ['gen-l10n'],
      ),
    ),
  );
}
