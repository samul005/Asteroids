import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/game_constants.dart';

enum AsteroidSize {
  large,
  medium,
  small
}

class Asteroid {
  double x;
  double y;
  double vx;
  double vy;
  double angle = 0;
  double rotationSpeed;
  final AsteroidSize size;
  final List<Offset> vertices = [];
  
  // Constructor
  Asteroid({
    required this.x,
    required this.y,
    required this.size,
    double? speed,
    double? direction,
  }) {
    // Generate random direction if not provided
    direction ??= Random().nextDouble() * 2 * pi;
    
    // Set speed based on size if not provided
    speed ??= _getDefaultSpeed();
    
    // Set velocity components
    vx = sin(direction) * speed;
    vy = cos(direction) * speed;
    
    // Set rotation speed (smaller asteroids rotate faster)
    rotationSpeed = (Random().nextDouble() * 0.03) + 
                   (size == AsteroidSize.small ? 0.02 : 0.01);
    
    // Generate random vertices for the asteroid shape
    _generateVertices();
  }
  
  // Create random asteroid at screen edge
  factory Asteroid.random(AsteroidSize size) {
    final rand = Random();
    
    // Determine which edge to spawn from (0: top, 1: right, 2: bottom, 3: left)
    final edge = rand.nextInt(4);
    
    double x, y;
    
    switch (edge) {
      case 0: // Top
        x = rand.nextDouble() * GameConstants.gameWidth;
        y = 0;
        break;
      case 1: // Right
        x = GameConstants.gameWidth;
        y = rand.nextDouble() * GameConstants.gameHeight;
        break;
      case 2: // Bottom
        x = rand.nextDouble() * GameConstants.gameWidth;
        y = GameConstants.gameHeight;
        break;
      case 3: // Left
        x = 0;
        y = rand.nextDouble() * GameConstants.gameHeight;
        break;
      default:
        x = 0;
        y = 0;
    }
    
    // Create asteroid with random direction toward center of screen
    final centerX = GameConstants.gameWidth / 2;
    final centerY = GameConstants.gameHeight / 2;
    
    // Calculate direction toward center with some randomness
    final direction = atan2(centerY - y, centerX - x) + 
                     (rand.nextDouble() - 0.5) * 1.0;
    
    return Asteroid(
      x: x,
      y: y,
      size: size,
      direction: direction,
    );
  }
  
  // Create asteroid split from a larger one
  factory Asteroid.split(Asteroid parent) {
    final rand = Random();
    final newSize = parent.size == AsteroidSize.large 
        ? AsteroidSize.medium 
        : AsteroidSize.small;
    
    // Slightly vary the trajectory from the parent
    final angleVariation = (rand.nextDouble() - 0.5) * 1.5;
    final direction = atan2(parent.vy, parent.vx) + angleVariation;
    
    // Increase speed as asteroids get smaller
    final speed = _getStaticDefaultSpeed(newSize) * 1.2;
    
    return Asteroid(
      x: parent.x,
      y: parent.y,
      size: newSize,
      speed: speed,
      direction: direction,
    );
  }
  
  // Helper function to get default speeds without an instance
  static double _getStaticDefaultSpeed(AsteroidSize size) {
    switch (size) {
      case AsteroidSize.large:
        return 1.0;
      case AsteroidSize.medium:
        return 1.5;
      case AsteroidSize.small:
        return 2.0;
    }
  }
  
  double _getDefaultSpeed() {
    return _getStaticDefaultSpeed(size);
  }
  
  double getRadius() {
    switch (size) {
      case AsteroidSize.large:
        return 40.0;
      case AsteroidSize.medium:
        return 25.0;
      case AsteroidSize.small:
        return 15.0;
    }
  }
  
  int getPoints() {
    switch (size) {
      case AsteroidSize.large:
        return 20;
      case AsteroidSize.medium:
        return 50;
      case AsteroidSize.small:
        return 100;
    }
  }
  
  void _generateVertices() {
    final radius = getRadius();
    final jaggedness = 0.4; // How jagged the asteroid looks
    final numVertices = size == AsteroidSize.small ? 8 : 12;
    
    final rand = Random();
    
    for (int i = 0; i < numVertices; i++) {
      final angle = (i / numVertices) * 2 * pi;
      
      // Vary the radius to create a jagged shape
      final radiusVariation = radius * (1 + (rand.nextDouble() - 0.5) * jaggedness);
      
      final x = cos(angle) * radiusVariation;
      final y = sin(angle) * radiusVariation;
      
      vertices.add(Offset(x, y));
    }
  }
  
  // Create a hitbox for collision detection
  Rect get hitbox {
    final radius = getRadius() * 0.9; // Slightly smaller for better gameplay feel
    return Rect.fromCenter(
      center: Offset(x, y),
      width: radius * 2,
      height: radius * 2,
    );
  }
  
  void update() {
    // Update position
    x += vx;
    y += vy;
    
    // Update rotation
    angle += rotationSpeed;
    
    // Handle screen wrapping
    if (x < -getRadius()) x = GameConstants.gameWidth + getRadius();
    if (x > GameConstants.gameWidth + getRadius()) x = -getRadius();
    if (y < -getRadius()) y = GameConstants.gameHeight + getRadius();
    if (y > GameConstants.gameHeight + getRadius()) y = -getRadius();
  }
  
  void draw(Canvas canvas, Size canvasSize) {
    canvas.save();
    
    // Move to asteroid's position and apply rotation
    canvas.translate(x, y);
    canvas.rotate(angle);
    
    final paint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;
    
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Draw the asteroid shape using the vertices
    final path = Path();
    
    if (vertices.isNotEmpty) {
      path.moveTo(vertices[0].dx, vertices[0].dy);
      
      for (int i = 1; i < vertices.length; i++) {
        path.lineTo(vertices[i].dx, vertices[i].dy);
      }
      
      path.close();
    }
    
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
    
    canvas.restore();
  }
}