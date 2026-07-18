import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class ScoreDisplay extends TextComponent {
  ScoreDisplay()
      : super(
          text: '0',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 44,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          anchor: Anchor.topCenter,
        );

  void setScore(int score) => text = '$score';
}
