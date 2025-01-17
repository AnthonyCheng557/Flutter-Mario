import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import '../globals/globals.dart';

class MarioAnimationConfigs {
  Future<SpriteAnimation> idle() async => SpriteAnimation.spriteList(
    [await Sprite.load(Globals.paths.images.marioIdle)],
    stepTime: Globals.numbers.marioSpriteStepTime,
  );

  Future<SpriteAnimation> walking() async => SpriteAnimation.spriteList(
    await Future.wait(
      Globals.paths.images.marioWalk.map((path) => Sprite.load(path)).toList()),
      stepTime: Globals.numbers.marioSpriteStepTime,
  );

  Future<SpriteAnimation> jumping() async => SpriteAnimation.spriteList(
    [await Sprite.load(Globals.paths.images.marioJump)],
    stepTime: Globals.numbers.marioSpriteStepTime,
  );

  Future<SpriteAnimation> sliding() async => SpriteAnimation.spriteList(
    await Future.wait(
        Globals.paths.images.marioSlide.map((path) => Sprite.load(path)).toList()),
    stepTime: Globals.numbers.marioSpriteStepTime,
  );

  Future<SpriteAnimation> invincibleWalking() async => SpriteAnimation.spriteList(
    await Future.wait(
      Globals.paths.images.marioInvincibleWalk.map((path) => Sprite.load(path)).toList()),
    stepTime: Globals.numbers.marioSpriteStepTime,
  );

  Future<SpriteAnimation> invincibleIdle() async => SpriteAnimation.spriteList(
    await Future.wait(
      Globals.paths.images.marioInvincibleIdle.map((path) => Sprite.load(path)).toList()),
    stepTime: Globals.numbers.marioSpriteStepTime,
  );

  Future<SpriteAnimation> invincibleJumping() async => SpriteAnimation.spriteList(
    await Future.wait(
      Globals.paths.images.marioInvincibleJump.map((path) => Sprite.load(path)).toList()),
    stepTime: Globals.numbers.marioSpriteStepTime,
  );
}