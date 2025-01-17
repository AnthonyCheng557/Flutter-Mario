import 'dart:async' as async;
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import '../constants/globals/globals.dart';
import '../components/mario.dart';
class RedMushroom extends SpriteComponent with CollisionCallbacks {
  bool moved = false;

RedMushroom({required Vector2 position}):super(position: position, size: Vector2(Globals.numbers.tileSize, Globals.numbers.tileSize)) {
  debugMode = true;
  add(CircleHitbox());
}

  @override
  async.FutureOr<void> onLoad() async {
    
    sprite = await Sprite.load('magic_mushroom.png');
    print("loaded");
    debugMode = true;
    
    return super.onLoad();

  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is Mario && moved == false) {
      position.y+=1000;
      moved = true;
    }
  
    
  }

void reset() {
  if (moved == true) {
  position.y-=1000;
  moved = false;
  }
  
}
 
}