import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/asteroid.dart';
import '../models/bullet.dart';
import '../models/particle.dart';
import '../models/power_up.dart';
import '../models/spaceship.dart';
import 'audio_helper.dart';
import 'game_constants.dart';

class GameController {
  // Game dimensions and scaling
  double gameWidth = 0;
  double gameHeight = 0;
  double scaleFactor = 1.0;
  Offset gameOffset = Offset.zero;
  
  // Game state
  GameState gameState = GameState.playing;
  int score = 0;
  int lives = GameConstants.initialLives;
  int currentWave = 1;
  int highScore = 0;
  
  // Game objects
  late Spaceship spaceship;
  final List<Bullet> bullets = [];
  final List<Asteroid> asteroids = [];
  final List<Particle> particles = [];
  final List<PowerUp> powerUps = [];
  
  // Controls
  bool isLeftPressed = false;
  bool isRightPressed = false;
  bool isUpPressed = false;
  bool isFirePressed = false;
  
  // Utilities
  final Random random = Random();
  final AudioHelper audioHelper = AudioHelper();
  
  // Constructor
  GameController() {
    _initGame();
  }
  
  void _initGame() {
    // Reset game state
    gameState = GameState.playing;
    score = 0;
    lives = GameConstants.initialLives;
    currentWave = 1;
    
    // Clear all game objects
    bullets.clear();
    asteroids.clear();
    particles.clear();
    powerUps.clear();
    
    // Initialize the spaceship in the center of the screen
    spaceship = Spaceship(
      x: gameWidth / 2,
      y: gameHeight / 2,
    );
    
    // Make the spaceship temporarily invulnerable
    spaceship.makeInvulnerable();
    
    // Spawn the first wave of asteroids
    _spawnAsteroidWave();
  }
  
  void resetGame() {
    _initGame();
  }

  void update() {
    if (gameState != GameState.playing) return;
    
    // Update spaceship
    if (isLeftPressed) {
      spaceship.rotateLeft();
    }
    if (isRightPressed) {
      spaceship.rotateRight();
    }
    if (isUpPressed) {
      spaceship.thrust();
    } else {
      spaceship.stopThrust();
    }
    if (isFirePressed && spaceship.canFire()) {
      _fireBullet();
    }
    
    spaceship.update();
    
    // Update bullets
    for (int i = bullets.length - 1; i >= 0; i--) {
      bullets[i].update();
      if (bullets[i].isExpired() || bullets[i].isOffScreen(Size(gameWidth, gameHeight))) {
        bullets.removeAt(i);
      }
    }
    
    // Update asteroids
    for (var asteroid in asteroids) {
      asteroid.update();
    }
    
    // Update particles
    for (int i = particles.length - 1; i >= 0; i--) {
      particles[i].update();
      if (particles[i].isExpired()) {
        particles.removeAt(i);
      }
    }
    
    // Update power-ups
    for (int i = powerUps.length - 1; i >= 0; i--) {
      powerUps[i].update();
      if (powerUps[i].isExpired()) {
        powerUps.removeAt(i);
      }
    }
    
    // Check for collisions
    _checkCollisions();
    
    // Spawn thrust particles
    if (spaceship.isThrusting && random.nextDouble() < 0.3) { // 30% chance to spawn thrust particle
      _spawnThrustParticle();
    }
    
    // Check if wave is cleared
    if (asteroids.isEmpty) {
      currentWave++;
      _spawnAsteroidWave();
    }
  }

  void draw(Canvas canvas, Size size) {
    // Calculate game scaling and offset to fit the screen
    _calculateGameDimensions(size);
    
    canvas.save();
    canvas.translate(gameOffset.dx, gameOffset.dy);
    canvas.scale(scaleFactor);
    
    // Draw stars in background
    _drawStarBackground(canvas);
    
    // Draw bullets
    for (var bullet in bullets) {
      bullet.draw(canvas);
    }
    
    // Draw asteroids
    for (var asteroid in asteroids) {
      asteroid.draw(canvas);
    }
    
    // Draw power-ups
    for (var powerUp in powerUps) {
      powerUp.draw(canvas);
    }
    
    // Draw spaceship
    spaceship.draw(canvas, Size(gameWidth, gameHeight));
    
    // Draw particles
    for (var particle in particles) {
      particle.draw(canvas);
    }
    
    canvas.restore();
  }
  
