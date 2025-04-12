import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import '../utils/phone_utils.dart';

class TwilioService {
  final String _accountSid;
  final String _authToken;
  final String _twilioNumber;
  
  TwilioService({
    String? accountSid,
    String? authToken,
    String? twilioNumber,
  }) : 
    _accountSid = accountSid ?? AppConfig.twilioAccountSid,
    _authToken = authToken ?? AppConfig.twilioAuthToken,
    _twilioNumber = twilioNumber ?? AppConfig.twilioPhoneNumber;
  
  // 6桁の認証コードを生成
  String generateVerificationCode() {
    return (100000 + Random().nextInt(900000)).toString();
  }
  
  // SMS送信メソッド
  Future<bool> sendSMS(String phoneNumber, String message) async {
    try {
      // 日本の電話番号を国際形式に変換（090... -> +81...）
      final internationalNumber = PhoneUtils.formatJapaneseToInternational(phoneNumber);
      
      // Twilio API用のエンドポイントURL
      final uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json'
      );
      
      // Basic認証用のCredentials
      final authString = base64Encode(utf8.encode('$_accountSid:$_authToken'));
      
      // POSTリクエストの実行
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Basic $authString',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': internationalNumber,
          'From': _twilioNumber,
          'Body': message,
        },
      );
      
      // レスポンスのチェック
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        print('Twilioレスポンスエラー: ${response.body}');
        return false;
      }
    } catch (e) {
      print('SMS送信エラー: $e');
      return false;
    }
  }
  
  // 認証コード送信
  Future<String?> sendVerificationCode(String phoneNumber) async {
    final code = generateVerificationCode();
    final message = 'Allesの認証コード: $code';
    
    final success = await sendSMS(phoneNumber, message);
    if (success) {
      return code;
    }
    return null;
  }
}
