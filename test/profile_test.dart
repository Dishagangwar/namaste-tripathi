import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:namaste_tripathi/bloc/bookings/bookings_bloc.dart';
import 'package:namaste_tripathi/bloc/catalog/catalog_bloc.dart';
import 'package:namaste_tripathi/bloc/favourites/favourites_bloc.dart';
import 'package:namaste_tripathi/bloc/preferences/preferences_cubit.dart';
import 'package:namaste_tripathi/bloc/session/session_bloc.dart';
import 'package:namaste_tripathi/core/theme.dart';
import 'package:namaste_tripathi/features/profile/profile_screen.dart';
import 'package:namaste_tripathi/features/profile/saved_addresses_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesCubit', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('settings survive a restart', () async {
      final first = PreferencesCubit();
      await first.load();
      first
        ..addAddress('Home', '12 Park Road')
        ..addUpi('me@upi')
        ..setOffers(true)
        ..setLanguage('hi')
        ..setTextSize(TextSize.large);
      // Writes are fire-and-forget; let them land.
      await Future<void>.delayed(Duration.zero);

      final second = PreferencesCubit();
      await second.load();
      expect(second.state.addresses.single.label, 'Home');
      expect(second.state.payments.single.detail, 'me@upi');
      expect(second.state.offers, isTrue);
      expect(second.state.language, 'hi');
      expect(second.state.textSize, TextSize.large);
    });

    test('a card keeps only its last four digits', () async {
      final cubit = PreferencesCubit();
      await cubit.load();
      cubit.addCard('4242 4242 4242 1234');
      expect(cubit.state.payments.single.detail, '•••• 1234');
      expect(cubit.state.payments.single.detail, isNot(contains('4242')));
    });

    test('edit and remove an address', () async {
      final cubit = PreferencesCubit();
      await cubit.load();
      cubit.addAddress('Work', 'Office Lane');
      final a = cubit.state.addresses.single;
      cubit.updateAddress(
          SavedAddress(id: a.id, label: 'Office', address: a.address));
      expect(cubit.state.addresses.single.label, 'Office');
      cubit.removeAddress(a.id);
      expect(cubit.state.addresses, isEmpty);
    });
  });

  testWidgets('every row on the profile opens a real screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesCubit();
    await prefs.load();
    // Tall enough that every row is on screen without scrolling.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Future<void> openRow(String row, String expectOnScreen) async {
      // Start from nothing so the previous row's screen is not still open.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => SessionBloc()),
            BlocProvider(create: (_) => BookingsBloc()),
            BlocProvider(create: (_) => FavouritesBloc()),
            BlocProvider(create: (_) => CatalogBloc()),
            BlocProvider.value(value: prefs),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(body: ProfileScreen()),
          ),
        ),
      );
      await tester.tap(find.text(row));
      await tester.pumpAndSettle();
      expect(find.text(expectOnScreen), findsWidgets, reason: row);
      expect(find.textContaining('coming soon'), findsNothing, reason: row);
    }

    await openRow('Edit profile', 'Save changes');
    await openRow('Saved addresses', 'Add address');
    await openRow('Payment methods', 'Add UPI ID');
    await openRow('Notifications', 'Order updates');
    await openRow('Language', 'हिन्दी');
    await openRow('Appearance', 'TEXT SIZE');
    await openRow('Help centre', 'FREQUENTLY ASKED');
    await openRow('Privacy policy', 'What we collect');
    await openRow('Terms of service', 'Using the app');
  });

  testWidgets('adding an address validates then saves it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesCubit();
    await prefs.load();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SessionBloc()),
          BlocProvider.value(value: prefs),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: prefs),
                        BlocProvider.value(
                            value: context.read<SessionBloc>()),
                      ],
                      child: const SavedAddressesScreen(),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add address'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Give it a label'), findsOneWidget);
    expect(prefs.state.addresses, isEmpty);

    await tester.enterText(find.byType(TextFormField).at(0), 'Home');
    await tester.enterText(find.byType(TextFormField).at(1), '12 Park Road');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(prefs.state.addresses.single.address, '12 Park Road');
    expect(find.text('12 Park Road'), findsOneWidget);
  });
}
