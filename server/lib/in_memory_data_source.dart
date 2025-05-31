import 'package:commons/commons.dart';
import 'package:server/data_source.dart';

/// in memory user data
class InMemoryDataSource implements DataSource {
  final _cache = <String, UserData?>{};

  @override
  Future<bool> contains(String uuid) async => _cache.containsKey(uuid);

  @override
  Future<void> create(String uuid) async => _cache[uuid] = null;

  @override
  Future<UserData?> read(String uuid) async => _cache[uuid];

  @override
  Future<void> update(String uuid, UserData data) async =>
      _cache.update(uuid, (value) => data);
}
