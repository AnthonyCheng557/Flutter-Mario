import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:nextbigthing/components/goomba.dart';
import 'package:nextbigthing/components/platform.dart';
import '../constants/animations/animations_configs.dart';
import '../constants/globals/globals.dart';
import 'mario.dart';


enum Direction {left, right, none}

enum KoopaAnimationStates {
  idle,
  walking,
}

class Koopa extends SpriteAnimationGroupComponent<KoopaAnimationStates> with CollisionCallbacks {
  late Mario mario;
  final double moveSpeed = 10;
  final double maxMoveSpeed = 50;
  Vector2 velocity = Vector2.zero();
  final double _gravity = 2.5;
  Direction direction = Direction.none;
  bool isShell = false, hasBeenHit = false, isOnPlatform = false;


  Koopa({
    required Vector2 position,
    required this.mario,
}) : super (
    position: position,
    size: Vector2(Globals.numbers.tileSize, Globals.numbers.tileSize),
    anchor: Anchor.topCenter,
  ){
    add(RectangleHitbox()..collisionType = CollisionType.active);
    debugMode = true;
  }
  @override
  Future<dynamic> onLoad() async {
    final SpriteAnimation idle = await AnimationConfigs.koopa.idle();
    final SpriteAnimation walking = await AnimationConfigs.koopa.walking();

    animations = {
      KoopaAnimationStates.idle: idle,
      KoopaAnimationStates.walking: walking,
    };

    current = KoopaAnimationStates.walking;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    isOnPlatform = false;
    updateMovement(dt);

    if (!isOnPlatform) {
      velocity.y += _gravity;
      velocity.y = velocity.y.clamp(-10, 10);
      position.y += velocity.y * dt;
    }
    else {
      velocity.y = 0;
    }
  }

  void updateMovement(double dt) {
    double speed = isShell ? maxMoveSpeed : moveSpeed;

    if (direction == Direction.left) {
      velocity.x -= speed;
    }
    else if (direction == Direction.right) {
      velocity.x += speed;
    }
    else {
      velocity.x = 0;
    }

    position += velocity * dt;
    velocity.x = velocity.x.clamp(-speed, speed);
  }

  void reset() {
    direction = Direction.none;
    current = KoopaAnimationStates.walking;
    isShell = false;
    hasBeenHit = false;
  }

  void moveOutFromPlatform(Set<Vector2> intersectionPoints) {
    final Vector2 mid = Vector2.zero();
    for (final point in intersectionPoints) {
      mid.add(point);
    }
    mid.scale(1/intersectionPoints.length);


    final Vector2 collisionNormal = absoluteCenter - mid;
    double penetrationDepth = (size.x / 2) - collisionNormal.length;
    collisionNormal.normalize();

    position += collisionNormal.scaled(penetrationDepth);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Platform) {
      isOnPlatform = true;
      if (intersectionPoints.length != 2) {
        if (direction == Direction.left) {
          direction = Direction.right;
        }
        else {
          direction = Direction.left;
        }
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Platform) {
      isOnPlatform = true;
      if (intersectionPoints.length == 2) {
        moveOutFromPlatform(intersectionPoints);
      }
    }

    if (other is Goomba && isShell) {
      other.goombaSmashed();
      mario.points += 100;
    }
  }
}