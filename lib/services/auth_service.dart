import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:postgres/postgres.dart';
import '../utils/database_helper.dart';
import '../utils/phone_utils.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  // パスワードのハッシュ化
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // ユーザー登録
  Future<bool> registerUser(String phoneNumber, String password) async {
    try {
      // 接続確認
      final conn = await DatabaseHelper.connection;
      final hashedPassword = _hashPassword(password);
      
      // 日本の電話番号を国際形式に変換して保存
      final internationalNumber = PhoneUtils.formatJapaneseToInternational(phoneNumber);
      
      // usersテーブルの存在確認
      final tableExists = await _checkTableExists(conn, 'users');
      if (!tableExists) {
        throw Exception('データベースエラー: usersテーブルが存在しません。アプリを再起動してデータベース初期化を実行してください。');
      }
      
      await conn.query(
        'INSERT INTO users (phone_number, password, created_at) VALUES (@phoneNumber, @password, NOW())',
        substitutionValues: {
          'phoneNumber': internationalNumber,
          'password': hashedPassword,
        },
      );
      
      // 登録成功後、自動ログイン
      await _secureStorage.write(key: 'phone_number', value: internationalNumber);
      await _secureStorage.write(key: 'is_logged_in', value: 'true');
      
      return true;
    } catch (e) {
      print('ユーザー登録エラー: $e');
      // エラーを再スローして詳細なメッセージを表示できるようにする
      throw Exception('ユーザー登録中にエラーが発生しました: $e');
    }
  }
  
  // ログイン
  Future<bool> login(String phoneNumber, String password) async {
    try {
      final conn = await DatabaseHelper.connection;
      final hashedPassword = _hashPassword(password);
      
      // 日本の電話番号を国際形式に変換
      final internationalNumber = PhoneUtils.formatJapaneseToInternational(phoneNumber);
      
      final results = await conn.query(
        'SELECT id FROM users WHERE phone_number = @phoneNumber AND password = @password',
        substitutionValues: {
          'phoneNumber': internationalNumber,
          'password': hashedPassword,
        },
      );
      
      if (results.isNotEmpty) {
        // ログイン成功
        await _secureStorage.write(key: 'phone_number', value: internationalNumber);
        await _secureStorage.write(key: 'is_logged_in', value: 'true');
        await _secureStorage.write(key: 'user_id', value: results[0][0].toString());
        return true;
      }
      
      return false;
    } catch (e) {
      print('ログインエラー: $e');
      return false;
    }
  }
  
  // ログイン確認
  Future<bool> isLoggedIn() async {
    final value = await _secureStorage.read(key: 'is_logged_in');
    return value == 'true';
  }
  
  // ログアウト
  Future<void> logout() async {
    await _secureStorage.delete(key: 'is_logged_in');
    await _secureStorage.delete(key: 'phone_number');
    await _secureStorage.delete(key: 'user_id');
  }
  
  // パスワードリセット
  Future<bool> resetPassword(String phoneNumber, String newPassword) async {
    try {
      final conn = await DatabaseHelper.connection;
      final hashedPassword = _hashPassword(newPassword);
      
      // 日本の電話番号を国際形式に変換
      final internationalNumber = PhoneUtils.formatJapaneseToInternational(phoneNumber);
      
      // usersテーブルの存在確認
      final tableExists = await _checkTableExists(conn, 'users');
      if (!tableExists) {
        throw Exception('データベースエラー: usersテーブルが存在しません。アプリを再起動してデータベース初期化を実行してください。');
      }
      
      final result = await conn.query(
        'UPDATE users SET password = @password WHERE phone_number = @phoneNumber',
        substitutionValues: {
          'password': hashedPassword,
          'phoneNumber': internationalNumber,
        },
      );
      
      // 影響を受けた行数を確認
      if (result.affectedRowCount == 0) {
        throw Exception('電話番号に一致するユーザーが見つかりませんでした。');
      }
      
      return true;
    } catch (e) {
      print('パスワードリセットエラー: $e');
      // エラーを再スローして詳細なメッセージを表示できるようにする
      throw Exception('パスワードリセット中にエラーが発生しました: $e');
    }
  }
  
  // ユーザー存在確認
  Future<bool> userExists(String phoneNumber) async {
    try {
      final conn = await DatabaseHelper.connection;
      
      // 日本の電話番号を国際形式に変換
      final internationalNumber = PhoneUtils.formatJapaneseToInternational(phoneNumber);
      
      final result = await conn.query(
        'SELECT COUNT(*) FROM users WHERE phone_number = @phoneNumber',
        substitutionValues: {
          'phoneNumber': internationalNumber,
        },
      );
      
      return (result[0][0] as int) > 0;
    } catch (e) {
      print('ユーザー存在確認エラー: $e');
      return false;
    }
  }
  
  // 現在のユーザー情報を取得
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final phoneNumber = await _secureStorage.read(key: 'phone_number');
    final userId = await _secureStorage.read(key: 'user_id');
    
    if (phoneNumber == null || userId == null) {
      return null;
    }
    
    return {
      'id': userId,
      'phone_number': phoneNumber,
      // 表示用の日本の電話番号形式に変換
      'display_phone': PhoneUtils.formatInternationalToJapanese(phoneNumber),
    };
  }
  
  // テーブルの存在確認メソッド
  Future<bool> _checkTableExists(PostgreSQLConnection conn, String tableName) async {
    try {
      final result = await conn.query('''
        SELECT EXISTS (
          SELECT 1 FROM information_schema.tables 
          WHERE table_schema = 'public' AND table_name = @tableName
        )
      ''', substitutionValues: {'tableName': tableName});
      
      return result.first[0] as bool;
    } catch (e) {
      print('テーブル存在確認エラー: $e');
      return false;
    }
  }
}
