import 'database_helper.dart';

class DatabaseInitializer {
  // データベーステーブルの初期化
  static Future<void> initialize() async {
    try {
      final conn = await DatabaseHelper.connection;
      
      // usersテーブルの作成
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id SERIAL PRIMARY KEY,
          phone_number VARCHAR(20) UNIQUE NOT NULL,
          password VARCHAR(255) NOT NULL,
          username VARCHAR(100),
          profile_image_url TEXT,
          birth_date DATE,
          created_at TIMESTAMP NOT NULL,
          updated_at TIMESTAMP,
          last_login_at TIMESTAMP
        )
      ''');
      
      // その他必要なテーブルの作成
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS fortune_tellers (
          id SERIAL PRIMARY KEY,
          user_id INTEGER REFERENCES users(id),
          display_name VARCHAR(100) NOT NULL,
          profile_description TEXT,
          category VARCHAR(50),
          rating DECIMAL(3,2),
          price_per_minute INTEGER,
          is_available BOOLEAN DEFAULT TRUE,
          created_at TIMESTAMP NOT NULL
        )
      ''');
      
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS sessions (
          id SERIAL PRIMARY KEY,
          user_id INTEGER REFERENCES users(id),
          fortune_teller_id INTEGER REFERENCES fortune_tellers(id),
          start_time TIMESTAMP NOT NULL,
          end_time TIMESTAMP,
          duration INTEGER,
          price_total INTEGER,
          payment_status VARCHAR(20),
          rating INTEGER,
          review TEXT,
          created_at TIMESTAMP NOT NULL
        )
      ''');
      
      print('データベーステーブルが正常に初期化されました');
    } catch (e) {
      print('データベースの初期化中にエラーが発生しました: $e');
    }
  }
  
  // 初期データの投入（必要に応じて）
  static Future<void> seedInitialData() async {
    try {
      final conn = await DatabaseHelper.connection;
      
      // 占いカテゴリの初期データなど
      final categoriesExist = await conn.query('''
        SELECT EXISTS (
          SELECT 1 FROM information_schema.tables 
          WHERE table_name = 'fortune_categories'
        )
      ''');
      
      if (categoriesExist[0][0] == false) {
        // fortune_categoriesテーブルの作成
        await conn.execute('''
          CREATE TABLE IF NOT EXISTS fortune_categories (
            id SERIAL PRIMARY KEY,
            name VARCHAR(50) NOT NULL,
            description TEXT,
            icon_name VARCHAR(50),
            color_hex VARCHAR(10),
            created_at TIMESTAMP NOT NULL
          )
        ''');
        
        // カテゴリの初期データ
        await conn.execute('''
          INSERT INTO fortune_categories (name, description, icon_name, color_hex, created_at)
          VALUES 
            ('タロット', 'タロットカードを使った占い', 'tarot_card', '#F8A1C4', NOW()),
            ('手相', '手のひらから運命を読み解く', 'palm', '#CDB4DB', NOW()),
            ('四柱推命', '生年月日から導き出す東洋の占術', 'calendar', '#D1E0F3', NOW()),
            ('西洋占星術', '星の配置から運命を導く', 'star', '#E6D3B3', NOW()),
            ('霊感', '霊的な感覚で相談者の未来を視る', 'crystal_ball', '#FAD6E8', NOW())
          ON CONFLICT DO NOTHING
        ''');
      }
      
      print('初期データが正常に投入されました');
    } catch (e) {
      print('初期データ投入中にエラーが発生しました: $e');
    }
  }
}
