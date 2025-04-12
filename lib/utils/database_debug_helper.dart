import 'dart:developer' as developer;
import 'database_helper.dart';
import 'config.dart';

class DatabaseDebugHelper {
  
  // データベース接続テスト
  static Future<bool> testConnection() async {
    try {
      developer.log('データベース接続テスト開始');
      
      // URLが正しい形式かチェック
      final uri = Uri.parse(AppConfig.databaseUrl);
      developer.log('データベースURL解析: ホスト=${uri.host}, ポート=${uri.port}, パス=${uri.path}');
      
      // 接続を試行
      final conn = await DatabaseHelper.connection;
      
      // 簡単なクエリを実行してみる
      final result = await conn.query('SELECT 1 as test');
      developer.log('テストクエリ結果: ${result.first[0]}');
      
      // usersテーブルの存在確認
      final tableExists = await checkTableExists('users');
      developer.log('usersテーブル存在確認: $tableExists');
      
      return true;
    } catch (e, stackTrace) {
      developer.log('データベース接続テスト失敗: $e');
      developer.log('スタックトレース: $stackTrace');
      return false;
    }
  }
  
  // テーブルの存在確認
  static Future<bool> checkTableExists(String tableName) async {
    try {
      final conn = await DatabaseHelper.connection;
      final result = await conn.query('''
        SELECT EXISTS (
          SELECT 1 FROM information_schema.tables 
          WHERE table_schema = 'public' AND table_name = @tableName
        )
      ''', substitutionValues: {'tableName': tableName});
      
      return result.first[0] as bool;
    } catch (e) {
      developer.log('テーブル存在確認エラー: $e');
      return false;
    }
  }
  
  // テーブル情報の詳細取得
  static Future<List<Map<String, dynamic>>> getTableDetails(String tableName) async {
    try {
      final conn = await DatabaseHelper.connection;
      final result = await conn.mappedResultsQuery('''
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = @tableName
        ORDER BY ordinal_position
      ''', substitutionValues: {'tableName': tableName});
      
      return result.map((row) => row.values.first).toList();
    } catch (e) {
      developer.log('テーブル詳細取得エラー: $e');
      return [];
    }
  }
  
  // データベースエラーの詳細報告
  static String formatDatabaseError(dynamic error) {
    if (error == null) return 'Unknown error';
    
    String errorMessage = error.toString();
    
    // PostgreSQLの一般的なエラーコードに基づいた解説を追加
    if (errorMessage.contains('relation') && errorMessage.contains('does not exist')) {
      return 'テーブルが存在しません。データベース初期化が必要です: $errorMessage';
    } else if (errorMessage.contains('connection refused')) {
      return 'データベースへの接続が拒否されました。設定を確認してください: $errorMessage';
    } else if (errorMessage.contains('password authentication failed')) {
      return '認証エラー: ユーザー名またはパスワードが間違っています: $errorMessage';
    } else if (errorMessage.contains('duplicate key value')) {
      return '重複データエラー: 既に存在するデータです: $errorMessage';
    }
    
    return errorMessage;
  }
}
