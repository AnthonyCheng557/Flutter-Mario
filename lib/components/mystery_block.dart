import 'dart:async';

import 'package:flame/components.dart';
import 'package:nextbigthing/components/game_block.dart';
import 'package:nextbigthing/components/red_mushroom.dart';
import 'package:nextbigthing/constants/animations/animations_configs.dart';
import 'package:nextbigthing/constants/animations/block_animation_configs.dart';
import 'package:nextbigthing/pages/gameplay_page.dart';

class MysteryBlock extends GameBlock with HasGameRef<GameplayPage> {
  bool _hit = false;
  MysteryBlock({required Vector2 position})
  : super(
    animation:null,
    position: position,
    shouldCrumble: false,
  );

  @override
  FutureOr<void> onLoad() async {
    animation = await BlockConfigs.mysteryBlockIdle();
    return super.onLoad();
  }
  @override
  Future<void> hit() async {
    if(!_hit) {
      _hit = true;
      animation = await BlockConfigs.mysteryBlockHit();
    }

    super.hit();
  }
}