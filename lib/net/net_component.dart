import 'dart:convert';
import 'dart:io';

import 'package:commons/commons.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsoh/level/level_scene.dart';
import 'package:tsoh/level/player/has_animations.dart';
import 'package:tsoh/level/player/player.dart';
import 'package:tsoh/start/start_scene.dart';
import 'package:tsoh/tsoh_game.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class NetComponent extends Component with HasGameReference<TsohGame> {
  final _addrHttp = 'http://localhost:8080/http/';
  final _uriWs = Uri.parse('ws://localhost:8080/ws/ws');
  late final WebSocketChannel _channel;
  late final SharedPreferences _prefs;
  bool _hasError = false;

  UserData? userData;

  @override
  Future<void> onLoad() async {
    _prefs = await SharedPreferences.getInstance();
    _channel = WebSocketChannel.connect(_uriWs);
    try {
      await _channel.ready.timeout(Duration(seconds: 2));
    } catch (e) {
      _hasError = true;
    }
    if (_hasError) return;
    _channel.stream.listen(
      _onData,
      onError: (e) => _hasError = true,
      onDone: () => _hasError = true, // disconnected
      cancelOnError: false,
    );
    final uuid = getUuid();
    final uriUuid = Uri.parse('${_addrHttp}uuid/$uuid');
    final response = await http.get(uriUuid);
    final newUuid = response.body.replaceAll('"', '');
    _prefs.setString('uuid', newUuid);
  }

  void _onData(dynamic dyn) {
    print(dyn);
    final subs = (dyn as String).split(';');
    if (subs.length != 2) return;
    final idx = int.parse(subs[0]);
    final cmd = NetCommand.values[idx];
    final data = subs[1];

    switch (cmd) {
      case NetCommand.requestOthers:
        final decoded = jsonDecode(data) as List<dynamic>;
        final others = <IdUserData>[];
        for (final dec in decoded) {
          others.add(IdUserData.fromJson(dec as Map<String, dynamic>));
        }
        getLevelScene()?.addOthers(others);

      case NetCommand.enterLevel:
        final decoded = jsonDecode(data) as List<dynamic>;
        final enemies = <IdPositionEnemy>[];
        for (final dec in decoded) {
          enemies.add(IdPositionEnemy.fromJson(dec as Map<String, dynamic>));
        }
        getLevelScene()?.enemiesByServer(enemies);

      case NetCommand.enterSomeone:
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        final other = IdUserData.fromJson(decoded);
        getLevelScene()?.others.addOther(other);

      case NetCommand.leaveSomeone:
        getLevelScene()?.others.removeOther(data);

      case NetCommand.userSync:
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        final userSync = IdUserSync.fromJson(decoded);
        getLevelScene()?.others.userSync(userSync);

      case NetCommand.enemyHit:
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        final enemySync = EnemyHitSync.fromJson(decoded);
        getLevelScene()?.hitEnemyByServer(enemySync);

      case NetCommand.leaveLevel:
      case NetCommand.disconnected:
    }
  }

  LevelScene? getLevelScene() {
    final world = (game.router.currentRoute as WorldRoute).world;
    if (world is LevelScene) {
      return world;
    }
    return null;
  }

  bool isConnected() {
    return !_hasError;
  }

  String getUuid() {
    return _prefs.getString('uuid') ?? "tsoh";
  }

  Future<void> requestUserData() async {
    if (_hasError) return;
    final uuid = getUuid();
    final uriUuid = Uri.parse('${_addrHttp}chr/$uuid');
    final response = await http.get(uriUuid);
    if (response.statusCode == HttpStatus.ok) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      userData = UserData.fromJson(decoded);
      game.chr = UserCommon.fromJson(decoded);
      final scene =
          (game.router.currentRoute as WorldRoute).world as StartScene;
      scene.refreshContinue();
    }
  }

  Future<void> newUserData(UserCommon common) async {
    final uuid = getUuid();
    final uriUuid = Uri.parse('${_addrHttp}chr/$uuid');
    final idUserData = IdUser(
      uuid: uuid,
      name: common.name,
      outfit: common.outfit,
    );
    final json = jsonEncode(idUserData);
    await http.put(uriUuid, body: json);
  }

  void requestOthers() {
    if (_hasError) return;
    _channel.sink.add('${NetCommand.requestOthers.index}; ');
  }

  void enterLevel(UserData user) {
    if (_hasError) return;
    final uuid = getUuid();
    final idUserData = IdUserData(uuid: uuid, user: user);
    final json = jsonEncode(idUserData);
    _channel.sink.add('${NetCommand.enterLevel.index};$json');
  }

  Future<void> leaveLevel(bool isFlip, WeaponType weapon, Vector2 pos) async {
    if (_hasError) return;
    final uuid = getUuid();
    final gridPosition = game.util.positionToGridPosition(pos);
    final idUserStatus = IdUserStatus(
      uuid: uuid,
      isFlip: isFlip,
      weapon: weapon.index,
      gridX: gridPosition.x,
      gridY: gridPosition.y,
    );
    final json = jsonEncode(idUserStatus);
    final uriUuid = Uri.parse('${_addrHttp}chr/$uuid');
    await http.post(uriUuid, body: json);
    _channel.sink.add('${NetCommand.leaveLevel.index};$uuid');
  }

  void sendUserSync(
    bool isFlip,
    WeaponType weapon,
    Vector2 pos,
    Vector2 vel,
    Ops ops,
  ) {
    if (_hasError) return;
    final uuid = getUuid();
    final gridPosition = game.util.positionToGridPosition(pos);
    final idUserSync = IdUserSync(
      uuid: uuid,
      isFlip: isFlip,
      weapon: weapon.index,
      gridX: gridPosition.x,
      gridY: gridPosition.y,
      velX: vel.x,
      velY: vel.y,
      ops: ops.index,
    );
    final json = jsonEncode(idUserSync);
    _channel.sink.add('${NetCommand.userSync.index};$json');
  }

  void sendEnemyHitSync(
    bool isFlip,
    String attackerUuid,
    String slimeUuid,
    Vector2 pos,
  ) {
    if (_hasError) return;
    final gridPosition = game.util.positionToGridPosition(pos);
    final enemyHitSync = EnemyHitSync(
      isFlip: isFlip,
      attackerUuid: attackerUuid,
      slimeUuid: slimeUuid,
      gridX: gridPosition.x,
      gridY: gridPosition.y,
    );
    final json = jsonEncode(enemyHitSync);
    _channel.sink.add('${NetCommand.enemyHit.index};$json');
  }

  void close() {
    if (_hasError) return;
    _channel.sink.close();
    _hasError = true;
  }
}
