import 'package:flutter/material.dart';
import '../utils/audio_helper.dart';

class SpaceButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final double fontSize;
  final bool playSound;

  const SpaceButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.fontSize = 20.0,
    this.playSound = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioHelper = AudioHelper();

    void handlePress() {
      if (playSound) {
        audioHelper.playButtonSound();
      }
      onPressed();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        onPressed: handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}