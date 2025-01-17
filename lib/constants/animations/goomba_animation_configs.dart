import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import '../globals/globals.dart';

class GoombaAnimationConfigs {
  static late SpriteSheet goombaSpriteSheet;

  //load spritesheet
  static Future<void> load() async {
    final goombaSpriteSheetImage = await Flame.images.load(
      Globals.paths.images.goombaWalk,
    );
    goombaSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: goombaSpriteSheetImage,
      columns: 3,
      rows: 1,
    );
  }
  //walking animation
  static Future<SpriteAnimation> idleWalk() async {
    await load();

    return SpriteAnimation.variableSpriteList(
      List<Sprite>.generate(
        2,
            (index) => goombaSpriteSheet.getSprite(0, index),
      ),
      stepTimes: List<double>.generate(2, (index) => 0.5),
    );
  }
}
