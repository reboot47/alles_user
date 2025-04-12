import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'dart:math' as math;

import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashScreen({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showText = false;
  bool _showShimmer = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Show text after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
      }
    });

    // Show shimmer effect after text appears
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showShimmer = true;
        });
      }
    });

    // Go to next screen after splash duration
    Timer(AllesConstants.splashDuration, () {
      widget.onComplete();
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // グラデーション背景
            Container(
              decoration: const BoxDecoration(
                gradient: AllesColors.splashGradient,
              ),
            ),
            
            // 星のアニメーション
            Positioned.fill(
              child: _buildStars(),
            ),
            
            // メインコンテンツ
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ロゴアニメーション
                  Animate(
                    effects: [
                      FadeEffect(
                        delay: 200.ms,
                        duration: 1000.ms,
                        curve: Curves.easeOut,
                      ),
                      ScaleEffect(
                        delay: 200.ms,
                        duration: 1000.ms,
                        curve: Curves.easeOut,
                      ),
                    ],
                    child: _buildLogo(),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Animated text that appears after logo
                  if (_showText)
                    Animate(
                      effects: [
                        FadeEffect(
                          duration: 800.ms, 
                          curve: Curves.easeOut,
                        ),
                        SlideEffect(
                          begin: const Offset(0, 20),
                          end: const Offset(0, 0),
                          duration: 800.ms,
                          curve: Curves.easeOut,
                        ),
                      ],
                      child: _buildAnimatedTitle(),
                    ),
                    
                  const SizedBox(height: 30),
                  
                  // Shimmer effect below the text
                  if (_showShimmer)
                    Animate(
                      effects: [
                        FadeEffect(
                          duration: 800.ms,
                          curve: Curves.easeOut,
                        ),
                      ],
                      child: _buildShimmer(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // グラデーション背景
        Container(
          decoration: const BoxDecoration(
            gradient: AllesColors.splashGradient,
          ),
        ),
        
        // フローラルデコレーション（装飾的な花）
        Positioned.fill(
          child: Image.asset(
            'assets/images/floral_decoration.png',
            fit: BoxFit.contain,
          ),
        ),
        
        
        // メインロゴのグラデーション背景
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AllesColors.milkyWhite.withOpacity(0.0),
          ),
        ),

        // メインロゴ
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AllesColors.lavender.withOpacity(0.0),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
         //child: Image.asset(
          //  'assets/images/alles_logo.png',
          //  width: 180,
          //  height: 180,
          //  fit: BoxFit.contain,
         // ),
        ),
      ],
    );
  }

  Widget _buildAnimatedTitle() {
    return Column(
      children: [
        AnimatedTextKit(
          animatedTexts: [
            TypewriterAnimatedText(
              AllesConstants.appTagline,
              textStyle: const TextStyle(
                color: AllesColors.grayishLavender,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.2,
              ),
              speed: const Duration(milliseconds: 100),
            ),
          ],
          totalRepeatCount: 1,
          displayFullTextOnTap: true,
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return SizedBox(
      width: 160,
      height: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AllesColors.fairyBlue.withOpacity(0.2),
              AllesColors.pearlGold,
              AllesColors.fairyBlue.withOpacity(0.2),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(),
      ).shimmer(
        duration: 2.seconds,
        delay: 0.5.seconds,
      ),
    );
  }
  
  // 星のアニメーション要素
  Widget _buildStars() {
    return Stack(
      children: List.generate(20, (index) {
        final size = 3.0 + (index % 3) * 2.0;
        final x = math.Random().nextDouble() * MediaQuery.of(context).size.width;
        final y = math.Random().nextDouble() * MediaQuery.of(context).size.height;
        final delay = (index * 100).ms;

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
           .fadeIn(duration: 1.seconds, delay: delay)
           .scaleXY(begin: 0.1, end: 1.0, duration: 1.seconds, delay: delay)
           .then()
           .fadeOut(duration: 1.seconds, delay: 5.seconds),
        );
      }),
    );
  }
}
