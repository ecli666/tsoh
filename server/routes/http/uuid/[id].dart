import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:server/data_source.dart';
import 'package:uuid/uuid.dart';

FutureOr<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _get(context, id);
    case HttpMethod.put:
    case HttpMethod.delete:
    case HttpMethod.head:
    case HttpMethod.options:
    case HttpMethod.patch:
    case HttpMethod.post:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _get(RequestContext context, String id) async {
  final dataSource = context.read<DataSource>();
  final contains = await dataSource.contains(id);
  if (contains) {
    print('found');
    return Response.json(body: id);
  } else {
    print('not found');
    final newUuid = const Uuid().v4();
    await dataSource.create(newUuid);
    return Response.json(body: newUuid);
  }
}
