import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

const _slots = <String, List<String>>{
  'MORNING': ['09:00 AM', '10:30 AM'],
  'AFTERNOON': ['02:00 PM', '03:30 PM', '05:00 PM'],
  'EVENING': ['06:30 PM', '07:00 PM'],
};

class ScheduleVisitScreen extends StatefulWidget {
  const ScheduleVisitScreen({
    super.key,
    required this.property,
    this.embedded = false,
  });

  final Property property;

  /// When true the screen lives inside the real-estate tab bar and does not
  /// draw its own back button.
  final bool embedded;

  @override
  State<ScheduleVisitScreen> createState() => _ScheduleVisitScreenState();
}

class _ScheduleVisitScreenState extends State<ScheduleVisitScreen> {
  DateTime _month = DateTime(2023, 10);
  int? _day = 6;
  String? _slot = '02:00 PM';

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  int get _daysInMonth => DateTime(_month.year, _month.month + 1, 0).day;

  /// Monday-first offset for the first cell of the grid.
  int get _leadingBlanks => DateTime(_month.year, _month.month, 1).weekday - 1;

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _day = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                if (!widget.embedded)
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                  )
                else
                  const SizedBox(width: 40),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Schedule Visit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                AppCard(
                  color: const Color(0xFFFBF6E6),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        height: 64,
                        child: AppImage(widget.property.image, radius: 12),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.property.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 5),
                            IconLabel(Icons.location_on_rounded,
                                widget.property.location),
                            const SizedBox(height: 9),
                            Wrap(
                              spacing: 6,
                              children: [
                                const Pill('RESIDENTIAL'),
                                if (widget.property.tags.contains('Premium'))
                                  const Pill('PREMIUM'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Text('Select Date',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _shiftMonth(-1),
                      icon: const Icon(Icons.chevron_left_rounded),
                      color: AppColors.primary,
                    ),
                    Text(
                      '${_monthNames[_month.month - 1]} ${_month.year}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _shiftMonth(1),
                      icon: const Icon(Icons.chevron_right_rounded),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _Calendar(
                  daysInMonth: _daysInMonth,
                  leadingBlanks: _leadingBlanks,
                  selected: _day,
                  onSelect: (d) => setState(() => _day = d),
                ),
                const SizedBox(height: 28),
                const Text('Preferred Time',
                    style:
                        TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                for (final entry in _slots.entries) ...[
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 10.5,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final s in entry.value)
                        GestureDetector(
                          onTap: () => setState(() => _slot = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 13),
                            decoration: BoxDecoration(
                              color: _slot == s
                                  ? AppColors.primary
                                  : const Color(0xFFF8F2E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: _slot == s
                                    ? Colors.white
                                    : AppColors.muted,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF4E2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 20, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Site visits are approximately 45 minutes long. A '
                          'dedicated concierge will meet you at the main lobby '
                          'entrance.',
                          style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                              height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: (_day != null && _slot != null) ? _confirm : null,
                  style: FilledButton.styleFrom(
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.35),
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Confirm Visit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return widget.embedded ? body : Scaffold(body: body);
  }

  void _confirm() {
    final when =
        '${_monthNames[_month.month - 1]} $_day, ${_month.year} • $_slot';

    context.read<BookingsState>().add(
          Booking(
            id: 'visit${DateTime.now().millisecondsSinceEpoch}',
            title: widget.property.name,
            subtitle: 'Site visit with a concierge',
            kind: 'Property Visit',
            when: when,
            status: BookingStatus.confirmed,
            image: widget.property.image,
            location: widget.property.location,
            reference:
                '#PV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          ),
        );

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: Colors.white, size: 30),
        ),
        title: const Text('Visit scheduled',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        content: Text(
          '${widget.property.name}\n$when',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 13.5, color: AppColors.muted, height: 1.6),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(context);
                if (!widget.embedded) Navigator.of(context).maybePop();
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.daysInMonth,
    required this.leadingBlanks,
    required this.selected,
    required this.onSelect,
  });

  final int daysInMonth;
  final int leadingBlanks;
  final int? selected;
  final ValueChanged<int> onSelect;

  static const _labels = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final isSelected = d == selected;
      cells.add(
        GestureDetector(
          onTap: () => onSelect(d),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$d',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.text,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            for (final l in _labels)
              Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w600,
                      color: AppColors.faint,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 6,
          children: cells,
        ),
      ],
    );
  }
}
