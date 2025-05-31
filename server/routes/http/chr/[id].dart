import 'dart:async';
import 'dart:io';

import 'package:commons/commons.dart';
import 'package:dart_frog/dart_frog.dart';
import 'package:server/data_source.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, id);
    case HttpMethod.put:
      return _put(context, id);
    case HttpMethod.post:
      return _post(context, id);
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, String id) async {
  final dataSource = context.read<DataSource>();
  final userData = await dataSource.read(id);
  if (userData == null) {
    return Response.json(statusCode: HttpStatus.notFound);
  } else {
    return Response.json(body: userData);
  }
}

Future<Response> _put(RequestContext context, String id) async {
  final decoded = await context.request.json() as Map<String, dynamic>;
  final idUser = IdUser.fromJson(decoded);
  final userData = UserData(
    name: idUser.name,
    outfit: idUser.outfit,
    isFlip: true,
    weapon: 0,
    gridX: 0,
    gridY: 0,
  );
  final dataSource = context.read<DataSource>();
  await dataSource.update(idUser.uuid, userData);
  return Response.json();
}

Future<Response> _post(RequestContext context, String id) async {
  final decoded = await context.request.json() as Map<String, dynamic>;
  final idStatus = IdUserStatus.fromJson(decoded);
  final dataSource = context.read<DataSource>();
  final rdData = await dataSource.read(idStatus.uuid);
  if (rdData != null) {
    final updated = rdData.copyWith(
      isFlip: idStatus.isFlip,
      weapon: idStatus.weapon,
      gridX: idStatus.gridX,
      gridY: idStatus.gridY,
    );
    await dataSource.update(idStatus.uuid, updated);
  }
  return Response.json();
}
