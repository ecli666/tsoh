import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:commons/commons.dart';
import 'package:synchronized/synchronized.dart';
import 'package:uuid/uuid.dart';

final _broadcast = <int, IdUserData>{};
final _enemies = [
  IdPositionEnemy(
    uuid: const Uuid().v4(),
    gridX: 11,
    gridY: 2,
    isFlip: false,
    life: 5,
  ),
  IdPositionEnemy(
    uuid: const Uuid().v4(),
    gridX: 16,
    gridY: 2,
    isFlip: false,
    life: 5,
  ),
  IdPositionEnemy(
    uuid: const Uuid().v4(),
    gridX: 18,
    gridY: 5,
    isFlip: false,
    life: 5,
  ),
];
final _lock = Lock();

/// worker with synchronize
class LockWorker {
  LockWorker._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<Object?>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  /// work..
  Future<Object?> work(int channel, String message) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer<Object?>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, channel, message));
    return completer.future;
  }

  /// spawn new isolate
  static Future<LockWorker> spawn() async {
    // Create a receive port and add its initial message handler
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (SendPort initialMessage) {
      final commandPort = initialMessage;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate, initPort.sendPort);
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    return LockWorker._(receivePort, sendPort);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final (int id, Object? response) = message as (int, Object?);
    final completer = _activeRequests.remove(id)!;

    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      completer.complete(response);
    }

    if (_closed && _activeRequests.isEmpty) _responses.close();
  }

  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) {
    receivePort.listen((message) async {
      if (message == 'shutdown') {
        receivePort.close();
        return;
      }
      final (id, channel, dyn) = message as (int, int, String);
      final subs = dyn.split(';');
      if (subs.length != 2) return;
      final idx = int.parse(subs[0]);
      final cmd = NetCommand.values[idx];
      final data = subs[1];
      try {
        switch (cmd) {
          case NetCommand.requestOthers:
            final jsonData = await _lock.synchronized(() async {
              final others = <IdUserData>[];
              _broadcast.forEach((chan, idUserData) => others.add(idUserData));
              return jsonEncode(others);
            });
            sendPort.send((id, jsonData));

          case NetCommand.enterLevel:
            final jsonData = await _lock.synchronized(() async {
              final decoded = jsonDecode(data) as Map<String, dynamic>;
              final idUserData = IdUserData.fromJson(decoded);
              _broadcast[channel] = idUserData;
              return jsonEncode(_enemies);
            });
            sendPort.send((id, jsonData));

          case NetCommand.leaveLevel:
            await _lock.synchronized(() async {
              _broadcast.remove(channel);
            });
            sendPort.send((id, null));

          case NetCommand.userSync:
            await _lock.synchronized(() async {
              final rdData = _broadcast[channel];
              if (rdData != null) {
                final decoded = jsonDecode(data) as Map<String, dynamic>;
                final idSync = IdUserSync.fromJson(decoded);
                final updated = rdData.user.copyWith(
                  isFlip: idSync.isFlip,
                  weapon: idSync.weapon,
                  gridX: idSync.gridX,
                  gridY: idSync.gridY,
                );
                final idUserData = IdUserData(uuid: idSync.uuid, user: updated);
                _broadcast[channel] = idUserData;
              }
            });
            sendPort.send((id, null));

          case NetCommand.enemyHit:
            await _lock.synchronized(() async {
              final decoded = jsonDecode(data) as Map<String, dynamic>;
              final enemyHitSync = EnemyHitSync.fromJson(decoded);
              final enemy =
                  _enemies.firstWhere(
                      (enemy) => enemy.uuid == enemyHitSync.slimeUuid,
                    )
                    ..attackerUuid = enemyHitSync.attackerUuid
                    ..isFlip = !enemyHitSync.isFlip
                    ..gridX = enemyHitSync.gridX
                    ..gridY = enemyHitSync.gridY;
              --enemy.life;
              if (enemy.life == 0) {
                _enemies.remove(enemy);
              }
            });
            sendPort.send((id, null));

          case NetCommand.disconnected:
            final uuid = await _lock.synchronized(() async {
              final id = _broadcast[channel]?.uuid;
              _broadcast.remove(channel);
              return id;
            });
            sendPort.send((id, uuid));

          case NetCommand.enterSomeone:
          case NetCommand.leaveSomeone:
        }
      } catch (e) {
        sendPort.send((id, RemoteError(e.toString(), '')));
      }
    });
  }

  static void _startRemoteIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort, sendPort);
  }

  /// close worker
  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_activeRequests.isEmpty) _responses.close();
      print('--- port closed --- ');
    }
  }
}
