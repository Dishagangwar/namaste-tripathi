import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'role_screen.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 6;

  /// One real field behind six painted boxes. Six separate TextFields drop
  /// characters when the code is pasted, autofilled from the SMS, or simply
  /// typed faster than focus can move between them.
  final _controller = TextEditingController();
  final _node = FocusNode();
  Timer? _timer;
  int _seconds = 90;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds = _seconds > 0 ? _seconds - 1 : 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _node.dispose();
    super.dispose();
  }

  bool _verifying = false;

  String get _code => _controller.text;
  bool get _complete => _code.length == _length;

  String get _countdown {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _verify() async {
    if (!_complete || _verifying) return;
    _node.unfocus();
    final session = context.read<SessionState>();

    setState(() => _verifying = true);
    final error = await session.auth.verifyOtp(
      countryCode: session.countryCode,
      phone: session.phone,
      token: _code,
    );
    if (!mounted) return;
    setState(() => _verifying = false);

    if (error != null) {
      _controller.clear();
      showAppSnack(context, error);
      _node.requestFocus();
      return;
    }

    // Signed in: pull down the profile, bookings and saved items that belong
    // to this account before the shell renders them.
    if (session.isSignedIn) {
      final bookings = context.read<BookingsState>();
      final favourites = context.read<FavouritesState>();
      await Future.wait([
        session.loadProfile(),
        bookings.load(),
        favourites.load(),
      ]);
      if (!mounted) return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RoleScreen()),
    );
  }

  Future<void> _resend() async {
    final session = context.read<SessionState>();
    setState(() => _seconds = 90);
    final error = await session.auth.sendOtp(
      countryCode: session.countryCode,
      phone: session.phone,
    );
    if (!mounted) return;
    showAppSnack(context, error ?? 'A new code is on its way.');
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: () => showAppSnack(context, 'Support is on the way.'),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.tintSurface,
                foregroundColor: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Help'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'We just sent you an SMS',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                      fontSize: 14.5, color: AppColors.muted, height: 1.5),
                  children: [
                    const TextSpan(text: 'Enter the security code we sent to '),
                    TextSpan(
                      text: '${session.countryCode} ${session.phone}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AppColors.text),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              _CodeField(
                length: _length,
                controller: _controller,
                focusNode: _node,
                onChanged: () => setState(() {}),
                onCompleted: _verify,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _seconds > 0
                        ? 'Resend OTP in $_countdown'
                        : 'Did not get the code?',
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  GestureDetector(
                    onTap: _seconds > 0 ? null : _resend,
                    child: Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _seconds > 0
                            ? AppColors.faint
                            : AppColors.primaryLight,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: (_complete && !_verifying) ? _verify : null,
                style: FilledButton.styleFrom(
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.35),
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _verifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify & Continue'),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _CodeField extends StatelessWidget {
  const _CodeField({
    required this.length,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCompleted,
  });

  final int length;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onChanged;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final text = controller.text;

    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 58,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(length, (i) {
                final filled = i < text.length;
                final active = i == text.length && focusNode.hasFocus;
                return Container(
                  width: 50,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: active ? AppColors.primary : AppColors.border,
                      width: active ? 1.8 : 1,
                    ),
                  ),
                  child: Text(
                    filled ? text[i] : '',
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                );
              }),
            ),
            // The real input sits on top, invisible, catching every keystroke.
            Positioned.fill(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(length),
                ],
                showCursor: false,
                cursorColor: Colors.transparent,
                enableInteractiveSelection: false,
                style: const TextStyle(color: Colors.transparent, height: 1),
                decoration: const InputDecoration(
                  counterText: '',
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onChanged: (v) {
                  onChanged();
                  if (v.length == length) onCompleted();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
