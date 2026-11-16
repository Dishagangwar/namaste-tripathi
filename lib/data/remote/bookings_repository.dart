import 'package:flutter/foundation.dart';

import '../models.dart';
import 'mappers.dart';
import 'supabase_service.dart';

/// The signed-in user's bookings. Rows are owner-scoped by RLS, so no query
/// here needs to filter by user id — the database does it.
class BookingsRepository {
  const BookingsRepository();

  bool get isLive => SupabaseService.isReady && SupabaseService.isSignedIn;

  /// Newest first. Returns null when there is nothing to read from, which
  /// tells the caller to keep whatever it already has.
  Future<List<Booking>?> fetch() async {
    if (!isLive) return null;
    try {
      final result = await SupabaseService.client
          .from('bookings')
          .select()
          .order('created_at', ascending: false);
      return [
        for (final row in result)
          bookingFromRow(Map<String, dynamic>.from(row as Map)),
      ];
    } catch (error) {
      debugPrint('Supabase: bookings fetch failed — $error');
      return null;
    }
  }

  /// Inserts a booking and returns the stored row (with its database id), or
  /// null when offline — the caller keeps its local copy either way.
  Future<Booking?> add(Booking booking) async {
    final userId = SupabaseService.currentUser?.id;
    if (!isLive || userId == null) return null;
    try {
      final row = await SupabaseService.client
          .from('bookings')
          .insert({...bookingToRow(booking), 'user_id': userId})
          .select()
          .single();
      return bookingFromRow(Map<String, dynamic>.from(row));
    } catch (error) {
      debugPrint('Supabase: booking insert failed — $error');
      return null;
    }
  }
}
