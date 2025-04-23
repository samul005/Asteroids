import 'dart:math';
import 'package:flutter/material.dart';

enum ParticleType {
  explosion,
  thruster,
  sparkle
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  int lifespan;
  int maxLifespan;
  Color color;
  ParticleType type;
  
  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.lifespan,
    required this.color,
    required this.type,
  }) {
    maxLifespan = lifespan;
  }
  
  bool get isDead => lifespan <= 0;
  
  double get opacity => lifespan / maxLifespan;
  
  void update() {
    x += vx;
    y += vy;
    
    // Gradually reduce size based on lifespan
    size = size * (lifespan / maxLifespan);
    
    // Apply some drag/friction to slow particles
    vx *= 0.98;
    vy *= 0.98;
    
    // Decrease lifespan
    lifespan--;
  }
  
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(x, y),
      this.size,
      paint,
    );
    
    // For thruster particles, add a glowing effect
    if (type == ParticleType.thruster) {
      final glowPaint = Paint()
        ..color = color.withOpacity(opacity * 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, this.size);
      
      canvas.drawCircle(
        Offset(x, y),
        this.size * 1.5,
        glowPaint,
      );
    }
    
    // For explosion particles, add some variance
    if (type == ParticleType.explosion && opacity > 0.5) {
      final glowPaint = Paint()
        ..color = color.withOpacity(opacity * 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, this.size * 0.8);
      
      canvas.drawCircle(
        Offset(x, y),
        this.size * 2,
        glowPaint,
      );
    }
    
    // For sparkle particles, make them twinkle
    if (type == ParticleType.sparkle && lifespan % 3 == 0) {
      final sparklePaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y),
        this.size * 1.5,
        sparklePaint,
      );
    }
  }
  
  static List<Particle> createExplosion(double x, double y, Color color, {int count = 30}) {
    final particles = <Particle>[];
    final random = Random();
    
    for (int i = 0; i < count; i++) {
      // Create random direction
      final angle = random.nextDouble() * 2 * pi;
      final speed = 1 + random.nextDouble() * 3;
      
      particles.add(Particle(
        x: x,
        y: y,
        vx: sin(angle) * speed,
        vy: cos(angle) * speed,
        size: 1 + random.nextDouble() * 3,
        lifespan: 30 + random.nextInt(30),
        color: color,
        type: ParticleType.explosion,
      ));
    }
    
    return particles;
  }
  
  static List<Particle> createThruster(double x, double y, double angle) {
    final particles = <Particle>[];
    final random = Random();
    
    // Base direction is opposite of ship angle
    final baseAngle = angle + pi;
    
    // Create a few particles per thruster burst
    for (int i = 0; i < 5; i++) {
      // Slightly randomize direction
      final particleAngle = baseAngle + (random.nextDouble() - 0.5) * 0.5;
      final speed = 1 + random.nextDouble() * 2;
      
      // Randomize color between yellow and orange/red
      final colorValue = random.nextDouble();
      final color = Color.lerp(
        Colors.orange,
        Colors.yellow,
        colorValue,
      )!;
      
      particles.add(Particle(
        x: x,
        y: y,
        vx: sin(particleAngle) * speed,
        vy: cos(particleAngle) * speed,
        size: 1 + random.nextDouble() * 2,
        lifespan: 10 + random.nextInt(15),
        color: color,
        type: ParticleType.thruster,
      ));
    }
    
    return particles;
  }
}