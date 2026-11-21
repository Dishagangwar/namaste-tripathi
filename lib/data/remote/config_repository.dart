import 'package:flutter/foundation.dart';

import '../mock_data.dart';
import '../models.dart';
import '../repositories.dart';
import 'mappers.dart';
import 'supabase_service.dart';

/// The app's taxonomy: service tiles, filter chips, saved addresses, ride
/// classes and editorial copy.
///
/// Five small tables rather than one, because each is edited separately in
/// the dashboard. They are assembled into the one [AppConfig] the app reads,
/// which keeps the shape identical to the demo backend's `/config` payload.
class ConfigRepository implements ConfigSource {
  const ConfigRepository();

  bool get isLive => SupabaseService.isReady;

  @override
  Future<AppConfig?> fetch() async {
    if (!isLive) return null;
    try {
      final client = SupabaseService.client;
      // `order` defaults to DESCENDING in supabase-dart, so `ascending: true`
      // is load-bearing on every one of these.
      final results = await Future.wait([
        client.from('service_categories').select().order('sort_order',
            ascending: true),
        client.from('saved_places').select().order('sort_order',
            ascending: true),
        client.from('ride_options').select().order('sort_order',
            ascending: true),
        client
            .from('filter_options')
            .select('group_key, label')
            .order('sort_order', ascending: true),
        client.from('app_settings').select('key, value'),
      ]);

      final filters = <String, List<String>>{};
      for (final row in results[3]) {
        final map = Map<String, dynamic>.from(row as Map);
        final group = map['group_key']?.toString() ?? '';
        final label = map['label']?.toString() ?? '';
        if (group.isEmpty || label.isEmpty) continue;
        filters.putIfAbsent(group, () => <String>[]).add(label);
      }

      final settings = <String, String>{};
      for (final row in results[4]) {
        final map = Map<String, dynamic>.from(row as Map);
        settings[map['key']?.toString() ?? ''] = map['value']?.toString() ?? '';
      }

      // Rebuilt into the wire shape `/config` serves so one parser covers
      // both backends.
      return appConfigFromRow({
        'categories': [for (final row in results[0]) Map<String, dynamic>.from(row as Map)],
        'saved_places': [for (final row in results[1]) Map<String, dynamic>.from(row as Map)],
        'ride_options': [for (final row in results[2]) Map<String, dynamic>.from(row as Map)],
        'filters': filters,
        'traveler_tip': settings['traveler_tip'],
      }, kBundledConfig);
    } catch (error) {
      debugPrint('Supabase: config fetch failed — $error');
      return null;
    }
  }
}
