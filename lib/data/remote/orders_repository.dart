import 'package:flutter/foundation.dart';

import '../models.dart';
import '../repositories.dart';
import 'mappers.dart';
import 'supabase_service.dart';

/// Food orders. Rows are owner-scoped by RLS, so no query here filters by
/// user id — the database does it.
class OrdersRepository implements OrdersSource {
  const OrdersRepository();

  bool get isLive => SupabaseService.isReady && SupabaseService.isSignedIn;

  @override
  Future<List<FoodOrder>?> fetch() async {
    if (!isLive) return null;
    try {
      final result = await SupabaseService.client
          .from('orders')
          .select()
          .order('created_at', ascending: false);
      return [
        for (final row in result)
          orderFromRow(Map<String, dynamic>.from(row as Map)),
      ];
    } catch (error) {
      debugPrint('Supabase: orders fetch failed — $error');
      return null;
    }
  }

  @override
  Future<FoodOrder?> place(FoodOrder order) async {
    final userId = SupabaseService.currentUser?.id;
    if (!isLive || userId == null) return null;
    try {
      final row = await SupabaseService.client
          .from('orders')
          .insert({...orderToRow(order), 'user_id': userId})
          .select()
          .single();
      return orderFromRow(Map<String, dynamic>.from(row));
    } catch (error) {
      debugPrint('Supabase: order insert failed — $error');
      return null;
    }
  }
}
