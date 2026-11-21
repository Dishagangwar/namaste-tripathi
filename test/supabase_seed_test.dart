import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/data/icon_registry.dart';
import 'package:namaste_tripathi/data/mock_data.dart';
import 'package:namaste_tripathi/data/models.dart';

/// The seed is hand-written SQL, so nothing in the build checks it against
/// the app. These tests do: every asset it names has to be bundled, and
/// every icon name has to resolve, or rows would render blank in the UI.
void main() {
  final seed = File('supabase/seed.sql').readAsStringSync();
  final migrations = Directory('supabase/migrations')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.sql'))
      .toList();

  test('the seed and a migration are both present', () {
    expect(seed, isNotEmpty);
    expect(migrations, isNotEmpty);
  });

  test('every asset the seed points at is bundled', () {
    final referenced = RegExp(r"'(assets/images/[^']+)'")
        .allMatches(seed)
        .map((m) => m.group(1)!)
        .toSet();

    expect(referenced, isNotEmpty);
    final missing = referenced.where((p) => !File(p).existsSync()).toList()
      ..sort();
    expect(missing, isEmpty, reason: 'seed references missing assets: $missing');
  });

  test('every expertise icon in the seed resolves', () {
    // Matches the `('sp1', 'Label', 'icon_name', 1)` expertise rows.
    final names = RegExp(r"'sp\d+',\s*'[^']*',\s*'([a-z_]+)',\s*\d+")
        .allMatches(seed)
        .map((m) => m.group(1)!)
        .toSet();

    expect(names, isNotEmpty);
    final unknown = names.where((n) => !kIconRegistry.containsKey(n)).toList()
      ..sort();
    expect(unknown, isEmpty, reason: 'icons not in the registry: $unknown');
  });

  /// The config rows live in a migration, not in the seed: `db push
  /// --include-seed` will not re-run a seed file it has already recorded, so
  /// rows added to one never reach a database that was seeded before them.
  final configRows = File(
    'supabase/migrations/20261121110000_config_rows.sql',
  ).readAsStringSync();

  /// The rows of one `insert into public.<table> ... ;` statement.
  String block(String table) {
    final start = configRows.indexOf('insert into public.$table');
    expect(start, isNot(-1), reason: 'no config block for $table');
    final end = configRows.indexOf(';', start);
    return configRows.substring(start, end == -1 ? configRows.length : end);
  }

  group('config rows', () {
    test('they are a migration, so they reach every environment', () {
      // Being in seed.sql would silently skip any database already seeded.
      expect(configRows, contains('insert into public.service_categories'));
      expect(seed, isNot(contains('insert into public.service_categories')));
    });

    test('every table they write to is created by a migration', () {
      final schema = migrations.map((f) => f.readAsStringSync()).join('\n');
      final written = RegExp(r'insert into public\.(\w+)')
          .allMatches(configRows)
          .map((m) => m.group(1)!)
          .toSet();

      expect(written, hasLength(5));
      final undeclared = written
          .where((t) => !schema.contains('create table if not exists public.$t'))
          .toList()
        ..sort();
      expect(undeclared, isEmpty, reason: 'tables with no migration: $undeclared');
    });

    test('every icon it names resolves in the registry', () {
      // Icon columns sit at a known position in each table, so each shape
      // is matched rather than every quoted string in the file.
      final icons = <String>{
        // ('id', 'label', 'icon', is_wide, n)
        ...RegExp(r"\('[\w-]+',\s*'[^']*',\s*'([a-z0-9_]+)',\s*(?:true|false)")
            .allMatches(block('service_categories'))
            .map((m) => m.group(1)!),
        // ('id', 'icon', 'label', 'address', n)
        ...RegExp(r"\('[\w-]+',\s*'([a-z0-9_]+)',\s*'[^']*',\s*'[^']*',\s*\d+\)")
            .allMatches(block('saved_places'))
            .map((m) => m.group(1)!),
        // ('id', 'title', 'subtitle', 'icon', '#RRGGBB', ...)
        ...RegExp(r"\('[\w-]+',\s*'[^']*',\s*'[^']*',\s*'([a-z0-9_]+)',\s*'#")
            .allMatches(block('ride_options'))
            .map((m) => m.group(1)!),
      };

      expect(icons, hasLength(greaterThanOrEqualTo(9)));
      final unknown = icons.where((n) => !kIconRegistry.containsKey(n)).toList()
        ..sort();
      expect(unknown, isEmpty, reason: 'icons not in the registry: $unknown');
    });

    test('its filter chips match the bundled ones exactly', () {
      // The two have to agree: a build falls back to the bundled lists when
      // the backend is unreachable, and the chips must not shuffle.
      List<String> seeded(String group) => RegExp(
            r"\('GROUP',\s*'([^']*)',\s*\d+\)".replaceFirst('GROUP', group),
          ).allMatches(block('filter_options')).map((m) => m.group(1)!).toList();

      expect(seeded(FilterGroup.cuisine), kCuisineFilters);
      expect(seeded(FilterGroup.hotel), kHotelFilters);
      expect(seeded(FilterGroup.property), kPropertyFilters);
      expect(seeded(FilterGroup.provider), kProviderFilters);
    });

    test('its service tiles match the bundled ones, wide tile included', () {
      final rows = RegExp(r"\('([\w-]+)',\s*'([^']*)',\s*'[a-z0-9_]+',\s*(true|false)")
          .allMatches(block('service_categories'))
          .toList();

      final grid = [
        for (final m in rows)
          if (m.group(3) == 'false') (m.group(1)!, m.group(2)!),
      ];
      final wide = [
        for (final m in rows)
          if (m.group(3) == 'true') (m.group(1)!, m.group(2)!),
      ];

      expect(grid, [for (final c in kCategories) (c.id, c.label)]);
      expect(wide, [(kWideCategory.id, kWideCategory.label)]);
    });

    test('its ride options match the bundled ids and fares', () {
      final rows = RegExp(
        r"\('([\w-]+)',\s*'([^']*)',\s*'[^']*',\s*'[a-z0-9_]+',\s*'#[0-9A-Fa-f]{6}',\s*'[^']*',\s*(\d+),",
      ).allMatches(block('ride_options')).toList();

      expect(
        [for (final m in rows) (m.group(1)!, m.group(2)!, int.parse(m.group(3)!))],
        [for (final r in kRideOptions) (r.id, r.title, r.pricePerKm)],
      );
    });

    test('its traveler tip matches the bundled copy', () {
      expect(block('app_settings'), contains(kTravelerTip));
    });

    test('its saved places match the bundled ids and addresses', () {
      final rows = RegExp(r"\('([\w-]+)',\s*'[a-z0-9_]+',\s*'([^']*)',\s*'([^']*)',")
          .allMatches(block('saved_places'))
          .toList();

      expect(
        [for (final m in rows) (m.group(1)!, m.group(2)!, m.group(3)!)],
        [for (final p in kSavedPlaces) (p.id, p.label, p.address)],
      );
    });
  });

  test('every table the seed writes to is created by a migration', () {
    final schema = migrations.map((f) => f.readAsStringSync()).join('\n');
    final written = RegExp(r'insert into public\.(\w+)')
        .allMatches(seed)
        .map((m) => m.group(1)!)
        .toSet();

    expect(written, isNotEmpty);
    final undeclared = written
        .where((t) => !schema.contains('create table if not exists public.$t'))
        .toList()
      ..sort();
    expect(undeclared, isEmpty, reason: 'tables with no migration: $undeclared');
  });

  test('row level security is enabled on every table', () {
    final schema = migrations.map((f) => f.readAsStringSync()).join('\n');
    final declared = RegExp(r'create table if not exists public\.(\w+)')
        .allMatches(schema)
        .map((m) => m.group(1)!)
        .toSet();

    expect(declared, isNotEmpty);
    final unprotected = declared
        .where((t) => !schema.contains('alter table public.$t'))
        .toList()
      ..sort();
    expect(unprotected, isEmpty, reason: 'tables without RLS: $unprotected');
  });
}
