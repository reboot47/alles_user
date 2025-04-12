import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../utils/phone_utils.dart';
import '../../services/twilio_service.dart';
import '../../services/auth_service.dart';
import 'verification_code_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({Key? key}) : super(key: key);

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _authService = AuthService();
  final _twilioService = TwilioService();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // 電話番号のバリデーション
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return '電話番号を入力してください';
    }
    
    // ハイフンなしの場合は自動整形
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-]'), '');
    
    if (!PhoneUtils.isValidJapanesePhoneNumber(cleanNumber)) {
      return '有効な日本の電話番号を入力してください';
    }
    
    return null;
  }

  // 次へボタンの処理
  Future<void> _handleNext() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final phoneNumber = _phoneController.text.replaceAll(RegExp(r'[\s\-]'), '');
        
        // 既存ユーザーのチェック
        final exists = await _authService.userExists(phoneNumber);
        if (exists) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('この電話番号は既に登録されています。ログインしてください。')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        // 認証コードの送信
        final verificationCode = await _twilioService.sendVerificationCode(phoneNumber);
        if (verificationCode == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('認証コードの送信に失敗しました。もう一度お試しください。')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
        
        if (!mounted) return;
        // 認証コード入力画面へ
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => VerificationCodeScreen(
              phoneNumber: phoneNumber,
              verificationCode: verificationCode,
              isRegistration: true,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラーが発生しました: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景グラデーション
          Container(
            decoration: const BoxDecoration(
              gradient: AllesColors.splashGradient,
            ),
          ),
          
          // 装飾的な星
          _buildStars(),
          
          // メインコンテンツ
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      
                      // 戻るボタン
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: AllesColors.navyBlue,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // タイトル
                      Animate(
                        effects: [
                          FadeEffect(duration: 500.ms),
                          SlideEffect(
                            begin: const Offset(0, 30),
                            end: const Offset(0, 0),
                            duration: 500.ms,
                          ),
                        ],
                        child: const Text(
                          '新規登録',
                          style: TextStyle(
                            color: AllesColors.navyBlue,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // サブタイトル
                      Animate(
                        effects: [
                          FadeEffect(
                            duration: 500.ms,
                            delay: 200.ms,
                          ),
                        ],
                        child: const Text(
                          '電話番号を入力してください',
                          style: TextStyle(
                            color: AllesColors.grayishLavender,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // 電話番号入力フィールド
                      Animate(
                        effects: [
                          FadeEffect(
                            duration: 500.ms,
                            delay: 400.ms,
                          ),
                        ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '電話番号',
                              style: TextStyle(
                                color: AllesColors.navyBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: '090-1234-5678',
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    '🇯🇵 +81',
                                    style: TextStyle(
                                      color: AllesColors.navyBlue,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 12,
                                ),
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _PhoneNumberFormatter(),
                              ],
                              validator: _validatePhoneNumber,
                            ),
                            const SizedBox(height: 4),
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                '* ハイフンは自動的に挿入されます',
                                style: TextStyle(
                                  color: AllesColors.grayishLavender,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // 次へボタン
                      Animate(
                        effects: [
                          FadeEffect(
                            duration: 500.ms,
                            delay: 600.ms,
                          ),
                        ],
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AllesColors.rosePink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text('認証コードを送信'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 装飾的な星（ログイン画面と同じスタイル）
  Widget _buildStars() {
    return Stack(
      children: List.generate(15, (index) {
        final size = 2.0 + (index % 3) * 1.5;
        final x = index * 20.0;
        final y = index * 15.0;

        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: index % 3 == 0 
                  ? AllesColors.pearlGold 
                  : AllesColors.fairyBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (index % 3 == 0 
                      ? AllesColors.pearlGold 
                      : AllesColors.fairyBlue).withOpacity(0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scaleXY(
             begin: 0.5, 
             end: 1.5, 
             duration: Duration(milliseconds: 1000 + (index * 100 % 1000)),
           ),
        );
      }),
    );
  }
}

// 電話番号フォーマッター
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }
    
    // ハイフンを削除
    final digitsOnly = text.replaceAll('-', '');
    
    // フォーマット適用
    String formatted = '';
    
    if (digitsOnly.length <= 3) {
      formatted = digitsOnly;
    } else if (digitsOnly.length <= 7) {
      formatted = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    } else {
      formatted = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7, digitsOnly.length.clamp(0, 11))}';
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
