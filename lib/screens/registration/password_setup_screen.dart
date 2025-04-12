import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';

class PasswordSetupScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegistration; // 新規登録かパスワードリセットか

  const PasswordSetupScreen({
    Key? key,
    required this.phoneNumber,
    required this.isRegistration,
  }) : super(key: key);

  @override
  State<PasswordSetupScreen> createState() => _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends State<PasswordSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
      return 'パスワードは8文字以上必要です';
    }
    // 英字と数字を含む
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$').hasMatch(value)) {
      return 'パスワードは英字と数字を含む必要があります';
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

  // 完了ボタンの処理
  Future<void> _handleComplete() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        String successMessage;
        try {
          if (widget.isRegistration) {
            // 新規登録
            await _authService.registerUser(
              widget.phoneNumber,
              _passwordController.text,
            );
            successMessage = '登録が完了しました！';
          } else {
            // パスワードリセット
            await _authService.resetPassword(
              widget.phoneNumber,
              _passwordController.text,
            );
            successMessage = 'パスワードがリセットされました';
          }
          
          if (!mounted) return;
          
          // 成功時の処理
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                successMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: AllesColors.rosePink,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          
          // ホーム画面へ
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } catch (error) {
          // エラー内容を詳細に表示
          String errorMessage = error.toString();
          bool isDbError = errorMessage.contains('usersテーブルが存在しません');
          
          if (!mounted) return;
          
          // データベースエラーの場合は詳細な説明を表示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('エラー: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 7),
              action: isDbError ? SnackBarAction(
                label: 'アプリを再起動',
                onPressed: () {
                  // アプリを再起動するコードは実装できないので、
                  // ユーザーにメッセージを表示する
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('アプリを手動で再起動してください'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ) : null,
            ),
          );
        }
      } catch (e) {
        // 予期せぬエラー
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('予期せぬエラーが発生しました: $e'),
            backgroundColor: Colors.red,
          ),
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
                        child: Text(
                          widget.isRegistration ? 'パスワード設定' : '新しいパスワード設定',
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
                        child: const Text(
                          '安全なパスワードを設定してください',
                          style: TextStyle(
                            color: AllesColors.grayishLavender,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // パスワード入力フィールド
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
                              'パスワード',
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
                                hintText: '8文字以上の英数字',
                                filled: true,
                                fillColor: Colors.white,
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // パスワード確認入力フィールド
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 16,
                                ),
                              ),
                              validator: _validateConfirmPassword,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // パスワード要件
                      Animate(
                        effects: [
                          FadeEffect(
                            duration: 500.ms,
                            delay: 600.ms,
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPasswordRequirement('8文字以上'),
                              const SizedBox(height: 4),
                              _buildPasswordRequirement('英字と数字を含む'),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // 完了ボタン
                      Animate(
                        effects: [
                          FadeEffect(
                            duration: 500.ms,
                            delay: 700.ms,
                          ),
                        ],
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleComplete,
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
                                : Text(widget.isRegistration ? '登録を完了する' : 'パスワードを変更する'),
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
  
  // パスワード要件アイテム
  Widget _buildPasswordRequirement(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 16,
          color: AllesColors.grayishLavender,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AllesColors.grayishLavender,
            fontSize: 12,
          ),
        ),
      ],
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
