import 'package:flutter/foundation.dart';

import '../models.dart';
import '../repositories.dart';
import 'mappers.dart';
import 'supabase_service.dart';

/// Bike taxi, e-rickshaw, parcel and cab rides, owner-scoped by RLS.
class RidesRepository implements RidesSource {
  const RidesRepository();

  bool get isLive => SupabaseService.isReady && SupabaseService.isSignedIn;

  @override
  Future<List<Ride>?> fetch() async {
    if (!isLive) return null;
    try {
      final result = await SupabaseService.client
          .from('rides')
          .select()
          .order('created_at', ascending: false);
      return [
        for (final row in result)
          rideFromRow(Map<String, dynamic>.from(row as Map)),
      ];
    } catch (error) {
      debugPrint('Supabase: rides fetch failed — $error');
      return null;
    }
  }

  @override
  Future<Ride?> book(Ride ride) async {
    final userId = SupabaseService.currentUser?.id;
    if (!isLive || userId == null) return null;
    try {
      final row = await SupabaseService.client
          .from('rides')
          .insert({...rideToRow(ride), 'user_id': userId})
          .select()
          .single();
      return rideFromRow(Map<String, dynamic>.from(row));
    } catch (error) {
      debugPrint('Supabase: ride insert failed — $error');
      return null;
    }
  }
}
