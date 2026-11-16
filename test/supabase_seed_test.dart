import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/data/icon_registry.dart';

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
