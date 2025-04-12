import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phoneNumber;
  
  const ResetPasswordScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final _authService = AuthService();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // パスワードのバリデーション
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    }
    
    if (value.length < 8) {
      return 'パスワードは8文字以上で入力してください';
    }
    
    if (!_containsLetterAndNumber(value)) {
      return 'パスワードは文字と数字を含める必要があります';
    }
    
    return null;
  }
  
  // パスワード確認のバリデーション
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'パスワードを再入力してください';
    }
    
    if (value != _passwordController.text) {
      return 'パスワードが一致しません';
    }
    
    return null;
  }
  
  // 文字と数字を含むかチェック
  bool _containsLetterAndNumber(String text) {
    bool hasLetter = text.contains(RegExp(r'[a-zA-Z]'));
    bool hasNumber = text.contains(RegExp(r'[0-9]'));
    return hasLetter && hasNumber;
  }

  // パスワードリセット処理
  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final success = await _authService.resetPassword(
          widget.phoneNumber,
          _passwordController.text,
        );
        
        if (!mounted) return;
        
        if (success) {
          // リセット成功
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('パスワードがリセットされました。新しいパスワードでログインしてください。')),
          );
          
          // ログイン画面に遷移
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          // リセット失敗
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('パスワードのリセットに失敗しました。もう一度お試しください。')),
          );
        }
      } catch (e) {
        if (!mounted) return;
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
                          '新しいパスワードを設定',
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
                          '新しいパスワードを設定してください',
                          style: TextStyle(
                            color: AllesColors.grayishLavender,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // パスワード設定フィールド
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
                              '新しいパスワード',
                              style: TextStyle(
                                color: AllesColors.navyBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: '半角英数字8文字以上',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AllesColors.grayishLavender,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 4),
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                '* 英字と数字を含む8文字以上',
                                style: TextStyle(
                                  color: AllesColors.grayishLavender,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // パスワード確認フィールド
                      Animate(
                        effects: [
                          FadeEffect(
                            duration: 500.ms,
                            delay: 500.ms,
                          ),
                        ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'パスワード（確認）',
                              style: TextStyle(
                                color: AllesColors.navyBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                hintText: 'もう一度入力してください',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AllesColors.grayishLavender,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: _validateConfirmPassword,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // 完了ボタン
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
                            onPressed: _isLoading ? null : _handleResetPassword,
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
                                : const Text('パスワードを更新'),
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
  
  // 装飾的な星
  Widget _buildStars() {
    return Stack(
      children: List.generate(15, (index) {
        final size = 2.0 + (index % 3) * 1.5;
        final top = 20.0 + (index * 25) % (MediaQuery.of(context).size.height - 100);
        final left = (index * 20) % (MediaQuery.of(context).size.width - 20);

        return Positioned(
          left: left,
          top: top,
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
