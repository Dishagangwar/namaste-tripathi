import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/bookings/bookings_bloc.dart';
import 'bloc/cart/cart_bloc.dart';
import 'bloc/catalog/catalog_bloc.dart';
import 'bloc/favourites/favourites_bloc.dart';
import 'bloc/session/session_bloc.dart';
import 'core/theme.dart';
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
        // lazy: false matters here -- a lazy bloc would not be built until
        // the home screen first read it, so the fetch would start after
        // onboarding rather than during it.
        BlocProvider(
          lazy: false,
          create: (_) => CatalogBloc()..add(const CatalogRequested()),
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
