import 'package:server/lock_worker.dart';

LockWorker? _worker;

/// wrap lock worker
class LevelWorker {
  int _ref = 0;

  /// begin per channel
  Future<void> begin() async {
    _worker ??= await LockWorker.spawn();
    _ref++;
  }

  /// main work
  Future<Object?> work(int channel, String message) async {
    return _worker!.work(channel, message);
  }

  /// end per channel
  void end() {
    if (--_ref == 0) {
      _worker?.close();
      _worker = null;
    }
  }
}
