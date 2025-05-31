// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commons_base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserCommon _$UserCommonFromJson(Map<String, dynamic> json) => UserCommon(
  name: json['name'] as String,
  outfit: (json['outfit'] as num).toInt(),
);

Map<String, dynamic> _$UserCommonToJson(UserCommon instance) =>
    <String, dynamic>{'name': instance.name, 'outfit': instance.outfit};

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
  name: json['name'] as String,
  outfit: (json['outfit'] as num).toInt(),
  isFlip: json['isFlip'] as bool,
  weapon: (json['weapon'] as num).toInt(),
  gridX: (json['gridX'] as num).toDouble(),
  gridY: (json['gridY'] as num).toDouble(),
);

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
  'name': instance.name,
  'outfit': instance.outfit,
  'isFlip': instance.isFlip,
  'weapon': instance.weapon,
  'gridX': instance.gridX,
  'gridY': instance.gridY,
};

IdUserData _$IdUserDataFromJson(Map<String, dynamic> json) => IdUserData(
  uuid: json['uuid'] as String,
  user: UserData.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$IdUserDataToJson(IdUserData instance) =>
    <String, dynamic>{'uuid': instance.uuid, 'user': instance.user.toJson()};

IdUser _$IdUserFromJson(Map<String, dynamic> json) => IdUser(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  outfit: (json['outfit'] as num).toInt(),
);

Map<String, dynamic> _$IdUserToJson(IdUser instance) => <String, dynamic>{
  'name': instance.name,
  'outfit': instance.outfit,
  'uuid': instance.uuid,
};

IdPositionEnemy _$IdPositionEnemyFromJson(Map<String, dynamic> json) =>
    IdPositionEnemy(
      uuid: json['uuid'] as String,
      isFlip: json['isFlip'] as bool,
      life: (json['life'] as num).toInt(),
      gridX: (json['gridX'] as num).toDouble(),
      gridY: (json['gridY'] as num).toDouble(),
      attackerUuid: json['attackerUuid'] as String?,
    );

Map<String, dynamic> _$IdPositionEnemyToJson(IdPositionEnemy instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'gridX': instance.gridX,
      'gridY': instance.gridY,
      'isFlip': instance.isFlip,
      'life': instance.life,
      'attackerUuid': instance.attackerUuid,
    };

IdUserStatus _$IdUserStatusFromJson(Map<String, dynamic> json) => IdUserStatus(
  uuid: json['uuid'] as String,
  isFlip: json['isFlip'] as bool,
  weapon: (json['weapon'] as num).toInt(),
  gridX: (json['gridX'] as num).toDouble(),
  gridY: (json['gridY'] as num).toDouble(),
);

Map<String, dynamic> _$IdUserStatusToJson(IdUserStatus instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'gridX': instance.gridX,
      'gridY': instance.gridY,
      'isFlip': instance.isFlip,
      'weapon': instance.weapon,
    };

IdUserSync _$IdUserSyncFromJson(Map<String, dynamic> json) => IdUserSync(
  uuid: json['uuid'] as String,
  isFlip: json['isFlip'] as bool,
  weapon: (json['weapon'] as num).toInt(),
  gridX: (json['gridX'] as num).toDouble(),
  gridY: (json['gridY'] as num).toDouble(),
  velX: (json['velX'] as num).toDouble(),
  velY: (json['velY'] as num).toDouble(),
  ops: (json['ops'] as num).toInt(),
);

Map<String, dynamic> _$IdUserSyncToJson(IdUserSync instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'gridX': instance.gridX,
      'gridY': instance.gridY,
      'isFlip': instance.isFlip,
      'weapon': instance.weapon,
      'velX': instance.velX,
      'velY': instance.velY,
      'ops': instance.ops,
    };

EnemyHitSync _$EnemyHitSyncFromJson(Map<String, dynamic> json) => EnemyHitSync(
  isFlip: json['isFlip'] as bool,
  attackerUuid: json['attackerUuid'] as String,
  slimeUuid: json['slimeUuid'] as String,
  gridX: (json['gridX'] as num).toDouble(),
  gridY: (json['gridY'] as num).toDouble(),
);

Map<String, dynamic> _$EnemyHitSyncToJson(EnemyHitSync instance) =>
    <String, dynamic>{
      'isFlip': instance.isFlip,
      'attackerUuid': instance.attackerUuid,
      'slimeUuid': instance.slimeUuid,
      'gridX': instance.gridX,
      'gridY': instance.gridY,
    };
