import 'block_animation_configs.dart';
import 'koopa_animation_configs.dart';
import 'mario_animation_configs.dart';
import 'goomba_animation_configs.dart';

class AnimationConfigs {
  AnimationConfigs._();

  static MarioAnimationConfigs mario = MarioAnimationConfigs();
  static GoombaAnimationConfigs goomba = GoombaAnimationConfigs();
  static KoopaAnimationConfigs koopa = KoopaAnimationConfigs();
  static BlockConfigs block = BlockConfigs();
}
