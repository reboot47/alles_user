/// 日本の電話番号を国際形式に変換するユーティリティクラス
class PhoneUtils {
  /// 日本の電話番号を国際形式に変換
  /// 
  /// 例: 09012345678 → +819012345678
  static String formatJapaneseToInternational(String phoneNumber) {
    // 不要な文字（ハイフン、スペース等）を削除
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // 先頭の0を削除して+81を追加
    if (cleanNumber.startsWith('0')) {
      return '+81${cleanNumber.substring(1)}';
    }
    
    // 既に国際形式の場合はそのまま返す
    if (cleanNumber.startsWith('+81')) {
      return cleanNumber;
    }
    
    // 形式が不明な場合は日本の番号と仮定
    return '+81$cleanNumber';
  }
  
  /// 国際形式の電話番号を日本の表示形式に変換
  /// 
  /// 例: +819012345678 → 090-1234-5678
  static String formatInternationalToJapanese(String phoneNumber) {
    // 国際形式から日本の番号に
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleanNumber.startsWith('+81')) {
      cleanNumber = '0${cleanNumber.substring(3)}';
    }
    
    // ハイフン挿入
    if (cleanNumber.length == 11) {
      // 携帯電話の場合: 090-1234-5678
      return '${cleanNumber.substring(0, 3)}-${cleanNumber.substring(3, 7)}-${cleanNumber.substring(7)}';
    } else if (cleanNumber.length == 10) {
      // 固定電話の場合: 03-1234-5678
      return '${cleanNumber.substring(0, 2)}-${cleanNumber.substring(2, 6)}-${cleanNumber.substring(6)}';
    }
    
    // その他の場合はそのまま返す
    return cleanNumber;
  }
  
  /// 日本の電話番号形式を検証
  static bool isValidJapanesePhoneNumber(String phoneNumber) {
    // ハイフンなどを削除
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // 携帯電話 (090, 080, 070)
    final mobilePattern = RegExp(r'^0[789]0\d{8}$');
    
    // 固定電話
    final landlinePattern = RegExp(r'^0\d{9}$');
    
    return mobilePattern.hasMatch(cleanNumber) || landlinePattern.hasMatch(cleanNumber);
  }
}
