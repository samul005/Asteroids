import 'package:flutter/material.dart';
import '../widgets/space_button.dart';
import 'game_screen.dart';
import 'start_screen.dart';

class GameOverScreen extends StatelessWidget {
  final int score;
  final bool isHighScore;
  final int wave;

  const GameOverScreen({
    Key? key,
    required this.score,
    required this.isHighScore,
    required this.wave,
  }) : super(key: key);

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
              Colors.black.withOpacity(0.8),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              
              const SizedBox(height: 40),
              
              if (isHighScore)
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'NEW HIGH SCORE!',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(height: 10),
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 50,
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 30),
              
              Text(
                'FINAL SCORE: ${score.toString().padLeft(6, '0')}',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 15),
              
              Text(
                'WAVES SURVIVED: $wave',
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 50),
              
              SpaceButton(
                text: 'PLAY AGAIN',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameScreen(),
                    ),
                  );
                },
                color: Colors.blue,
              ),
              
              SpaceButton(
                text: 'MAIN MENU',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StartScreen(),
                    ),
                  );
                },
                color: Colors.purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}