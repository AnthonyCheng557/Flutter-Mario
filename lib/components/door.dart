import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:nextbigthing/components/mario.dart';
import '../constants/globals/globals.dart';

class Door extends PositionComponent with CollisionCallbacks {
  late Mario mario;

  Door ({
    required Vector2 position,
    required Vector2 size,
    required this.mario,
}) : super(
    position: position,
    size: Vector2.all(Globals.numbers.tileSize),
  ) {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Mario) {
      mario.hAxis_right = 0;
      mario.priority = 0;
      mario.atDoor = true;
    }
  }
}