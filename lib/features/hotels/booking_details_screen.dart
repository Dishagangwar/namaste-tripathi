import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/bookings/bookings_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'booking_confirmed_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({
    super.key,
    required this.hotel,
    required this.stay,
    required this.total,
    required this.roomTotal,
    required this.fees,
    required this.discount,
  });

  final Hotel hotel;
  final DateTimeRange stay;
  final double total;
  final double roomTotal;
  final double fees;
  final double discount;

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController(text: 'Darsh');
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  int _adults = 2;
  int _children = 1;
  String _room = 'Ocean Suite';

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _complete() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final booking = Booking(
      id: 'hb${DateTime.now().millisecondsSinceEpoch}',
      title: widget.hotel.name,
      subtitle: '$_room • $_adults Adults, $_children Child',
      kind: 'Luxury Stay',
      when: '${_fmt(widget.stay.start)} - ${_fmt(widget.stay.end)}',
      status: BookingStatus.confirmed,
      image: widget.hotel.image,
      location: widget.hotel.location,
      reference:
          '#AB-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
    context.read<BookingsBloc>().add(BookingAdded(booking));

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingConfirmedScreen(
          booking: booking,
          total: widget.total,
          guestName: '${_first.text} ${_last.text}'.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nights = widget.stay.duration.inDays;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AppCard(
              color: const Color(0xFFFAF4E2),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          size: 20, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text('Guest Information',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _Field(label: 'First Name', controller: _first),
                  const SizedBox(height: 14),
                  _Field(label: 'Last Name', controller: _last),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Enter a valid email'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _Field(
                    label: 'Phone',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().length < 10)
                        ? 'Enter a valid phone number'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 86,
                        height: 62,
                        child: AppImage(widget.hotel.image, radius: 12),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'PREMIUM SELECTION',
                              style: TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.hotel.name,
                              style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Divider(),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: _Fact(
                              'CHECK-IN', _fmt(widget.stay.start))),
                      Expanded(
                          child: _Fact('CHECK-OUT', _fmt(widget.stay.end))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _Stepper(
                          label: 'ADULTS',
                          value: _adults,
                          onChanged: (v) => setState(() => _adults = v),
                          min: 1,
                        ),
                      ),
                      Expanded(
                        child: _Stepper(
                          label: 'CHILDREN',
                          value: _children,
                          onChanged: (v) => setState(() => _children = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'ROOM TYPE',
                    style: TextStyle(
                      fontSize: 9.5,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final r in const [
                        'Ocean Suite',
                        'Deluxe King',
                        'Garden Twin'
                      ])
                        GestureDetector(
                          onTap: () => setState(() => _room = r),
                          child: Pill(
                            r,
                            bg: _room == r
                                ? AppColors.primary
                                : const Color(0xFFF9F3E3),
                            fg: _room == r ? Colors.white : AppColors.muted,
                          ),
                        ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Divider(),
                  ),
                  _Line('$nights Nights Stay', rupees(widget.roomTotal, decimals: true)),
                  const SizedBox(height: 10),
                  _Line('Service Fee & Tax', rupees(widget.fees, decimals: true)),
                  if (widget.discount > 0) ...[
                    const SizedBox(height: 10),
                    _Line('Membership Discount',
                        '-${rupees(widget.discount, decimals: true)}',
                        color: AppColors.primaryLight),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Price',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700)),
                      Text(
                        rupees(widget.total, decimals: true),
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _complete,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Complete Booking'),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded, size: 19),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text(
                'By clicking the button above, you agree to our Terms of '
                'Service and Cancellation Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, color: AppColors.faint, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.muted),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator ??
              (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          decoration: InputDecoration(hintText: 'Enter ${label.toLowerCase()}'),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _Round(
              icon: Icons.remove_rounded,
              onTap: value > min ? () => onChanged(value - 1) : null,
            ),
            SizedBox(
              width: 34,
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            _Round(
              icon: Icons.add_rounded,
              onTap: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? AppColors.primary : AppColors.faint,
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value, {this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label,
              style: const TextStyle(fontSize: 13.5, color: AppColors.muted)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.text)),
      ],
    );
  }
}
