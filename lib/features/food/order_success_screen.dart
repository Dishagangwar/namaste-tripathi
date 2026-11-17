import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

const _stages = ['Confirmed', 'Preparing', 'Out for delivery'];

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({
    super.key,
    required this.restaurantName,
    required this.image,
    required this.lines,
    required this.subtotal,
    required this.deliveryFee,
    required this.taxes,
    required this.discount,
    required this.couponCode,
    required this.total,
  });

  final String restaurantName;
  final String image;
  final List<String> lines;
  final double subtotal;
  final double deliveryFee;
  final double taxes;
  final double discount;
  final String? couponCode;
  final double total;

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late final String _orderId =
      '#AH-${(Random().nextInt(899999) + 100000)}';
  int _stage = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Nudge the tracker forward so the screen feels alive, as in the demo.
    _timer = Timer(const Duration(seconds: 6), () {
      if (mounted) setState(() => _stage = 2);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 30, 16, 24),
          children: [
            Center(
              child: Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 42),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Order Placed\nSuccessfully!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 27, fontWeight: FontWeight.w800, height: 1.25),
            ),
            const SizedBox(height: 12),
            Text(
              'Your feast from ${widget.restaurantName} is on its way.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F0DE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ORDER ID: $_orderId',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: AppColors.muted),
                ),
              ),
            ),
            const SizedBox(height: 26),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'ESTIMATED ARRIVAL',
                    style: TextStyle(
                      fontSize: 10.5,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '24-30',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        TextSpan(
                          text: '  mins',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  _Tracker(stage: _stage),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 20, color: AppColors.muted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DELIVERING TO',
                              style: TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 0.7,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              session.address,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: 96,
                        width: double.infinity,
                        child: AppImage(widget.image),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 12,
                        child: Text(
                          widget.restaurantName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (final l in widget.lines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                l,
                                style: const TextStyle(
                                    fontSize: 13.5, color: AppColors.muted),
                              ),
                            ),
                          ),
                        const Divider(height: 24),
                        _Row('Item Total', rupees(widget.subtotal)),
                        const SizedBox(height: 8),
                        _Row(
                          'Delivery Fee',
                          widget.deliveryFee == 0
                              ? 'FREE'
                              : rupees(widget.deliveryFee),
                        ),
                        const SizedBox(height: 8),
                        _Row('Taxes & Charges', rupees(widget.taxes)),
                        if (widget.discount > 0) ...[
                          const SizedBox(height: 8),
                          _Row(
                            'Coupon Discount (${widget.couponCode})',
                            '-${rupees(widget.discount)}',
                            color: AppColors.success,
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Paid',
                                style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700)),
                            Text(
                              rupees(widget.total),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.color});
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
              style: TextStyle(
                  fontSize: 13.5, color: color ?? AppColors.muted)),
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

class _Tracker extends StatelessWidget {
  const _Tracker({required this.stage});
  final int stage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(_stages.length * 2 - 1, (i) {
            if (i.isOdd) {
              final done = (i ~/ 2) < stage;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: 3,
                  color: done ? AppColors.text : AppColors.border,
                ),
              );
            }
            final index = i ~/ 2;
            final done = index <= stage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: done ? AppColors.text : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? AppColors.text : AppColors.border,
                  width: 2.4,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _stages.length; i++)
              Expanded(
                child: Text(
                  _stages[i].toUpperCase(),
                  textAlign: i == 0
                      ? TextAlign.left
                      : i == _stages.length - 1
                          ? TextAlign.right
                          : TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w600,
                    color: i <= stage ? AppColors.text : AppColors.faint,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
