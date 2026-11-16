import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'otp_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();
  String _code = '+91';
  bool _sending = false;

  bool get _valid => _controller.text.trim().length >= 10;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_valid || _sending) return;
    final session = context.read<SessionState>();
    final number = _controller.text.trim();
    session
      ..setCountryCode(_code)
      ..setPhone(number);

    setState(() => _sending = true);
    // Asks Supabase to text a code. Returns a message when that fails; a
    // build without an anon key returns null and simply moves on.
    final error = await session.auth.sendOtp(
      countryCode: _code,
      phone: number,
    );
    if (!mounted) return;
    setState(() => _sending = false);

    if (error != null) {
      showAppSnack(context, error);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OtpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Enter Your Mobile Number',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Let's create or find your account. We'll send you a security "
                "code to verify that it's really you.",
                style: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  _CountryCodeField(
                    code: _code,
                    onChanged: (v) => setState(() => _code = v),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(12),
                      ],
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _continue(),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(hintText: 'Mobile no.'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: (_valid && !_sending) ? _continue : null,
                style: FilledButton.styleFrom(
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
                  disabledForegroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _sending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'By continuing, you agree to our Terms & Privacy',
                  style: TextStyle(fontSize: 12, color: AppColors.faint),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryCodeField extends StatelessWidget {
  const _CountryCodeField({required this.code, required this.onChanged});
  final String code;
  final ValueChanged<String> onChanged;

  static const _codes = {
    '+91': '\u{1F1EE}\u{1F1F3}',
    '+1': '\u{1F1FA}\u{1F1F8}',
    '+44': '\u{1F1EC}\u{1F1E7}',
    '+971': '\u{1F1E6}\u{1F1EA}',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: code,
          onChanged: (v) => onChanged(v ?? code),
          borderRadius: BorderRadius.circular(14),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.muted, size: 20),
          items: _codes.entries
              .map(
                (e) => DropdownMenuItem(
                  value: e.key,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.value, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 7),
                      Text(
                        e.key,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
