import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:nextbigthing/components/level.dart';
import 'package:nextbigthing/components/level_options.dart';
import 'package:nextbigthing/mario_lite.dart';
import 'package:nextbigthing/components/mario.dart';
import 'package:flame_audio/flame_audio.dart';

class GameplayPage extends FlameGame with HasGameRef<MarioLite>{
  Mario? mario;
  @override
  final world = World();
  LevelComponent? _currentLevel;
  final RouterComponent router;
  @override
  MarioLite gameRef;

  GameplayPage({required this.router, required this.gameRef});

  @override
  FutureOr<void> onLoad() async {
    add(world);
    await loadLevel(LevelOption.level1);
    await FlameAudio.audioCache.load('backgroundMusic.mp3');
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('backgroundMusic.mp3', volume: 1);

    return super.onLoad();
  }

  @override
  void onRemove() async{
    await FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
    super.onRemove();
  }


  @override
  void update(double dt) {
    super.update(dt);
    if (mario != null) {
      if (mario?.lives == -1) {
        //Can't use game.router because game is expected to be of type GameplayPage
        //instead of MarioLite since FlameGame is extended.
        router.pushNamed('gameover');
      }

      if (mario!.hasWon) {
        gameRef.reset(false);
      }
    }
  }

  Future<void> loadLevel(LevelOption options) async{
    _currentLevel?.removeFromParent();
    _currentLevel = LevelComponent(options);
    add(_currentLevel!);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;
}