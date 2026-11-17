import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'booking_details_screen.dart';

class HotelDetailScreen extends StatefulWidget {
  const HotelDetailScreen({super.key, required this.hotel});
  final Hotel hotel;

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  DateTimeRange _stay = DateTimeRange(
    start: DateTime(2024, 10, 24),
    end: DateTime(2024, 10, 30),
  );

  int get _nights => _stay.duration.inDays;
  int get _roomTotal => widget.hotel.pricePerNight * _nights;
  int get _resortFee => 120;
  int get _tax => (_roomTotal * 0.009).round();
  int get _discount =>
      (_roomTotal * widget.hotel.discountPercent / 100).round();
  int get _total => _roomTotal + _resortFee + _tax - _discount;

  Future<void> _pickDates() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _stay,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _stay = picked);
  }

  String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _short(DateTime d) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.hotel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Details'),
        leading: const BackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: AppImage(h.image),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  top: 16,
                  left: 16,
                  child: OverlayTag('Premier Collection',
                      color: Color(0xE6FFFFFF)),
                ),
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        h.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 17, color: AppColors.star),
                          const SizedBox(width: 4),
                          Text(
                            '${h.rating} (${h.reviews} reviews)',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.location_on_rounded,
                              size: 15, color: Colors.white70),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              h.location,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 3,
                margin: const EdgeInsets.only(top: 11, right: 10),
                color: AppColors.primary,
              ),
              Expanded(
                child: Text(
                  h.tagline,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF4E2),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Text(
              h.description,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.muted, height: 1.65),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final a in h.amenities) Pill(a),
            ],
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SoftIconBox(Icons.explore_outlined, size: 44, iconSize: 21),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'LOCATION',
                        style: TextStyle(
                          fontSize: 9.5,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        h.location,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Starting at',
                            style: TextStyle(
                                fontSize: 12.5, color: AppColors.muted),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                rupees(h.pricePerNight),
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800),
                              ),
                              const Text(
                                ' / night',
                                style: TextStyle(
                                    fontSize: 14, color: AppColors.muted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (h.discountPercent > 0)
                      Pill(
                        '${h.discountPercent}% OFF',
                        bg: const Color(0xFFFDE8E8),
                        fg: AppColors.danger,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickDates,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: _DateBox('CHECK-IN', _fmt(_stay.start))),
                        Container(
                          width: 1,
                          height: 56,
                          color: AppColors.border,
                        ),
                        Expanded(
                            child: _DateBox('CHECK-OUT', _fmt(_stay.end))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _Line('${rupees(h.pricePerNight)} × $_nights nights',
                    rupees(_roomTotal)),
                const SizedBox(height: 10),
                _Line('Resort Fee', rupees(_resortFee)),
                const SizedBox(height: 10),
                _Line('Taxes', rupees(_tax)),
                if (_discount > 0) ...[
                  const SizedBox(height: 10),
                  _Line('Member Discount', '-${rupees(_discount)}',
                      color: AppColors.success),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    Text(
                      rupees(_total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _book,
                  child: const Text('Book Now'),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'NO HIDDEN BOOKING FEES',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.faint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3A2A05).withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${rupees(h.pricePerNight)} / night',
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_short(_stay.start)} - ${_short(_stay.end)}',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: _book,
                style: FilledButton.styleFrom(minimumSize: const Size(150, 52)),
                child: const Text('Book Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _book() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(
          hotel: widget.hotel,
          stay: _stay,
          total: _total.toDouble(),
          roomTotal: _roomTotal.toDouble(),
          fees: (_resortFee + _tax).toDouble(),
          discount: _discount.toDouble(),
        ),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
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
              style:
                  TextStyle(fontSize: 13.5, color: color ?? AppColors.muted)),
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
