import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import '../globals/globals.dart';

class BlockConfigs {
  static late SpriteSheet itemBlocksSpriteSheet;

  // Load sprite sheet
  static Future<void> load() async {
    final image = await Flame.images.load('blocks_spritesheet.png');

    itemBlocksSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 28,
      rows: 16,
    );
  }

  // Mystery block idle animation
  static Future<SpriteAnimation> mysteryBlockIdle() async {
    await load();
    return SpriteAnimation.variableSpriteList(
      List<Sprite>.generate(
        3,
            (index) => itemBlocksSpriteSheet.getSprite(8, 5 + index),
      ),
      stepTimes: List<double>.generate(3, (index) => 0.2),
    );
  }

  // Mystery block hit animation
  static Future<SpriteAnimation> mysteryBlockHit() async {
    await load();
    return SpriteAnimation.variableSpriteList(
      [
        itemBlocksSpriteSheet.getSprite(7, 8),
      ],
      stepTimes: [0.2],
    );
  }

  // Brick block idle animation
  static Future<SpriteAnimation> brickBlockIdle() async {
    await load();
    return SpriteAnimation.variableSpriteList(
      [
        itemBlocksSpriteSheet.getSprite(7, 17),
      ],
      stepTimes: [0.2],
    );
  }

  // Brick block hit animation
  static Future<SpriteAnimation> brickBlockHit() async {
    await load();
    return SpriteAnimation.variableSpriteList(
      [
        itemBlocksSpriteSheet.getSprite(7, 19),
      ],
      stepTimes: [double.infinity],
    );
  }
}