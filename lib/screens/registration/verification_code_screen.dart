import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../utils/constants.dart';
import '../../services/twilio_service.dart';
import 'password_setup_screen.dart';
import '../password_reset/reset_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationCode;
  final bool isRegistration; // 新規登録かパスワードリセットか

  const VerificationCodeScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationCode,
    required this.isRegistration,
  }) : super(key: key);

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  int _remainingTime = 60; // 再送信までの秒数
  Timer? _timer;
  late TwilioService _twilioService;

  @override
  void initState() {
    super.initState();
    _twilioService = TwilioService();
    _startTimer();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  // 認証コード再送信
  Future<void> _resendCode() async {
    if (_remainingTime > 0) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newCode = await _twilioService.sendVerificationCode(widget.phoneNumber);
      if (newCode != null) {
        // verificationCodeはfinalなので直接更新できないが、新しいコードが送信されたことを通知
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('認証コードを再送信しました')),
        );
        _startTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('認証コードの送信に失敗しました')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラー: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 認証コード確認
  void _verifyCode() {
    if (_formKey.currentState!.validate()) {
      final enteredCode = _codeController.text.trim();
      
      if (enteredCode == widget.verificationCode) {
        // 認証成功
        if (widget.isRegistration) {
          // 新規登録の場合
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordSetupScreen(
                phoneNumber: widget.phoneNumber,
                isRegistration: true,
              ),
            ),
          );
        } else {
          // パスワードリセットの場合
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        }
      } else {
        // 認証失敗
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('認証コードが正しくありません')),
        );
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
                        child: Text(
                          widget.isRegistration ? '認証コードを入力' : 'パスワードリセット',
                          style: const TextStyle(
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
                        child: Text(
                          'SMSで送信された6桁の認証コードを入力してください',
                          style: const TextStyle(
                            color: AllesColors.grayishLavender,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // 電話番号表示
                      Animate(
                        effects: [
                          FadeEffect(
                            duration: 500.ms,
                            delay: 300.ms,
                          ),
                        ],
                        child: Text(
                          widget.phoneNumber,
                          style: const TextStyle(
                            color: AllesColors.navyBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // PINコード入力フィールド
                      Animate(
                        effects: [
                          FadeEffect(
                            duration: 500.ms,
                            delay: 400.ms,
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: PinCodeTextField(
                            appContext: context,
                            length: 6,
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(12),
                              fieldHeight: 50,
                              fieldWidth: 45,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              selectedFillColor: Colors.white,
                              activeColor: AllesColors.lavender,
                              inactiveColor: Colors.grey.shade300,
                              selectedColor: AllesColors.rosePink,
                            ),
                            animationDuration: const Duration(milliseconds: 300),
                            enableActiveFill: true,
                            onCompleted: (v) {
                              // 全ての桁が入力されたら自動的に検証
                              _verifyCode();
                            },
                            beforeTextPaste: (text) {
                              // 数字のみ許可
                              return text != null && RegExp(r'^\d+$').hasMatch(text);
                            },
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 再送信オプション
                      Center(
                        child: Animate(
                          effects: [
                            FadeEffect(
                              duration: 500.ms,
                              delay: 500.ms,
                            ),
                          ],
                          child: TextButton(
                            onPressed: _remainingTime > 0 ? null : _resendCode,
                            child: Text(
                              _remainingTime > 0
                                  ? '再送信まで $_remainingTime 秒'
                                  : '認証コードを再送信',
                              style: TextStyle(
                                color: _remainingTime > 0
                                    ? AllesColors.grayishLavender
                                    : AllesColors.rosePink,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
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
                            onPressed: _isLoading ? null : _verifyCode,
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
                                : const Text('認証して次へ'),
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
  
  // 装飾的な星（他の画面と同じスタイル）
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
