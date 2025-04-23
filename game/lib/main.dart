import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set full screen immersive mode
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );
  
  runApp(const AsteroidsGame());
}

class AsteroidsGame extends StatelessWidget {
  const AsteroidsGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asteroids',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.orbitronTextTheme(
          Theme.of(context).textTheme.copyWith(
                bodyMedium: const TextStyle(color: Colors.white),
                bodyLarge: const TextStyle(color: Colors.white),
                headlineMedium: const TextStyle(color: Colors.white),
              ),
        ),
      ),
      home: const StartScreen(),
    );
  }
}
