import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'dart:io';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';
import 'utils/database_initializer.dart';
import 'utils/database_helper.dart';
import 'utils/database_debug_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // データベースの初期化とシードデータの投入
  try {
    developer.log('データベース初期化開始');
    
    // まず接続をテスト
    final connectionSuccess = await DatabaseDebugHelper.testConnection();
    if (!connectionSuccess) {
      developer.log('データベース接続テスト失敗、初期化を続行します');
    } else {
      developer.log('データベース接続テスト成功');
    }
    
    // usersテーブルの存在確認
    final usersExists = await DatabaseDebugHelper.checkTableExists('users');
    developer.log('usersテーブルの存在: $usersExists');
    
    // 手動データベース初期化を実行
    developer.log('=== 手動データベース初期化開始 ===');
    await DatabaseInitializer.initialize();
    developer.log('=== テーブル作成完了 ===');
    
    // 検証
    final testConn = await DatabaseHelper.connection;
    final result = await testConn.query('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = \'public\'');
    developer.log('テーブル数: ${result.first[0]}');
    
    // 詳細情報
    final dbInfo = await testConn.query('SELECT current_user, current_database()');
    developer.log('DB情報: ユーザー=${dbInfo.first[0]}, DB=${dbInfo.first[1]}');
    
    // usersテーブルがあるか再確認
    final usersExistsAfter = await DatabaseDebugHelper.checkTableExists('users');
    developer.log('初期化後のusersテーブルの存在: $usersExistsAfter');
    
    if (usersExistsAfter) {
      // テーブルの構造確認
      final tableDetails = await DatabaseDebugHelper.getTableDetails('users');
      developer.log('usersテーブルの詳細: $tableDetails');
      
      // シードデータ投入
      await DatabaseInitializer.seedInitialData();
      developer.log('シードデータ投入完了');
    } else {
      developer.log('警告: usersテーブルがまだ存在しません');
    }
    
    // ユーザーテーブルを直接SQLで作成する試行
    try {
      developer.log('直接SQLでテーブル作成を試みます');
      await testConn.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          phone_number VARCHAR(20) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          username VARCHAR(100),
          created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      developer.log('テーブル作成成功！');
    } catch (e) {
      developer.log('直接SQLでのテーブル作成エラー: $e');
    }
    
    developer.log('データベースの初期化処理が完了しました');
  } catch (e, stackTrace) {
    developer.log('データベースの初期化中にエラーが発生しました: ${DatabaseDebugHelper.formatDatabaseError(e)}');
    developer.log('スタックトレース: $stackTrace');
  }
  
  runApp(const AllesApp());
}

class AllesApp extends StatelessWidget {
  const AllesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AllesConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AllesColors.rosePink,
          primary: AllesColors.rosePink,
          secondary: AllesColors.lavender,
          background: AllesColors.milkyWhite,
        ),
        fontFamily: 'Nunito',
        useMaterial3: true,
      ),
      home: const AllesAppInitializer(),
    );
  }
}

class AllesAppInitializer extends StatefulWidget {
  const AllesAppInitializer({super.key});

  @override
  State<AllesAppInitializer> createState() => _AllesAppInitializerState();
}

class _AllesAppInitializerState extends State<AllesAppInitializer> {
  bool _showSplash = true;
  bool _showLogin = false;

  void _navigateToLogin() {
    setState(() {
      _showSplash = false;
      _showLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _navigateToLogin);
    } else if (_showLogin) {
      return const LoginScreen();
    } else {
      return const HomeScreen();
    }
  }
}

