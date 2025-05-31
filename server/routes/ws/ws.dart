import 'dart:async';

import 'package:commons/commons.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:server/level_worker.dart';

final _broadcast = <WebSocketChannel>[];

Future<Response> onRequest(RequestContext context) async {
  final levelWorker = context.read<LevelWorker>();
  await levelWorker.begin();

  final handler = webSocketHandler((channel, protocol) async {
    // A new client has connected to our server.
    print('connected');
    _broadcast.add(channel);

    // Listen for messages from the client.
    channel.stream.listen(
      (dyn) async {
        print(dyn);
        final subs = (dyn as String).split(';');
        if (subs.length != 2) return;
        final idx = int.parse(subs[0]);
        final cmd = NetCommand.values[idx];
        final data = subs[1];

        switch (cmd) {
          case NetCommand.requestOthers:
            final jsonOthers = await levelWorker.work(channel.hashCode, dyn);
            channel.sink.add('${NetCommand.requestOthers.index};$jsonOthers');

          case NetCommand.enterLevel:
            final json = await levelWorker.work(channel.hashCode, dyn);
            channel.sink.add('${NetCommand.enterLevel.index};$json');
            final cont = '${NetCommand.enterSomeone.index};$data';
            broadcasts(channel, cont);

          case NetCommand.leaveLevel:
            await levelWorker.work(channel.hashCode, dyn);
            final cont = '${NetCommand.leaveSomeone.index};$data';
            broadcasts(channel, cont);

          case NetCommand.userSync:
            await levelWorker.work(channel.hashCode, dyn);
            broadcasts(channel, dyn);

          case NetCommand.enemyHit:
            await levelWorker.work(channel.hashCode, dyn);
            broadcasts(channel, dyn);

          case NetCommand.enterSomeone:
          case NetCommand.leaveSomeone:
          case NetCommand.disconnected:
        }
      },
      // The client has disconnected.
      onDone: () async {
        _broadcast.remove(channel);
        final cmd = '${NetCommand.disconnected.index}; ';
        final uuid = await levelWorker.work(channel.hashCode, cmd);
        final cont = '${NetCommand.leaveSomeone.index};$uuid';
        broadcasts(channel, cont);
        levelWorker.end();
        print('disconnected');
      },
    );
  });

  return handler(context);
}

void broadcasts(WebSocketChannel me, String cont) {
  for (final chan in _broadcast) {
    if ((chan != me) && (chan.closeCode == null)) {
      chan.sink.add(cont);
    }
  }
}
