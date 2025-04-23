import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/game_constants.dart';
import '../utils/game_controller.dart';
import '../widgets/game_hud.dart';
import '../widgets/space_button.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late GameController _gameController;
  Timer? _gameLoop;
  bool _isPaused = false;
  Size _screenSize = Size.zero;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _gameController = GameController();
    _startGameLoop();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseGame();
    }
  }
  
  @override
  void dispose() {
    _stopGameLoop();
    _gameController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  void _startGameLoop() {
    _gameLoop = Timer.periodic(
      Duration(milliseconds: 1000 ~/ GameConstants.targetFPS), 
      (_) => _update(),
    );
  }
  
  void _stopGameLoop() {
    _gameLoop?.cancel();
    _gameLoop = null;
  }
  
  void _update() {
    if (_isPaused) return;
    
    _gameController.update();
    
    if (_gameController.gameState == GameState.gameOver) {
      _stopGameLoop();
      _handleGameOver();
    }
    
    setState(() {});
  }
  
  void _pauseGame() {
    if (_isPaused) return;
    setState(() {
      _isPaused = true;
      _gameController.pause();
    });
  }
  
  void _resumeGame() {
    if (!_isPaused) return;
    setState(() {
      _isPaused = false;
      _gameController.resume();
    });
  }
  
  void _handleGameOver() async {
    final prefs = await SharedPreferences.getInstance();
    int highScore = prefs.getInt('highScore') ?? 0;
    
    if (_gameController.score > highScore) {
      // New high score!
      await prefs.setInt('highScore', _gameController.score);
    }
    
    // Navigate to game over screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameOverScreen(
            score: _gameController.score,
            isHighScore: _gameController.score > highScore,
            wave: _gameController.currentWave,
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Game canvas
            GestureDetector(
              onPanUpdate: (details) {
                // Bottom third of screen controls ship rotation
                final viewHeight = MediaQuery.of(context).size.height;
                final touchY = details.localPosition.y;
                
                if (touchY > viewHeight * 0.7) {
                  _gameController.isLeftPressed = details.delta.dx < -1;
                  _gameController.isRightPressed = details.delta.dx > 1;
                }
              },
              child: CustomPaint(
                painter: GamePainter(_gameController),
                size: Size.infinite,
              ),
            ),
            
            // Game HUD
            GameHud(
              score: _gameController.score,
              lives: _gameController.lives,
              wave: _gameController.currentWave,
            ),
            
            // Control buttons (transparent overlays)
            Positioned(
              left: 20,
              bottom: 20,
              child: Row(
                children: [
                  _buildControlButton(
                    icon: Icons.arrow_back,
                    onPressed: () => _gameController.isLeftPressed = true,
                    onReleased: () => _gameController.isLeftPressed = false,
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.arrow_forward,
                    onPressed: () => _gameController.isRightPressed = true,
                    onReleased: () => _gameController.isRightPressed = false,
                  ),
                ],
              ),
            ),
            
            Positioned(
              right: 20,
              bottom: 20,
              child: Row(
                children: [
                  _buildControlButton(
                    icon: Icons.arrow_upward,
                    onPressed: () => _gameController.isUpPressed = true,
                    onReleased: () => _gameController.isUpPressed = false,
                  ),
                  const SizedBox(width: 20),
                  _buildControlButton(
                    icon: Icons.adjust,
                    onPressed: () => _gameController.isFirePressed = true,
                    onReleased: () => _gameController.isFirePressed = false,
                  ),
                ],
              ),
            ),
            
            // Pause button
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                color: Colors.white,
                iconSize: 30,
                onPressed: () {
                  if (_isPaused) {
                    _resumeGame();
                  } else {
                    _pauseGame();
                  }
                },
              ),
            ),
            
            // Pause menu overlay
            if (_isPaused)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'PAUSED',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SpaceButton(
                          text: 'RESUME',
                          onPressed: _resumeGame,
                        ),
                        SpaceButton(
                          text: 'QUIT',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required VoidCallback onReleased,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased(),
      onTapCancel: onReleased,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  final GameController gameController;
  
  GamePainter(this.gameController);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Let the game controller handle drawing all game objects
    gameController.draw(canvas, size);
  }
  
  @override
  bool shouldRepaint(GamePainter oldDelegate) => true;
}