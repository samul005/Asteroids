import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/audio_helper.dart';
import '../widgets/space_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;
  double difficulty = 1.0; // 1.0 = normal, 0.7 = easy, 1.3 = hard
  
  final AudioHelper audioHelper = AudioHelper();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      musicEnabled = prefs.getBool('musicEnabled') ?? true;
      vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
      difficulty = prefs.getDouble('difficulty') ?? 1.0;
    });
  }
  
  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setBool('musicEnabled', musicEnabled);
    await prefs.setBool('vibrationEnabled', vibrationEnabled);
    await prefs.setDouble('difficulty', difficulty);
    
    // Update audio helper with new settings
    audioHelper.setSoundEnabled(soundEnabled);
    audioHelper.setMusicEnabled(musicEnabled);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved!'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  String _getDifficultyLabel() {
    if (difficulty <= 0.7) return 'Easy';
    if (difficulty >= 1.3) return 'Hard';
    return 'Normal';
  }
  
  Color _getDifficultyColor() {
    if (difficulty <= 0.7) return Colors.green;
    if (difficulty >= 1.3) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SETTINGS',
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
                const Text(
                  'Game Options',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 30),
                
                // Sound toggle
                _buildToggleSetting(
                  'Sound Effects',
                  soundEnabled,
                  (value) {
                    setState(() {
                      soundEnabled = value;
                    });
                    // Play test sound when enabled
                    if (soundEnabled) {
                      audioHelper.playButtonSound();
                    }
                  },
                  Icons.volume_up,
                ),
                
                const SizedBox(height: 15),
                
                // Music toggle
                _buildToggleSetting(
                  'Background Music',
                  musicEnabled,
                  (value) {
                    setState(() {
                      musicEnabled = value;
                    });
                  },
                  Icons.music_note,
                ),
                
                const SizedBox(height: 15),
                
                // Vibration toggle
                _buildToggleSetting(
                  'Vibration',
                  vibrationEnabled,
                  (value) {
                    setState(() {
                      vibrationEnabled = value;
                    });
                  },
                  Icons.vibration,
                ),
                
                const SizedBox(height: 30),
                
                // Difficulty slider
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.speed,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Difficulty',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              _getDifficultyLabel(),
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: difficulty,
                        min: 0.7,
                        max: 1.3,
                        divisions: 2,
                        activeColor: _getDifficultyColor(),
                        inactiveColor: Colors.grey,
                        onChanged: (value) {
                          setState(() {
                            difficulty = value;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Easy',
                            style: TextStyle(
                              color: Colors.green,
                              fontFamily: 'Orbitron',
                            ),
                          ),
                          Text(
                            'Normal',
                            style: TextStyle(
                              color: Colors.blue,
                              fontFamily: 'Orbitron',
                            ),
                          ),
                          Text(
                            'Hard',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: 'Orbitron',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Save button
                SpaceButton(
                  text: 'SAVE SETTINGS',
                  onPressed: _saveSettings,
                  color: Colors.green,
                ),
                
                const SizedBox(height: 10),
                
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
  
  Widget _buildToggleSetting(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
}