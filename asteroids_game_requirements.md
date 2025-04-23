# Asteroids – Flutter Arcade Game

A classic 2D space shooter built with Flutter, optimized for mobile (iOS/Android). You control a triangular ship that navigates a wrap-around space field, shoots asteroids, and collects power-ups.

---

## Features

### Core Gameplay
- **Spaceship Controls**:
  - Left tap to fire (250ms cooldown, 83ms with Rapid Fire)
  - Right-side drag to rotate and thrust
- **Wraparound Movement**
- **Asteroid Waves**:
  - Random size & speed
  - Split on hit if size > 20px
  - Progressive difficulty
- **Bullets**:
  - 10px/frame speed
  - Auto-expire after 60 frames

### Power-Ups
- **Extra Life** (Red): +1 life (max 3)
- **Rapid Fire** (Yellow): Faster shooting for 6s
- **Shield** (Blue): No damage for 35s
- 30% drop rate on asteroid destruction
- Disappear if not collected in 5s
- Debug message + unique SFX (600Hz–1000Hz)

### Particles
- Asteroid explosion: 5 particles
- Ship thrust: 20% chance
- Fade-out with frame shrink

---

## UI Screens

- **Start Screen**: Title, Start & Settings buttons, animated stars
- **Settings Screen**: Adjust ship speed (1–10)
- **Game Screen**: In-game HUD, controls (Play, Pause, Exit), fullscreen toggle
- **Game Over Screen**: Final score, high score, retry option

---

## Controls

| Action            | Input                              |
|-------------------|-------------------------------------|
| Fire              | Tap left side                       |
| Rotate/Thrust     | Drag right side                     |
| Settings Adjust   | Tap left/right of center            |
| Game Buttons      | Start, Pause, Play, Exit, Retry     |

---

## Technical Details

- **Framework**: Flutter
- **Rendering**: Custom game loop + Canvas
- **Performance**:
  - Object pooling
  - Reverse-looped removals
  - Particle limit & framerate optimized (60 FPS)
- **Audio**: `audioplayers` for SFX
- **Storage**: `shared_preferences` for high score
- **Fonts**: Orbitron (titles/buttons), Arial (HUD/instructions)
- **Aspect Ratio**: Maintains 4:3, centers on screen

---


## Installation

```bash
git clone https://github.com/your-username/flutter-asteroids.git
cd flutter-asteroids
flutter pub get
flutter run
