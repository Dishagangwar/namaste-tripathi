import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Asset paths are plain strings, so a rename or typo would not fail the build
/// -- it would just render a grey placeholder. These tests catch that instead.
void main() {
  final catalogue = File('lib/data/images.dart').readAsStringSync();
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final referenced = RegExp(r"'(assets/images/[^']+)'")
      .allMatches(catalogue)
      .map((m) => m.group(1)!)
      .toSet();

  test('the catalogue actually references assets', () {
    expect(referenced, isNotEmpty);
  });

  test('every referenced asset exists on disk', () {
    final missing = referenced.where((p) => !File(p).existsSync()).toList()
      ..sort();
    expect(missing, isEmpty, reason: 'missing asset files: $missing');
  });

  test('no bundled image is left unused', () {
    final onDisk = Directory('assets/images')
        .listSync()
        .whereType<File>()
        .map((f) => f.path)
        .where((p) => p.endsWith('.jpg'))
        .toSet();
    final orphans = onDisk.difference(referenced).toList()..sort();
    expect(orphans, isEmpty, reason: 'unused asset files: $orphans');
  });

  test('pubspec declares the images directory', () {
    expect(pubspec, contains('assets/images/'));
  });

  test('no photo is still loaded over the network', () {
    expect(
      catalogue.contains('images.unsplash.com'),
      isFalse,
      reason: 'images.dart should point at bundled assets, not remote URLs',
    );
  });
}
