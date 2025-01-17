import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:nextbigthing/components/mario.dart';
import '../constants/globals/globals.dart';

class Flag extends PositionComponent with CollisionCallbacks {
  bool hasFlipped = false;
  bool pointsDistributed = false;
  late Mario mario;
  late Timer timer;

    Flag ({
      required Vector2 position,
      required this.timer,
      required this.mario
    })
    : super(
        position: position,
        size: Vector2.all(Globals.numbers.tileSize),
      ) {
      add(RectangleHitbox()..collisionType = CollisionType.passive);
    }

  @override
  void update(double dt) {
    super.update(dt);

    position.y = mario.position.y;

    if (mario.isSliding) {
      mario.position.y += mario.velocity.y * dt;
    }
  }

  @override
  Future<void> onCollision(Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollision(intersectionPoints, other);

    if (other is Mario) {
      timer.pause();
      mario.isSliding = true;
      mario.inputDisabled = true;
      mario.velocity.x = 0;
      mario.velocity.y = 50;


      if (!pointsDistributed) {
        if (intersectionPoints.first.y >= 22 &&
            intersectionPoints.first.y <= 80) {
          mario.points += 5000;
        }
        else if (intersectionPoints.first.y >= 82 &&
            intersectionPoints.first.y <= 127) {
          mario.points += 2000;
        }
        else if (intersectionPoints.first.y >= 128 &&
            intersectionPoints.first.y <= 145) {
          mario.points += 800;
        }
        else if (intersectionPoints.first.y >= 146 &&
            intersectionPoints.first.y <= 170) {
          mario.points += 400;
        }
        else {
          mario.points += 100;
        }
        pointsDistributed = true;
      }

      if (intersectionPoints.first.y >= 180 && !hasFlipped) {
        mario.reset();
        await Future.delayed(const Duration(seconds: 3), () {
          if (!hasFlipped) {
            mario.position.x += position.x - mario.position.x + 5;
            mario.flipHorizontally();
            mario.hAxis_right = 1;
            mario.moveAcceleration = 500;
            hasFlipped = true;
          }
        });
      }
    }
  }
}