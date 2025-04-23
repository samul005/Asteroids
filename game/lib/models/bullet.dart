import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/game_constants.dart';

class Bullet {
  double x;
  double y;
  double vx;
  double vy;
  int lifespan;
  final double size = 3.0;
  final double speed = 8.0;
  final Color color;
  
  Bullet({
    required this.x,
    required this.y,
    required double angle,
    this.color = Colors.cyan,
    this.lifespan = GameConstants.bulletLifespanTicks,
  }) : 
    vx = sin(angle) * speed,
    vy = -cos(angle) * speed; // Negative because y-axis points down
  
  bool get isDead => lifespan <= 0;
  
  // Create a hitbox for collision detection
  Rect get hitbox {
    return Rect.fromCenter(
      center: Offset(x, y),
      width: size * 2,
      height: size * 2,
    );
  }
  
  void update() {
    // Update position
    x += vx;
    y += vy;
    
    // Handle screen wrapping
    if (x < 0) x += GameConstants.gameWidth;
    if (x > GameConstants.gameWidth) x -= GameConstants.gameWidth;
    if (y < 0) y += GameConstants.gameHeight;
    if (y > GameConstants.gameHeight) y -= GameConstants.gameHeight;
    
    // Decrease lifespan
    lifespan--;
  }
  
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(x, y),
      this.size,
      paint,
    );
    
    // Optional: add a glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3.0);
    
    canvas.drawCircle(
      Offset(x, y),
      this.size * 1.5,
      glowPaint,
    );
  }
}