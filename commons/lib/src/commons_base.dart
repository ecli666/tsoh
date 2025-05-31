import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'commons_base.g.dart';

enum NetCommand {
  requestOthers,
  enterLevel,
  leaveLevel,
  enterSomeone,
  leaveSomeone,
  userSync,
  enemyHit,
  disconnected,
}

@immutable
@JsonSerializable()
class UserCommon {
  UserCommon({required this.name, required this.outfit});
  final String name;
  final int outfit;

  factory UserCommon.fromJson(Map<String, dynamic> json) =>
      _$UserCommonFromJson(json);

  Map<String, dynamic> toJson() => _$UserCommonToJson(this);

  UserCommon copyWith({String? name, int? outfit}) {
    return UserCommon(name: name ?? this.name, outfit: outfit ?? this.outfit);
  }
}

@immutable
@JsonSerializable()
class UserData extends UserCommon {
  UserData({
    required super.name,
    required super.outfit,
    required this.isFlip,
    required this.weapon,
    required this.gridX,
    required this.gridY,
  });
  final bool isFlip;
  final int weapon;
  final double gridX, gridY;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserDataToJson(this);

  @override
  UserData copyWith({
    String? name,
    int? outfit,
    bool? isFlip,
    int? weapon,
    double? gridX,
    double? gridY,
  }) {
    return UserData(
      name: name ?? this.name,
      outfit: outfit ?? this.outfit,
      isFlip: isFlip ?? this.isFlip,
      weapon: weapon ?? this.weapon,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
    );
  }
}

@immutable
@JsonSerializable(explicitToJson: true)
class IdUserData {
  IdUserData({required this.uuid, required this.user});

  final String uuid;
  final UserData user;

  factory IdUserData.fromJson(Map<String, dynamic> json) =>
      _$IdUserDataFromJson(json);

  Map<String, dynamic> toJson() => _$IdUserDataToJson(this);
}

@immutable
@JsonSerializable()
class IdUser extends UserCommon {
  IdUser({required this.uuid, required super.name, required super.outfit});
  final String uuid;

  factory IdUser.fromJson(Map<String, dynamic> json) => _$IdUserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IdUserToJson(this);
}

base class IdPosition {
  IdPosition({required this.uuid, required this.gridX, required this.gridY});
  final String uuid;
  double gridX;
  double gridY;
}

@JsonSerializable()
final class IdPositionEnemy extends IdPosition {
  IdPositionEnemy({
    required super.uuid,
    required this.isFlip,
    required this.life,
    required super.gridX,
    required super.gridY,
    this.attackerUuid,
  });
  bool isFlip;
  int life;
  String? attackerUuid;

  factory IdPositionEnemy.fromJson(Map<String, dynamic> json) =>
      _$IdPositionEnemyFromJson(json);

  Map<String, dynamic> toJson() => _$IdPositionEnemyToJson(this);
}

@JsonSerializable()
final class IdUserStatus extends IdPosition {
  IdUserStatus({
    required super.uuid,
    required this.isFlip,
    required this.weapon,
    required super.gridX,
    required super.gridY,
  });
  final bool isFlip;
  final int weapon;

  factory IdUserStatus.fromJson(Map<String, dynamic> json) =>
      _$IdUserStatusFromJson(json);

  Map<String, dynamic> toJson() => _$IdUserStatusToJson(this);
}

@JsonSerializable()
final class IdUserSync extends IdUserStatus {
  IdUserSync({
    required super.uuid,
    required super.isFlip,
    required super.weapon,
    required super.gridX,
    required super.gridY,
    required this.velX,
    required this.velY,
    required this.ops,
  });
  final double velX, velY;
  final int ops;

  factory IdUserSync.fromJson(Map<String, dynamic> json) =>
      _$IdUserSyncFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IdUserSyncToJson(this);
}

@immutable
@JsonSerializable()
class EnemyHitSync {
  EnemyHitSync({
    required this.isFlip,
    required this.attackerUuid,
    required this.slimeUuid,
    required this.gridX,
    required this.gridY,
  });
  final bool isFlip;
  final String attackerUuid;
  final String slimeUuid;
  final double gridX, gridY;

  factory EnemyHitSync.fromJson(Map<String, dynamic> json) =>
      _$EnemyHitSyncFromJson(json);

  Map<String, dynamic> toJson() => _$EnemyHitSyncToJson(this);
}
