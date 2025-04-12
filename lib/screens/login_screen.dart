import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import '../utils/constants.dart';
import '../services/auth_service.dart';
import 'registration/phone_input_screen.dart';
import 'password_reset/reset_phone_input_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String _errorMessage = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
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
          
          // フローラルデコレーション（全体表示）
          //Positioned.fill(
          //  child: Image.asset(
          //    'assets/images/floral_decoration.png',
          //    fit: BoxFit.contain,
          //  ),
          //),
          
          // 装飾的な星
          _buildStars(),
          
          // メインコンテンツ
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    
                    // ロゴ
                    _buildLogo(),
                    
                    const SizedBox(height: 0),
                    
                    // サブタイトル
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        '占いとの出会いは最高です',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: AllesColors.navyBlue.withOpacity(0.5),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height:20),
                    
                    // 電話番号フィールド
                    _buildPhoneField(),
                    
                    const SizedBox(height: 20),
                    
                    // パスワードフィールド
                    _buildPasswordField(),
                    
                    const SizedBox(height: 10),
                    
                    // Remember Me & パスワードを忘れた
                    _buildLoginOptions(),
                    
                    // エラーメッセージ
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // ログインボタン
                    _buildLoginButton(),
                    
                    const SizedBox(height: 24),
                    
                    // または
                    _buildDividerWithText('または'),
                    
                    const SizedBox(height: 24),
                    
                    // SNSログインオプション
                    _buildSocialLoginOptions(),
                    
                    const SizedBox(height: 40),
                    
                    // アカウント作成リンク
                    _buildSignUpLink(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ログインボタン
  Widget _buildLoginButton() {
    return Animate(
      effects: [
        SlideEffect(
          begin: const Offset(0, 20),
          end: const Offset(0, 0),
          duration: 500.ms,
          delay: 300.ms,
          curve: Curves.easeOutQuint,
        ),
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 500.ms,
          delay: 300.ms,
        ),
      ],
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AllesColors.rosePink, AllesColors.lavender],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AllesColors.rosePink.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () async {
              // 入力検証
              if (_phoneNumberController.text.isEmpty || _passwordController.text.isEmpty) {
                setState(() {
                  _errorMessage = '電話番号とパスワードを入力してください';
                });
                return;
              }
              
              // 電話番号のフォーマット (ハイフンを削除)
              final phoneNumber = _phoneNumberController.text.replaceAll('-', '');
              
              setState(() {
                _isLoading = true;
                _errorMessage = '';
              });
              
              try {
                // ログイン処理
                final success = await AuthService().login(
                  phoneNumber,
                  _passwordController.text,
                );
                
                if (success) {
                  // ログイン成功
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  }
                } else {
                  // ログイン失敗
                  if (mounted) {
                    setState(() {
                      _errorMessage = '電話番号またはパスワードが正しくありません';
                      _isLoading = false;
                    });
                  }
                }
              } catch (e) {
                // エラー発生
                if (mounted) {
                  setState(() {
                    _errorMessage = 'ログインエラー: ${e.toString()}';
                    _isLoading = false;
                  });
                }
              }
            },
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'ログイン',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // 電話番号フィールド
  Widget _buildPhoneField() {
    return Animate(
      effects: [
        SlideEffect(
          begin: const Offset(0, 20),
          end: const Offset(0, 0),
          duration: 500.ms,
          delay: 100.ms,
          curve: Curves.easeOutQuint,
        ),
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 500.ms,
          delay: 100.ms,
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AllesColors.navyBlue.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextField(
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(
            color: AllesColors.navyBlue,
            fontSize: 16,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _PhoneNumberFormatter(),
          ],
          decoration: InputDecoration(
            hintText: '090-1234-5678',
            hintStyle: TextStyle(
              color: AllesColors.grayishLavender.withOpacity(0.7),
              fontSize: 16,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🇯🇵',  // 日本国旗絵文字
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.phone_android,
                    color: AllesColors.grayishLavender.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  // パスワードフィールド
  Widget _buildPasswordField() {
    return Animate(
      effects: [
        SlideEffect(
          begin: const Offset(0, 20),
          end: const Offset(0, 0),
          duration: 500.ms,
          delay: 200.ms,
          curve: Curves.easeOutQuint,
        ),
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 500.ms,
          delay: 200.ms,
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AllesColors.navyBlue.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(
            color: AllesColors.navyBlue,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'パスワード',
            hintStyle: TextStyle(
              color: AllesColors.grayishLavender.withOpacity(0.7),
              fontSize: 16,
            ),
            prefixIcon: Icon(
              Icons.lock_outline,
              color: AllesColors.grayishLavender.withOpacity(0.7),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AllesColors.grayishLavender.withOpacity(0.7),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ),
    );
  }

  // ログインオプション (Remember Me & パスワードを忘れた)
  Widget _buildLoginOptions() {
    return Animate(
      effects: [
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 500.ms,
          delay: 250.ms,
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remember Me
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                  fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.selected)) {
                      return AllesColors.rosePink;
                    }
                    return Colors.transparent;
                  }),
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(
                    color: AllesColors.grayishLavender.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ログイン情報を保存',
                style: TextStyle(
                  color: AllesColors.grayishLavender.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          
          // パスワードを忘れた
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResetPhoneInputScreen(),
                ),
              );
            },
            child: Text(
              'パスワードを忘れた場合',
              style: TextStyle(
                color: AllesColors.rosePink.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // または で区切る線
  Widget _buildDividerWithText(String text) {
    return Animate(
      effects: [
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 500.ms,
          delay: 350.ms,
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AllesColors.lavender.withOpacity(0.1),
                    AllesColors.lavender.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: TextStyle(
                color: AllesColors.grayishLavender.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AllesColors.lavender.withOpacity(0.5),
                    AllesColors.lavender.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // SNSログインオプション
  Widget _buildSocialLoginOptions() {
    final socialButtons = [
      {'icon': Icons.g_mobiledata, 'color': const Color(0xFFDB4437)},
      {'icon': Icons.apple, 'color': Colors.black},
    ];

    return Animate(
      effects: [
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 500.ms,
          delay: 400.ms,
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          socialButtons.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                // TODO: ソーシャルログイン処理
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AllesColors.navyBlue.withOpacity(0.15),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    socialButtons[index]['icon'] as IconData,
                    color: socialButtons[index]['color'] as Color,
                    size: 30,
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scaleXY(
                  begin: 1.0, 
                  end: 1.05,
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInOut,
                ),
            ),
          ),
        ),
      ),
    );
  }

  // アカウント作成リンク
  Widget _buildSignUpLink() {
    return Animate(
      effects: [
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 500.ms,
          delay: 450.ms,
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'アカウントをお持ちでない方は ',
            style: TextStyle(
              color: AllesColors.grayishLavender.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PhoneInputScreen(),
                ),
              );
            },
            child: const Text(
              '新規登録',
              style: TextStyle(
                color: AllesColors.rosePink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ロゴ
  Widget _buildLogo() {
    return Animate(
      effects: [
        ScaleEffect(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 1000.ms,
          curve: Curves.elasticOut,
        ),
        FadeEffect(
          begin: 0,
          end: 1,
          duration: 800.ms,
        ),
      ],
      child: Column(
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AllesColors.lavender.withOpacity(0.0),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/floral_decoration.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),

        ],
      ),
    );
  }

  // 装飾的な星
  Widget _buildStars() {
    return Stack(
      children: List.generate(15, (index) {
        final size = 2.0 + (index % 3) * 1.5;
        final x = math.Random().nextDouble() * MediaQuery.of(context).size.width;
        final y = math.Random().nextDouble() * MediaQuery.of(context).size.height;

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

  // 花のデコレーション
  Widget _buildFloralDecoration({bool isFlipped = false}) {
    return Transform.scale(
      scale: isFlipped ? 0.6 : 0.8,
      child: Transform.flip(
        flipX: isFlipped,
        flipY: isFlipped,
        child: Opacity(
          opacity: 0.4,
          child: Image.asset(
            'assets/images/floral_decoration.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            color: isFlipped ? AllesColors.lavender.withOpacity(0.7) : AllesColors.rosePink.withOpacity(0.6),
            colorBlendMode: BlendMode.srcATop,
          ),
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
      .fadeIn(duration: 800.ms)
      .scaleXY(begin: 0.95, end: 1.0, duration: 3.seconds, curve: Curves.easeInOut);
  }
}
