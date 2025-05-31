import 'package:dart_frog/dart_frog.dart';
import 'package:server/data_source.dart';
import 'package:server/in_memory_data_source.dart';

final _dataSource = InMemoryDataSource();

Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(provider<DataSource>((_) => _dataSource));
}
