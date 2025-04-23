import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/game_constants.dart';

class Spaceship {
  // Position
  double x;
  double y;
  double angle = 0; // In radians, 0 means pointing up
  
  // Velocity
  double vx = 0;
  double vy = 0;
  
  // Properties
  final double size = 15.0;
  final double rotationSpeed = 0.1;
  final double acceleration = 0.2;
  final double drag = 0.98;
  double maxSpeed = 5.0;
  
  // Status
  bool isInvulnerable = false;
  bool hasShield = false;
  bool isThrusting = false;
  
  // Visual effects
  int invulnerabilityTicks = 0;
  bool isVisible = true; // For blinking effect during invulnerability
  int blinkCounter = 0;
  
  // Weapons
  int fireCooldown = 0;
  bool hasRapidFire = false;
  int rapidFireTicks = 0;
  
  // Constructor
  Spaceship({
    required this.x,
    required this.y,
  });
  
  // Create a hitbox for collision detection
  Rect get hitbox {
    // Smaller hitbox than the visual size for better gameplay feel
    return Rect.fromCenter(
      center: Offset(x, y),
      width: size * 1.5,
      height: size * 1.5,
    );
  }
  
  void update() {
    // Update position based on velocity
    x += vx;
    y += vy;
    
    // Apply drag to slow down over time
    vx *= drag;
    vy *= drag;
    
    // Screen wrapping
    if (x < 0) x += GameConstants.gameWidth;
    if (x > GameConstants.gameWidth) x -= GameConstants.gameWidth;
    if (y < 0) y += GameConstants.gameHeight;
    if (y > GameConstants.gameHeight) y -= GameConstants.gameHeight;
    
    // Update invulnerability
    if (isInvulnerable) {
      invulnerabilityTicks--;
      
      // Blinking effect
      if (++blinkCounter >= 3) {
        blinkCounter = 0;
        isVisible = !isVisible;
      }
      
      if (invulnerabilityTicks <= 0) {
        isInvulnerable = false;
        isVisible = true; // Ensure spaceship is visible when invulnerability ends
      }
    }
    
    // Update weapon cooldown
    if (fireCooldown > 0) {
      fireCooldown--;
    }
    
    // Update rapid fire power-up
    if (hasRapidFire) {
      if (--rapidFireTicks <= 0) {
        hasRapidFire = false;
      }
    }
  }
  
  void rotateLeft() {
    angle -= rotationSpeed;
    // Keep angle within [0, 2π]
    if (angle < 0) angle += 2 * pi;
  }
  
  void rotateRight() {
    angle += rotationSpeed;
    // Keep angle within [0, 2π]
    if (angle > 2 * pi) angle -= 2 * pi;
  }
  
  void thrust() {
    isThrusting = true;
    
    // Calculate acceleration vector based on ship's angle
    final accelX = sin(angle) * acceleration;
    final accelY = -cos(angle) * acceleration; // Negative because y-axis is inverted
    
    // Apply acceleration to velocity
    vx += accelX;
    vy += accelY;
    
    // Limit speed
    final speed = sqrt(vx * vx + vy * vy);
    if (speed > maxSpeed) {
      final ratio = maxSpeed / speed;
      vx *= ratio;
      vy *= ratio;
    }
  }
  
  void stopThrust() {
    isThrusting = false;
  }
  
  bool canFire() {
    return fireCooldown <= 0;
  }
  
  void resetFireCooldown() {
    fireCooldown = hasRapidFire ? 
        GameConstants.rapidFireCooldownTicks : 
        GameConstants.normalFireCooldownTicks;
  }
  
  void makeInvulnerable() {
    isInvulnerable = true;
    invulnerabilityTicks = GameConstants.invulnerabilityTicks;
    blinkCounter = 0;
  }
  
  void activateShield() {
    hasShield = true;
  }
  
  void activateRapidFire() {
    hasRapidFire = true;
    rapidFireTicks = GameConstants.powerUpDurationTicks;
  }
  
  void draw(Canvas canvas, Size size) {
    // Don't draw if not visible during invulnerability blink
    if (isInvulnerable && !isVisible) {
      return;
    }
    
    canvas.save();
    
    // Move to ship's position and rotate
    canvas.translate(x, y);
    canvas.rotate(angle);
    
    // Draw shield if active
    if (hasShield) {
      final shieldPaint = Paint()
        ..color = Colors.blue.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(
        Offset.zero,
        size * 1.5, // Shield is larger than the ship
        shieldPaint,
      );
    }
    
    // Draw ship body
    final shipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    // Triangle shape pointing up
    path.moveTo(0, -size); // Top vertex
    path.lineTo(size * 0.7, size * 0.7); // Bottom right
    path.lineTo(-size * 0.7, size * 0.7); // Bottom left
    path.close();
    
    canvas.drawPath(path, shipPaint);
    
    // Draw engine flame when thrusting
    if (isThrusting) {
      final flamePaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.fill;
      
      final flamePath = Path();
      
      // Flame shape at bottom of ship
      flamePath.moveTo(-size * 0.3, size * 0.5); // Left point
      flamePath.lineTo(0, size * 1.2); // Bottom point
      flamePath.lineTo(size * 0.3, size * 0.5); // Right point
      flamePath.close();
      
      canvas.drawPath(flamePath, flamePaint);
    }
    
    canvas.restore();
  }
}