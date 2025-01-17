import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import '../constants/animations/goomba_animation_configs.dart';
import '../constants/globals/globals.dart';
//import 'package:nextbigthing/constants/animations/goomba_animation_configs.dart';

class Goomba extends SpriteAnimationComponent with CollisionCallbacks {
  final double _speed = 50;

  Goomba({required Vector2 position})
      : super(
    position: position,
    size: Vector2(Globals.numbers.tileSize, Globals.numbers.tileSize),
    anchor: Anchor.topCenter,
  );

  @override
  Future<void> onLoad() async {
    await GoombaAnimationConfigs.load();

    animation = await GoombaAnimationConfigs.idleWalk();

    Vector2 targetPosition = position.clone();
    targetPosition.x -= 100;

    final SequenceEffect effect = SequenceEffect(
      [
        MoveToEffect(targetPosition, EffectController(speed: _speed)),
        MoveToEffect(position, EffectController(speed: _speed)),
      ],
      alternate: true,
      infinite: true,
    );

    add(effect);
    add(RectangleHitbox()..collisionType = CollisionType.active);
  }

  void goombaSmashed(){
      removeFromParent();
  }

}
