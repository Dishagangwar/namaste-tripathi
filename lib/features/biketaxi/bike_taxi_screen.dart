import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/config/config_bloc.dart';
import '../../bloc/rides/rides_bloc.dart';
import '../../bloc/session/session_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../shell/services_tab.dart';

class BikeTaxiScreen extends StatefulWidget {
  const BikeTaxiScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<BikeTaxiScreen> createState() => _BikeTaxiScreenState();
}

class _BikeTaxiScreenState extends State<BikeTaxiScreen> {
  final _destination = TextEditingController();
  int _selectedRide = 0;
  final double _distanceKm = 7.4;

  @override
  void dispose() {
    _destination.dispose();
    super.dispose();
  }

  bool get _hasDestination => _destination.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionBloc>().state;
    final config = context.watch<ConfigBloc>().state;
    final rides = context.watch<RidesBloc>().state;

    // Served by `/config`, so the fares and ETAs can change without a
    // release. The list is never empty -- it falls back to the bundled
    // classes -- but the index is clamped in case it shrinks underneath us.
    final options = config.rideOptions;
    final selected = _selectedRide.clamp(0, options.length - 1);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          ModuleHeader(title: 'Bike taxi', onBack: widget.onBack),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    session.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F2E0),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_outline_rounded,
                      size: 18, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              children: [
                const Text(
                  'Bike taxi',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _destination,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Enter Destination...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.faint),
                    suffixIcon: _hasDestination
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 19),
                            onPressed: () {
                              _destination.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    fillColor: const Color(0xFFF9F3E3),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
                if (!_hasDestination) ...[
                  const SizedBox(height: 10),
                  for (final place in config.savedPlaces)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: SoftIconBox(place.icon, size: 40, iconSize: 18),
                      title: Text(place.label,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        place.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.muted),
                      ),
                      onTap: () {
                        _destination.text = place.address;
                        setState(() {});
                      },
                    ),
                ],
                if (_hasDestination) ...[
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Text(
                        'Choose a ride',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        '$_distanceKm km',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < options.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RideTile(
                        ride: options[i],
                        fare: options[i].fareFor(_distanceKm),
                        selected: selected == i,
                        onTap: () => setState(() => _selectedRide = i),
                      ),
                    ),
                ] else ...[
                  const SizedBox(height: 26),
                  const Text(
                    'Other Services',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final ride
                          in options.where((r) => r.title != 'Bike taxi'))
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: AppCard(
                              padding: const EdgeInsets.all(12),
                              onTap: () => showAppSnack(
                                  context, 'Enter a destination first.'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color:
                                          ride.color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(ride.icon,
                                        size: 20, color: ride.color),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    ride.title,
                                    style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    ride.subtitle,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.muted,
                                        height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (rides.items.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    const Text(
                      'Your rides',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    for (final ride in rides.items.take(5))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RideHistoryTile(ride: ride),
                      ),
                  ],
                ],
              ],
            ),
          ),
          if (_hasDestination && options.isNotEmpty)
            BottomActionBar(
              caption: options[selected].title,
              value: rupees(options[selected].fareFor(_distanceKm)),
              actionLabel: 'Confirm ride',
              onAction: () => _confirm(context, options[selected]),
            ),
        ],
      ),
    );
  }

  /// Books the ride, then opens the search sheet on it. The sheet follows
  /// the ride in [RidesBloc], so the reference number fills in when the
  /// write lands.
  void _confirm(BuildContext context, RideOption option) {
    final now = DateTime.now();
    final ride = Ride(
      id: 'local-${now.microsecondsSinceEpoch}',
      optionId: option.id,
      rideType: option.title,
      fromAddress: context.read<SessionBloc>().state.address,
      toAddress: _destination.text.trim(),
      distanceKm: _distanceKm,
      fare: option.fareFor(_distanceKm),
      eta: option.eta,
    );

    context.read<RidesBloc>().add(RideBooked(ride));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => _SearchingSheet(option: option, localId: ride.id),
    );
  }
}

/// The "looking for a driver" sheet.
///
/// It reads the ride back out of the bloc rather than holding a copy, so the
/// reference the server assigns appears without the sheet being reopened.
class _SearchingSheet extends StatelessWidget {
  const _SearchingSheet({required this.option, required this.localId});

  final RideOption option;
  final String localId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RidesBloc, RidesState>(
      builder: (context, state) {
        final ride = state.items.where((r) => r.id == localId).toList();
        final booked = ride.isEmpty ? null : ride.first;
        final failed = state.status == RidesStatus.failed;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: option.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(option.icon, size: 30, color: option.color),
                ),
                const SizedBox(height: 18),
                Text(
                  failed
                      ? 'Could not book that ride'
                      : 'Looking for a ${option.title.toLowerCase()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (booked != null)
                  Text(
                    '${booked.eta} • ${rupees(booked.fare)} to '
                    '${booked.toAddress}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.muted, height: 1.5),
                  ),
                if (booked?.reference != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F0DE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'RIDE ${booked!.reference}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                if (!failed)
                  const LinearProgressIndicator(
                    backgroundColor: AppColors.border,
                    color: AppColors.primary,
                  ),
                const SizedBox(height: 22),
                OutlinedButton(
                  onPressed: () {
                    if (booked != null) {
                      context.read<RidesBloc>().add(RideCancelled(booked.id));
                    }
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(failed ? 'Close' : 'Cancel search'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RideHistoryTile extends StatelessWidget {
  const _RideHistoryTile({required this.ride});

  final Ride ride;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SoftIconBox(Icons.near_me_outlined, size: 40, iconSize: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ride.toAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  '${ride.rideType} • ${_statusLabel(ride.status)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            rupees(ride.fare),
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(RideStatus status) => switch (status) {
        RideStatus.searching => 'Finding a driver',
        RideStatus.assigned => 'Driver on the way',
        RideStatus.completed => 'Completed',
        RideStatus.cancelled => 'Cancelled',
      };
}

class _RideTile extends StatelessWidget {
  const _RideTile({
    required this.ride,
    required this.fare,
    required this.selected,
    required this.onTap,
  });

  final RideOption ride;
  final int fare;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected ? kSoftShadow : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: ride.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(ride.icon, size: 24, color: ride.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ride.title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${ride.subtitle} • ${ride.eta}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Text(
              rupees(fare),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
