import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_state.dart';
import 'core/catalog_state.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionState()),
        ChangeNotifierProvider(create: (_) => CartState()),
        ChangeNotifierProvider(create: (_) => FavouritesState()),
        ChangeNotifierProvider(create: (_) => BookingsState()),
        // lazy: false matters here -- a lazy provider would not build until
        // the home screen first read it, so the fetch would start after
        // onboarding rather than during it.
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => CatalogState()..load(),
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
