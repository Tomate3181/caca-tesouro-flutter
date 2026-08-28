import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/constants/app_constants.dart';
import 'views/home_hunt_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConstants.colorDarkBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const TreasureHuntApp());
}

class TreasureHuntApp extends StatelessWidget {
  const TreasureHuntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caça ao Tesouro AR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.colorDarkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.colorAccent,
          secondary: AppConstants.colorGold,
          surface: AppConstants.colorCardBg,
          onSurface: Colors.white,
        ),
        cardTheme: CardTheme(
          color: AppConstants.colorCardBg,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.colorDarkBg,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeHuntScreen(),
    );
  }
}
