import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bookings/bookings_bloc.dart';
import 'bloc/cart/cart_bloc.dart';
import 'bloc/catalog/catalog_bloc.dart';
import 'bloc/config/config_bloc.dart';
import 'bloc/favourites/favourites_bloc.dart';
import 'bloc/orders/orders_bloc.dart';
import 'bloc/rides/rides_bloc.dart';
import 'bloc/session/session_bloc.dart';
import 'core/theme.dart';
import 'data/backend.dart';
import 'data/remote/supabase_service.dart';
import 'features/auth/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
  // Never throws: without a key, or with the project unreachable, the app
  // runs on the bundled catalogue instead of failing to start.
  await SupabaseService.initialize();

  // Loud on purpose. A build that quietly lands on the demo backend looks
  // exactly like a working one -- it signs you in, accepts bookings, and
  // keeps none of it -- so the first line in the console says which it is.
  if (kDebugMode) {
    debugPrint('=' * 62);
    debugPrint('  BACKEND: ${Backend.mode.name.toUpperCase()}');
    debugPrint('  ${Backend.reason}');
    if (Backend.isDemo) {
      debugPrint('  Nothing you do will be saved to Supabase.');
    }
    debugPrint('=' * 62);
  }

  runApp(const NamasteTripathiApp());
}

class NamasteTripathiApp extends StatelessWidget {
  const NamasteTripathiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SessionBloc()),
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(create: (_) => FavouritesBloc()),
        BlocProvider(create: (_) => BookingsBloc()),
        BlocProvider(create: (_) => OrdersBloc()),
        BlocProvider(create: (_) => RidesBloc()),
        // lazy: false matters here -- a lazy bloc would not be built until
        // the home screen first read it, so the fetch would start after
        // onboarding rather than during it.
        BlocProvider(
          lazy: false,
          create: (_) => CatalogBloc()..add(const CatalogRequested()),
        ),
        // The taxonomy is read by the very first screens and is not
        // user-specific, so it loads alongside the catalogue rather than
        // waiting for sign-in.
        BlocProvider(
          lazy: false,
          create: (_) => ConfigBloc()..add(const ConfigRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'Namaste Tripathi',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const OnboardingScreen(),
      ),
    );
  }
}
