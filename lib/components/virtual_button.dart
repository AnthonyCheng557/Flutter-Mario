import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class VirtualButton extends PositionComponent with TapCallbacks {
  final Function() onPressed;
  final Function() onReleased;
  final Vector2 buttonSize;
  final String label;

  VirtualButton({
    required this.onPressed,
    required this.onReleased,
    required this.buttonSize,
    required this.label,
    required Vector2 position,
  }) : super(position: position, size: buttonSize) {
    debugMode = true;
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }

  @override
  void onTapUp(TapUpEvent event) {
    onReleased();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    onReleased();
  }

  @override
  Future<void> onLoad() async {
    final TextComponent text;
    text = TextComponent(
      text: label,
      textRenderer: TextPaint(style: const TextStyle(fontSize: 20, color: Colors.white)),
      position: Vector2(size.x / 4, size.y / 4),
      anchor: Anchor.topLeft,
    );
    add(text);
  }
}
