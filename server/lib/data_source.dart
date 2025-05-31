import 'package:commons/commons.dart';

/// in memory user data
abstract class DataSource {
  /// check if contains key
  Future<bool> contains(String uuid);

  /// create with empty value
  Future<void> create(String uuid);

  /// read from map
  Future<UserData?> read(String uuid);

  /// update with new value
  Future<void> update(String uuid, UserData data);
}
