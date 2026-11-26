import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../bloc/session/session_bloc.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

/// Lets the user drop a pin on a Google map and use that spot as the
/// delivery address. The pin stays fixed in the middle of the screen and the
/// map moves under it, so the address is whatever the camera settles on.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.startAtCurrentLocation = false});

  /// Jump straight to the device position instead of the default city.
  final bool startAtCurrentLocation;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // Used until the device position is known (or if permission is refused).
  static const _fallback = LatLng(26.8467, 80.9462);

  GoogleMapController? _map;
  LatLng _center = _fallback;
  String _label = 'Locating…';
  String _address = '';
  bool _resolving = true;
  bool _locating = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.startAtCurrentLocation) {
      _goToCurrentLocation();
    } else {
      _resolve(_center);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _map?.dispose();
    super.dispose();
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'Turn on location services to use your current location.';
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw 'Location permission was denied. You can still pick a spot on the map.';
      }
      final pos = await Geolocator.getCurrentPosition();
      final target = LatLng(pos.latitude, pos.longitude);
      await _map?.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
      _center = target;
      await _resolve(target);
    } catch (e) {
      if (mounted) {
        showAppSnack(context, e is String ? e : 'Could not get your location.');
        await _resolve(_center);
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _resolve(LatLng point) async {
    setState(() => _resolving = true);
    String label = 'Dropped pin';
    String address =
        '${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}';
    try {
      final marks = await Geocoding().placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (marks.isNotEmpty) {
        final m = marks.first;
        String join(List<String?> parts) => parts
            .whereType<String>()
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toSet()
            .join(', ');
        final short = join([m.name, m.subLocality]);
        final full = join([
          m.name,
          m.subLocality,
          m.locality,
          m.administrativeArea,
          m.postalCode,
        ]);
        if (full.isNotEmpty) address = full;
        if (short.isNotEmpty) label = short;
      }
    } catch (_) {
      // Geocoding is best-effort; the raw coordinates above still work.
    }
    // Ignore a result for a spot the user has already moved away from.
    if (!mounted || point != _center) return;
    setState(() {
      _label = label;
      _address = address;
      _resolving = false;
    });
  }

  void _onCameraMove(CameraPosition p) => _center = p.target;

  void _onCameraIdle() {
    _debounce?.cancel();
    final point = _center;
    _debounce = Timer(const Duration(milliseconds: 300), () => _resolve(point));
  }

  void _confirm() {
    context.read<SessionBloc>().add(SessionLocationChanged(_label, _address));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            onMapCreated: (c) => _map = c,
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                // Lift the icon so its tip, not its middle, marks the point.
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(
                  Icons.location_pin,
                  size: 44,
                  color: AppColors.danger,
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 190,
            child: FloatingActionButton.small(
              heroTag: 'locate_me',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              onPressed: _locating ? null : _goToCurrentLocation,
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.sheet),
                ),
                boxShadow: kSoftShadow,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _resolving ? 'Finding address…' : _address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _resolving ? null : _confirm,
                        child: const Text('Confirm location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
