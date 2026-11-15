import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/images.dart';
import 'phone_screen.dart';

class _Slide {
  const _Slide(this.white, this.blue, this.image);
  final String white;
  final String blue;
  final String image;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  late final List<_Slide> _data = [
    _Slide('Bike', 'Services', Img.bikeHero),
    _Slide('Home', 'Services', Img.homeHero),
    _Slide('Food', 'Delivery', Img.foodHero),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % _data.length,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PhoneScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _data.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => AppImage(_data[i].image, fit: BoxFit.cover),
          ),
          // Legibility scrim.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.42, 0.68, 1.0],
                colors: [
                  Color(0x33000000),
                  Color(0x00000000),
                  Color(0xAA0A1526),
                  Color(0xF00A1526),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    child: Row(
                      key: ValueKey(_index),
                      children: [
                        Flexible(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                letterSpacing: -0.5,
                              ),
                              children: [
                                TextSpan(
                                  text: '${_data[_index].white} ',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: _data[_index].blue,
                                  style: const TextStyle(
                                      color: Color(0xFF3B8EF5)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_data.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 6,
                      width: active ? 22 : 6,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Column(
                    children: [
                      FilledButton(
                        onPressed: _continue,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.smartphone_rounded, size: 19),
                            SizedBox(width: 10),
                            Text('Continue with OTP'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _continue,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.text,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _GoogleGlyph(),
                            SizedBox(width: 10),
                            Text('Continue with Google'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'By continuing you agree to our Terms & Conditions and '
                        'Privacy Policy and receiving calls/sms from us even if '
                        'your number is registered with NDNC',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          colors: [
            Color(0xFF4285F4),
            Color(0xFF34A853),
            Color(0xFFFBBC05),
            Color(0xFFEA4335),
          ],
          stops: [0.0, 0.35, 0.65, 1.0],
        ).createShader(rect),
        child: const Text(
          'G',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.05,
          ),
        ),
      ),
    );
  }
}
