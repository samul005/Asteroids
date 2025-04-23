import 'package:flutter/material.dart';

// Game states - moved out of class as enums can't be nested in Dart
enum GameState {
  playing,
  paused,
  gameOver,
}

class GameConstants {
  // Game settings
  static const int targetFPS = 60;
  static const int initialLives = 3;
  static const int maxLives = 5;
  
  // Scoring
  static const int largeAsteroidPoints = 20;
  static const int mediumAsteroidPoints = 50;
  static const int smallAsteroidPoints = 100;
  
  // Game difficulty
  static const int baseAsteroidsPerWave = 3;
  static const int additionalAsteroidsPerWave = 2;
  static const double asteroidSpeedMultiplierPerWave = 1.1;
  
  // Ship settings
  static const double shipSize = 30.0;
  static const double shipAcceleration = 0.2;
  static const double shipMaxSpeed = 5.0;
  static const double shipRotationSpeed = 0.1;
  static const double shipFriction = 0.98;
  static const int shipInvulnerabilityFrames = 120; // 2 seconds at 60 FPS
  
  // Bullet settings
  static const double bulletSpeed = 10.0;
  static const double bulletSize = 3.0;
  static const int bulletLifespan = 60; // 1 second at 60 FPS
  static const int bulletCooldown = 15; // 0.25 seconds at 60 FPS
  static const int rapidFireCooldown = 5; // 0.083 seconds at 60 FPS
  
  // Asteroid settings
  static const double largeAsteroidSize = 80.0;
  static const double mediumAsteroidSize = 40.0;
  static const double smallAsteroidSize = 20.0;
  static const double baseAsteroidSpeed = 1.0;
  static const double maxAsteroidSpeed = 3.0;
  
  // Power-up settings
  static const double powerUpSize = 25.0;
  static const double powerUpSpeed = 1.0;
  static const int powerUpLifespan = 600; // 10 seconds at 60 FPS
  static const int shieldDuration = 600; // 10 seconds at 60 FPS
  static const int rapidFireDuration = 300; // 5 seconds at 60 FPS
  static const double powerUpDropChance = 0.2; // 20% chance
  
  // Colors
  static const Color shipColor = Colors.white;
  static const Color bulletColor = Colors.red;
  static const Color asteroidColor = Colors.grey;
  static const Color shieldColor = Colors.blue;
  static const Color shieldPowerUpColor = Colors.blue;
  static const Color rapidFirePowerUpColor = Colors.orange;
  static const Color extraLifePowerUpColor = Colors.green;
}