  void _calculateGameDimensions(Size size) {
    // Define a reference game size (portrait mode)
    const referenceWidth = 400.0;
    const referenceHeight = 600.0;
    
    if (size.width / size.height > referenceWidth / referenceHeight) {
      // Too wide, limit by height
      gameHeight = referenceHeight;
      gameWidth = referenceHeight * (size.width / size.height);
      scaleFactor = size.height / referenceHeight;
    } else {
      // Too tall, limit by width
      gameWidth = referenceWidth;
      gameHeight = referenceWidth * (size.height / size.width);
      scaleFactor = size.width / referenceWidth;
    }
    
    // Center the game
    gameOffset = Offset(
      (size.width - gameWidth * scaleFactor) / 2,
      (size.height - gameHeight * scaleFactor) / 2,
    );
  }
  
  void _drawStarBackground(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    // Using a deterministic approach for stars so they don't flicker
    final starSeed = Random(42); // Fixed seed for consistent star positions
    for (int i = 0; i < 100; i++) { // 100 stars
      final x = starSeed.nextDouble() * gameWidth;
      final y = starSeed.nextDouble() * gameHeight;
      final size = 1 + starSeed.nextDouble() * 2; // Stars of different sizes
      canvas.drawCircle(Offset(x, y), size, paint);
    }
  }
  
  void _fireBullet() {
    bullets.add(
      Bullet(
        x: spaceship.x + sin(spaceship.angle) * spaceship.size,
        y: spaceship.y - cos(spaceship.angle) * spaceship.size,
        angle: spaceship.angle,
      ),
    );
    
    spaceship.resetFireCooldown();
    audioHelper.playFireSound();
  }
  
  void _spawnAsteroidWave() {
    int numAsteroids = GameConstants.baseAsteroidsPerWave + 
        (currentWave - 1) * GameConstants.additionalAsteroidsPerWave;
    
    // Cap the maximum number of asteroids to prevent overwhelming the player
    if (numAsteroids > 15) {
      numAsteroids = 15;
    }
    
    for (int i = 0; i < numAsteroids; i++) {
      _spawnAsteroid(AsteroidSize.large);
    }
  }
  
  void _spawnAsteroid(AsteroidSize size) {
    // Choose a random position that's not too close to the player
    double x, y;
    double minDistanceSquared = pow(gameWidth / 4, 2); // Keep asteroids at least 1/4 of the screen away from player
    
    do {
      // Generate position around the edges of the screen
      if (random.nextBool()) {
        // Spawn on left or right edge
        x = random.nextBool() ? -20 : gameWidth + 20;
        y = random.nextDouble() * gameHeight;
      } else {
        // Spawn on top or bottom edge
        x = random.nextDouble() * gameWidth;
        y = random.nextBool() ? -20 : gameHeight + 20;
      }
      
      // Check distance from spaceship
      double dx = x - spaceship.x;
      double dy = y - spaceship.y;
      double distanceSquared = dx * dx + dy * dy;
      
      if (distanceSquared >= minDistanceSquared) {
        break; // Position is far enough from spaceship
      }
    } while (true);
    
    // Calculate speed based on wave number (increasing difficulty)
    double speedMultiplier = 1.0 + (currentWave - 1) * 0.1;
    if (speedMultiplier > 2.0) speedMultiplier = 2.0; // Cap the speed multiplier
    
    double speed = GameConstants.baseAsteroidSpeed * speedMultiplier;
    
    // Create and add the asteroid
    asteroids.add(
      Asteroid(
        x: x,
        y: y,
        size: size,
        speed: speed + random.nextDouble() * speed * 0.5, // Add some random variation
        angle: atan2(spaceship.y - y, spaceship.x - x) + (random.nextDouble() - 0.5) * pi / 2,
      ),
    );
  }

  void _spawnThrustParticle() {
    // Create a particle behind the spaceship for thrust visual effect
    final thrustAngle = spaceship.angle + pi; // Opposite of ship direction
    final distance = spaceship.size * 0.7;
    
    particles.add(
      Particle(
        x: spaceship.x + sin(thrustAngle) * distance,
        y: spaceship.y - cos(thrustAngle) * distance,
        vx: sin(thrustAngle) * (0.5 + random.nextDouble()),
        vy: -cos(thrustAngle) * (0.5 + random.nextDouble()),
        size: 1 + random.nextDouble() * 2,
        color: random.nextBool() ? Colors.orange : Colors.red,
        lifespan: 10 + random.nextInt(20),
      ),
    );
  }
  
