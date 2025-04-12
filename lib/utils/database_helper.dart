import 'package:postgres/postgres.dart';
import 'config.dart';

class DatabaseHelper {
  static PostgreSQLConnection? _connection;

  static Future<PostgreSQLConnection> get connection async {
    if (_connection == null || _connection!.isClosed) {
      _connection = await _createConnection();
    }
    return _connection!;
  }

  static Future<PostgreSQLConnection> _createConnection() async {
    final uri = Uri.parse(AppConfig.databaseUrl);
    final connection = PostgreSQLConnection(
      uri.host,
      uri.port,
      uri.pathSegments.last,
      username: uri.userInfo.split(':')[0],
      password: uri.userInfo.split(':')[1],
      useSSL: true,
    );
    await connection.open();
    return connection;
  }
  
  // データベース接続のクローズ
  static Future<void> closeConnection() async {
    if (_connection != null && !_connection!.isClosed) {
      await _connection!.close();
    }
  }
}
