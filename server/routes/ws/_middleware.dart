import 'package:dart_frog/dart_frog.dart';
import 'package:server/level_worker.dart';

final _levelWorker = LevelWorker();

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<LevelWorker>((_) => _levelWorker));
}
