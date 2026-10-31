import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class FloatingTextComponent extends PositionComponent {
  final String text;
  final Color color;
  final double fontSize;
  double lifeTime = 0.0;
  static const double maxLife = 1.0;
  final double upwardSpeed;

  late final TextPainter _textPainter;

  FloatingTextComponent({
    required this.text,
    required Vector2 position,
    this.color = const Color(0xFFFFD700),
    this.fontSize = 14.0,
    this.upwardSpeed = 50.0,
  }) : super(position: position.clone(), priority: 100) {
    _textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
            Shadow(color: Colors.black, blurRadius: 2, offset: Offset(-1, -1)),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();
    size = Vector2(_textPainter.width, _textPainter.height);
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifeTime += dt;
    position.y -= upwardSpeed * dt;
    if (lifeTime >= maxLife) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = (1.0 - (lifeTime / maxLife)).clamp(0.0, 1.0);
    canvas.save();
    canvas.translate(0, 0);
    _textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color.withValues(alpha: opacity),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        shadows: [
          Shadow(
            color: Colors.black.withValues(alpha: opacity),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
    );
    _textPainter.layout();
    _textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }
}
