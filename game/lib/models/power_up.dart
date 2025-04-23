import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/game_constants.dart';

enum PowerUpType {
  shield,
  rapidFire,
  extraLife
}

class PowerUp {
  double x;
  double y;
  double vx;
  double vy;
  final PowerUpType type;
  int lifespan = GameConstants.powerUpLifespanTicks;
  double angle = 0;
  double rotationSpeed = 0.02;
  final double size = 15.0;
  
  PowerUp({
    required this.x,
    required this.y,
    required this.type,
  }) {
    // Random slow movement
    final rand = Random();
    final speed = 0.5 + rand.nextDouble() * 0.5;
    final direction = rand.nextDouble() * 2 * pi;
    
    vx = sin(direction) * speed;
    vy = cos(direction) * speed;
  }
  
  // Factory constructor to create random power-up
  factory PowerUp.random() {
    final rand = Random();
    
    // Random position within the game area
    final x = rand.nextDouble() * GameConstants.gameWidth;
    final y = rand.nextDouble() * GameConstants.gameHeight;
    
    // Random power-up type
    final typeIndex = rand.nextInt(PowerUpType.values.length);
    final type = PowerUpType.values[typeIndex];
    
    return PowerUp(
      x: x,
      y: y,
      type: type,
    );
  }
  
  // Create a hitbox for collision detection
  Rect get hitbox {
    return Rect.fromCenter(
      center: Offset(x, y),
      width: size * 2,
      height: size * 2,
    );
  }
  
  bool get isDead => lifespan <= 0;
  
  void update() {
    // Update position
    x += vx;
    y += vy;
    
    // Rotate
    angle += rotationSpeed;
    
    // Handle screen wrapping
    if (x < 0) x += GameConstants.gameWidth;
    if (x > GameConstants.gameWidth) x -= GameConstants.gameWidth;
    if (y < 0) y += GameConstants.gameHeight;
    if (y > GameConstants.gameHeight) y -= GameConstants.gameHeight;
    
    // Decrease lifespan
    lifespan--;
  }
  
  void draw(Canvas canvas, Size size) {
    canvas.save();
    
    // Move to power-up position and rotate
    canvas.translate(x, y);
    canvas.rotate(angle);
    
    final outerPaint = Paint()
      ..color = _getOuterColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final innerPaint = Paint()
      ..color = _getInnerColor()
      ..style = PaintingStyle.fill;
    
    // Draw outer circle
    canvas.drawCircle(
      Offset.zero,
      this.size,
      outerPaint,
    );
    
    // Draw inner shape based on power-up type
    _drawInnerShape(canvas, innerPaint);
    
    // Add glow effect
    final glowPaint = Paint()
      ..color = _getOuterColor().withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);
    
    canvas.drawCircle(
      Offset.zero,
      this.size + 2,
      glowPaint,
    );
    
    canvas.restore();
  }
  
  void _drawInnerShape(Canvas canvas, Paint paint) {
    switch (type) {
      case PowerUpType.shield:
        // Shield icon
        canvas.drawCircle(
          Offset.zero,
          this.size * 0.6,
          paint,
        );
        break;
        
      case PowerUpType.rapidFire:
        // Rapid fire icon (lightning bolt)
        final path = Path();
        path.moveTo(0, -size * 0.7);  // Top
        path.lineTo(size * 0.4, 0);   // Middle right
        path.lineTo(0, size * 0.3);   // Middle center
        path.lineTo(-size * 0.4, size * 0.7);  // Bottom left
        path.lineTo(0, 0);           // Back to center
        path.close();
        canvas.drawPath(path, paint);
        break;
        
      case PowerUpType.extraLife:
        // Extra life icon (heart shape)
        final path = Path();
        path.moveTo(0, size * 0.5);  // Bottom point of heart
        
        // Left half of heart
        path.cubicTo(
          -size * 0.5, size * 0.1,
          -size * 0.5, -size * 0.5,
          0, -size * 0.3
        );
        
        // Right half of heart
        path.cubicTo(
          size * 0.5, -size * 0.5,
          size * 0.5, size * 0.1,
          0, size * 0.5
        );
        
        canvas.drawPath(path, paint);
        break;
    }
  }
  
  Color _getOuterColor() {
    switch (type) {
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.rapidFire:
        return Colors.orange;
      case PowerUpType.extraLife:
        return Colors.red;
    }
  }
  
  Color _getInnerColor() {
    return _getOuterColor().withOpacity(0.5);
  }
}