import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  static final AudioHelper _instance = AudioHelper._internal();
  
  factory AudioHelper() {
    return _instance;
  }
  
  AudioHelper._internal();
  
  final AudioPlayer _player = AudioPlayer();
  bool isSoundEnabled = true;
  
  Future<void> playLaserSound() async {
    if (!isSoundEnabled) return;
    await _player.play(AssetSource('audio/laser.mp3'));
  }
  
  // Alias for playLaserSound to maintain compatibility with game_controller calls
  Future<void> playFireSound() async {
    await playLaserSound();
  }
  
  Future<void> playExplosionSound() async {
    if (!isSoundEnabled) return;
    await _player.play(AssetSource('audio/explosion.mp3'));
  }
  
  Future<void> playPowerUpSound() async {
    if (!isSoundEnabled) return;
    await _player.play(AssetSource('audio/powerup.mp3'));
  }
  
  Future<void> playGameOverSound() async {
    if (!isSoundEnabled) return;
    await _player.play(AssetSource('audio/gameover.mp3'));
  }
  
  Future<void> playButtonSound() async {
    if (!isSoundEnabled) return;
    await _player.play(AssetSource('audio/button.mp3'));
  }
  
  void dispose() {
    _player.dispose();
  }
}