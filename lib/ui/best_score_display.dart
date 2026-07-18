import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

class BestScoreDisplay extends TextComponent {
  BestScoreDisplay()
      : super(
          text: 'BEST: 0',
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          anchor: Anchor.topLeft,
        );

  void setBest(int best) => text = 'BEST: $best';
}
