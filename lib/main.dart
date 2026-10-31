import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'domain/systems/data_loader.dart';
import 'providers/game_state_provider.dart';
import 'ui/main_dashboard.dart';
import 'ui/widgets/pixel_viewport.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataLoader.loadAllData();
  runApp(const BastoneroApp());
}

class BastoneroApp extends StatelessWidget {
  const BastoneroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GameStateProvider>(
      create: (_) => GameStateProvider()..loadSavedGame(),
      child: MaterialApp(
        title: 'Bastonero: Arnis Story',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          fontFamily: 'Silkscreen',
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFF59E0B),
            secondary: Color(0xFF38BDF8),
            surface: Color(0xFF1E293B),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              textStyle: const TextStyle(
                fontFamily: 'Silkscreen',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        home: const PixelViewport(
          child: MainDashboard(),
        ),
      ),
    );
  }
}
