import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/asteroid.dart';
import '../utils/game_constants.dart';
import '../widgets/space_button.dart';
import 'game_screen.dart';
import 'high_scores_screen.dart';
import 'settings_screen.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int highScore = 0;
  final List<Asteroid> _backgroundAsteroids = [];
  final Random _random = Random();
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _loadHighScore();
    _initBackgroundAsteroids();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }
  
  void _initBackgroundAsteroids() {
    for (int i = 0; i < 5; i++) {
      _backgroundAsteroids.add(
        Asteroid(
          x: _random.nextDouble() * 400,
          y: _random.nextDouble() * 600,
          size: AsteroidSize.values[_random.nextInt(AsteroidSize.values.length)],
          speed: 0.5 + _random.nextDouble() * 0.5,
          angle: _random.nextDouble() * 2 * pi,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage('assets/images/space_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Title with Animation
                ScaleTransition(
                  scale: _animation,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                        stops: [0.0, 1.0],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'ASTEROIDS',
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // High Score Display
                Text(
                  'HIGH SCORE: $highScore',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Game Menu Buttons
                SpaceButton(
                  text: 'PLAY GAME',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                  color: Colors.blue,
                ),
                
                SpaceButton(
                  text: 'HIGH SCORES',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HighScoresScreen(),
                      ),
                    );
                  },
                  color: Colors.purple,
                ),
                
                SpaceButton(
                  text: 'SETTINGS',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}