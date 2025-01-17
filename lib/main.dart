import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:nextbigthing/mario_lite.dart';
import 'package:nextbigthing/components/mario.dart' as mario;
import 'package:shake_gesture/shake_gesture.dart';




void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  MarioLite game = MarioLite();
  runApp(
    ShakeGesture(
        child: GameWidget(game: game),
        onShake: ()=> mario.shaked = true),
    );
}
