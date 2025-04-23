import 'package:flutter/material.dart';

class GameHud extends StatelessWidget {
  final int score;
  final int lives;
  final int wave;

  const GameHud({
    Key? key,
    required this.score,
    required this.lives,
    required this.wave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Score display
            Text(
              'SCORE: ${score.toString().padLeft(6, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Orbitron',
                fontSize: 20,
              ),
            ),
            
            // Wave display
            Text(
              'WAVE: $wave',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Orbitron',
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Lives display
            Row(
              children: [
                const Text(
                  'LIVES: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Orbitron',
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: List.generate(
                    lives,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.rocket,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}