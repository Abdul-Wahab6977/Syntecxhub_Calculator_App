import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'controllers/calculator_controller.dart';
import 'screens/calculator_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Allow both portrait and landscape — the UI is fully responsive to both.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Match the system status bar to our dark, obsidian theme.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const CalculatorApp());
}

/// Root widget. Wires up the [CalculatorController] via Provider so it can
/// be accessed anywhere below in the widget tree without prop-drilling.
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalculatorController(),
      child: MaterialApp(
        title: 'Calculator',
        debugShowCheckedModeBanner: false,
        theme: _buildDarkTheme(),
        home: const CalculatorScreen(),
      ),
    );
  }

  /// Sleek, modern, Apple/Google-inspired dark theme — deep obsidian
  /// background with a Tech Blue accent used for interactive elements.
  ThemeData _buildDarkTheme() {
    const seed = Color(0xFF007AFF);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
      ),
      fontFamily: 'Roboto',
      splashFactory: InkRipple.splashFactory,
    );
  }
}