  void _spawnExplosionParticles(double x, double y, Color color, {int count = 15, double speed = 3.0}) {
    for (int i = 0; i < count; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final velocity = 0.5 + random.nextDouble() * speed;
      
      particles.add(
        Particle(
          x: x,
          y: y,
          vx: sin(angle) * velocity,
          vy: cos(angle) * velocity,
          size: 1 + random.nextDouble() * 3,
          color: color,
          lifespan: 20 + random.nextInt(40),
        ),
      );
    }
  }
  
  void _spawnPowerUp(double x, double y) {
    if (random.nextDouble() < GameConstants.powerUpDropChance) {
      // Determine which power-up to spawn based on the player's current state
      List<PowerUpType> availablePowerUps = [];
      
      // Always consider rapid fire
      availablePowerUps.add(PowerUpType.rapidFire);
      
      // Add shield if player doesn't have one
      if (!spaceship.hasShield) {
        availablePowerUps.add(PowerUpType.shield);
      }
      
      // Add extra life if player isn't at max lives
      if (lives < GameConstants.maxLives) {
        availablePowerUps.add(PowerUpType.extraLife);
      }
      
      // If there are possible power-ups, spawn one
      if (availablePowerUps.isNotEmpty) {
        PowerUpType type = availablePowerUps[random.nextInt(availablePowerUps.length)];
        
        powerUps.add(
          PowerUp(
            x: x,
            y: y,
            type: type,
          ),
        );
      }
    }
  }
  
  void _checkCollisions() {
    // Check bullet-asteroid collisions
    for (int i = bullets.length - 1; i >= 0; i--) {
      for (int j = asteroids.length - 1; j >= 0; j--) {
        if (asteroids[j].isCollidingWith(bullets[i].hitbox)) {
          // Increase score based on asteroid size
          score += asteroids[j].pointValue;
          
          // Create explosion particles
          _spawnExplosionParticles(
            asteroids[j].x,
            asteroids[j].y,
            GameConstants.asteroidColor,
          );
          
          // Play explosion sound
          audioHelper.playExplosionSound();
          
          // Check if we should spawn a power-up
          _spawnPowerUp(asteroids[j].x, asteroids[j].y);
          
          // Split asteroid if it's not the smallest size
          List<Asteroid> newAsteroids = asteroids[j].split();
          asteroids.addAll(newAsteroids);
          
          // Remove the hit asteroid
          asteroids.removeAt(j);
          
          // Remove the bullet
          bullets.removeAt(i);
          break;
        }
      }
    }
    
    // Check spaceship-asteroid collisions
    if (!spaceship.isInvulnerable) {
      for (var asteroid in asteroids) {
        if (asteroid.isCollidingWith(spaceship.hitbox)) {
          // If the spaceship has a shield, just remove the shield
          if (spaceship.hasShield) {
            spaceship.hasShield = false;
            spaceship.makeInvulnerable(); // Brief invulnerability after shield is destroyed
            return;
          }
          
          // Decrease a life
          lives--;
          
          // Create explosion particles where the ship was
          _spawnExplosionParticles(
            spaceship.x,
            spaceship.y,
            Colors.white,
            count: 30,
            speed: 5.0,
          );
          
          // Play explosion sound
          audioHelper.playExplosionSound();
          
          if (lives <= 0) {
            // Game over
            gameState = GameState.gameOver;
            audioHelper.playGameOverSound();
          } else {
            // Reset the ship position and make it invulnerable temporarily
            spaceship.x = gameWidth / 2;
            spaceship.y = gameHeight / 2;
            spaceship.vx = 0;
            spaceship.vy = 0;
            spaceship.makeInvulnerable();
          }
          
          break;
        }
      }
    }
    
    // Check spaceship-powerup collisions
    for (int i = powerUps.length - 1; i >= 0; i--) {
      if (powerUps[i].isCollidingWith(spaceship.hitbox)) {
        // Apply power-up effect
        switch (powerUps[i].type) {
          case PowerUpType.shield:
            spaceship.activateShield();
            break;
          case PowerUpType.rapidFire:
            spaceship.activateRapidFire();
            break;
          case PowerUpType.extraLife:
            if (lives < GameConstants.maxLives) {
              lives++;
            }
            break;
        }
        
        // Play power-up sound
        audioHelper.playPowerUpSound();
        
        // Remove the power-up
        powerUps.removeAt(i);
      }
    }
  }
  
  void pause() {
    if (gameState == GameState.playing) {
      gameState = GameState.paused;
    }
  }
  
  void resume() {
    if (gameState == GameState.paused) {
      gameState = GameState.playing;
    }
  }
  
  void dispose() {
    audioHelper.dispose();
  }
}