import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../globals/globals.dart';

class KoopaAnimationConfigs {
  Future<SpriteAnimation> idle() async => SpriteAnimation.spriteList(
    [await Sprite.load(Globals.paths.images.koopaIdle)],
    stepTime: Globals.numbers.marioSpriteStepTime,
  );

  Future<SpriteAnimation> walking() async => SpriteAnimation.spriteList(
    await Future.wait(
        Globals.paths.images.koopaWalk.map((path) => Sprite.load(path)).toList()),
    stepTime: Globals.numbers.marioSpriteStepTime,
  );
}