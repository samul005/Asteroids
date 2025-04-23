import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/space_button.dart';

class HighScoresScreen extends StatefulWidget {
  const HighScoresScreen({Key? key}) : super(key: key);

  @override
  State<HighScoresScreen> createState() => _HighScoresScreenState();
}

class _HighScoresScreenState extends State<HighScoresScreen> {
  int highScore = 0;
  List<int> topScores = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  void _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
      
      // Load top 5 scores if they exist
      final List<String>? savedScores = prefs.getStringList('topScores');
      if (savedScores != null && savedScores.isNotEmpty) {
        topScores = savedScores.map((score) => int.parse(score)).toList();
      } else {
        // If no top scores yet, add the high score if it exists
        if (highScore > 0) {
          topScores = [highScore];
        }
      }
      
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HIGH SCORES',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.black,
      ),
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                
                // High Score display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'ALL TIME HIGH SCORE',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        highScore.toString().padLeft(6, '0'),
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 36,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Top scores list
                const Text(
                  'TOP SCORES',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
                
                Expanded(
                  child: isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : topScores.isEmpty 
                      ? const Center(
                          child: Text(
                            'No scores yet.\nPlay a game to set a score!',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: topScores.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: index == 0 
                                    ? Colors.amber 
                                    : Colors.white24,
                                  width: index == 0 ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getPlaceColor(index),
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontFamily: 'Orbitron',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    topScores[index].toString().padLeft(6, '0'),
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      fontSize: 24,
                                      color: index == 0 
                                        ? Colors.amber 
                                        : Colors.white,
                                      fontWeight: index == 0 
                                        ? FontWeight.bold 
                                        : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                const SizedBox(height: 20),
                
                // Back button
                SpaceButton(
                  text: 'BACK',
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getPlaceColor(int index) {
    switch (index) {
      case 0: return Colors.amber;
      case 1: return Colors.grey.shade300;
      case 2: return Colors.brown.shade300;
      default: return Colors.blue;
    }
  }
}