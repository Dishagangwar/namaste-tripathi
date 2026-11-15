import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'features/auth/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));
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
