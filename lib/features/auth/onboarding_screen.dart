import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/session/session_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/backend.dart';
import '../../data/images.dart';
import 'account_bootstrap.dart';
import 'phone_screen.dart';
import 'role_screen.dart';

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
  late final List<_Slide> _data = [
    _Slide('Bike', 'Services', Img.bikeHero),
    _Slide('Home', 'Services', Img.homeHero),
    _Slide('Food', 'Delivery', Img.foodHero),
  ];

  // Start deep into an endless page range so the carousel loops forward
  // (no rewind across the middle slide) and can still be swiped backwards.
  late final _controller = PageController(initialPage: _data.length * 1000);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(
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

  /// This button used to call [_continue] as well, so "Continue with Google"
  /// just opened the phone screen. It signs in now.
  void _continueWithGoogle() {
    final session = context.read<SessionBloc>();
    if (session.state.isBusy) return;
    session.add(const GoogleSignInRequested());
  }

  void _onSessionChanged(BuildContext context, SessionState state) {
    switch (state.status) {
      case SessionStatus.authenticated:
        // A demo session looks exactly like a real one from here, so it has
        // to announce itself; otherwise "it signed me in" and "it pretended
        // to sign me in" are the same screen.
        if (state.signedInWithDemoBackend) {
          // Carries the reason, not just the fact. "You are on the demo
          // backend" without "because BACKEND and the key never reached this
          // build" leaves you with nothing to act on.
          showAppSnack(
            context,
            'Demo backend — no Google account was used. ${Backend.reason}',
          );
        }
        loadAccountData(context);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RoleScreen()),
        );
      case SessionStatus.failure:
        showAppSnack(
          context,
          state.errorMessage ?? 'Could not sign in with Google.',
        );
        context.read<SessionBloc>().add(const SessionErrorCleared());
      // Dismissing the account sheet is not an error, so nothing is shown.
      case SessionStatus.cancelled:
        context.read<SessionBloc>().add(const SessionErrorCleared());
      case SessionStatus.idle:
      case SessionStatus.sendingOtp:
      case SessionStatus.otpSent:
      case SessionStatus.verifying:
      case SessionStatus.signingInWithGoogle:
        break;
    }
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
            onPageChanged: (i) => setState(() => _index = i % _data.length),
            itemBuilder: (context, i) =>
                AppImage(_data[i % _data.length].image, fit: BoxFit.cover),
          ),
          // Legibility scrim.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.30, 0.56, 0.80],
                colors: [
                  Color(0x33000000),
                  Color(0x00000000),
                  Color(0xCC1A1206),
                  Color(0xF51A1206),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: RichText(
                            textAlign: TextAlign.center,
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
                                      color: Color(0xFFA16207)),
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
                      BlocConsumer<SessionBloc, SessionState>(
                        listener: _onSessionChanged,
                        listenWhen: (a, b) => a.status != b.status,
                        builder: (context, session) => FilledButton(
                          onPressed:
                              session.isBusy ? null : _continueWithGoogle,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.text,
                            disabledBackgroundColor: Colors.white70,
                          ),
                          child: session.isSigningInWithGoogle
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _GoogleGlyph(),
                                    SizedBox(width: 10),
                                    Text('Continue with Google'),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _BackendNotice(),
                      const SizedBox(height: 4),
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

/// Names the backend the app is running against, in debug builds only.
///
/// Release builds show nothing. This exists because the demo fallback is
/// silent by design -- it has to be, or a keyless checkout would be unusable
/// -- and a silent fallback is indistinguishable from a working one until
/// you go looking in the database and find it empty.
class _BackendNotice extends StatelessWidget {
  const _BackendNotice();

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final demo = Backend.isDemo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (demo ? AppColors.danger : AppColors.success)
            .withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        Backend.reason,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
