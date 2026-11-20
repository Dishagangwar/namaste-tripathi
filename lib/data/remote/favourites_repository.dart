import 'package:flutter/foundation.dart';

import '../repositories.dart';
import 'supabase_service.dart';

/// Saved properties and restaurants, one row per saved item.
class FavouritesRepository implements FavouritesSource {
  const FavouritesRepository();

  static const propertyType = 'property';
  static const restaurantType = 'restaurant';

  bool get isLive => SupabaseService.isReady && SupabaseService.isSignedIn;

  /// Returns `{'property': {...ids}, 'restaurant': {...ids}}`, or null when
  /// there is nothing to read from.
  @override
  Future<Map<String, Set<String>>?> fetch() async {
    if (!isLive) return null;
    try {
      final result = await SupabaseService.client
          .from('favourites')
          .select('item_type, item_id');
      final grouped = <String, Set<String>>{
        propertyType: <String>{},
        restaurantType: <String>{},
      };
      for (final row in result) {
        final map = Map<String, dynamic>.from(row as Map);
        final type = map['item_type']?.toString() ?? '';
        final id = map['item_id']?.toString() ?? '';
        if (id.isEmpty) continue;
        grouped.putIfAbsent(type, () => <String>{}).add(id);
      }
      return grouped;
    } catch (error) {
      debugPrint('Supabase: favourites fetch failed — $error');
      return null;
    }
  }

  @override
  Future<void> add(String itemType, String itemId) async {
    final userId = SupabaseService.currentUser?.id;
    if (!isLive || userId == null) return;
    try {
      // user_id is sent explicitly rather than left to the column default,
      // so the insert satisfies the RLS check even if that default changes.
      await SupabaseService.client.from('favourites').upsert(
        {'user_id': userId, 'item_type': itemType, 'item_id': itemId},
        onConflict: 'user_id,item_type,item_id',
      );
    } catch (error) {
      debugPrint('Supabase: favourite add failed — $error');
    }
  }

  @override
  Future<void> remove(String itemType, String itemId) async {
    if (!isLive) return;
    try {
      await SupabaseService.client
          .from('favourites')
          .delete()
          .eq('item_type', itemType)
          .eq('item_id', itemId);
    } catch (error) {
      debugPrint('Supabase: favourite remove failed — $error');
    }
  }
}
