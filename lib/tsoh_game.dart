import 'dart:io';

import 'package:commons/commons.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:tsoh/level/level_scene.dart';
import 'package:tsoh/net/net_component.dart';
import 'package:tsoh/new/new_scene.dart';
import 'package:tsoh/start/start_scene.dart';
import 'package:tsoh/util/grid_util.dart';

class TsohGame extends FlameGame with HasCollisionDetection {
  static const scale = 2.0;
  static var chrFrontSize = Vector2.all(32) * scale;
  static const gravity = 1520;
  static const dropVelocity = 200.0;

  final TextEditingController nameController = TextEditingController();

  void Function()? nextChr;
  UserCommon chr = UserCommon(name: "", outfit: 0);

  late final RouterComponent router;
  late final NetComponent net;
  late final GridUtil util;

  String? trTitle;
  String? trNewGame;
  String? trContinue;
  String? trName;
  String? trBack;
  String? trChrName;
  String? trGameStart;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    if (Platform.isIOS) {
      camera.viewport = FixedResolutionViewport(resolution: canvasSize);
    }
    await addAll([util = GridUtil(), net = NetComponent()]);
    add(
      router = RouterComponent(
        routes: {
          'start': WorldRoute(StartScene.new, maintainState: false),
          'new': WorldRoute(NewScene.new, maintainState: false),
          'level': WorldRoute(LevelScene.new, maintainState: false),
        },
        initialRoute: 'start',
      ),
    );
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('music/oriental-mandolin.mp3', volume: 0.008);
  }

  @override
  void onDispose() {
    net.close();
    nameController.dispose();
    super.onDispose();
  }

  void l10nLoaded() {
    final world = (router.currentRoute as WorldRoute).world;
    if (world is StartScene) {
      world.l10nLoad();
    }
  }
}
