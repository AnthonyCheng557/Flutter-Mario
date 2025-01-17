import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:nextbigthing/components/game_block.dart';
import 'package:nextbigthing/constants/animations/animations_configs.dart';
import 'package:nextbigthing/constants/animations/block_animation_configs.dart';

class BrickBlock extends GameBlock {
  bool _isHit = false;

  BrickBlock({
    required Vector2 position,
    required bool shouldCrumble,
  }) : super(
    animation: null,
    position: position,
    shouldCrumble: shouldCrumble,
  );

  @override
  Future<void> onLoad() async {
    animation = await BlockConfigs.brickBlockIdle();
    return super.onLoad();
  }
  @override
  Future<void> hit() async {
    if (shouldCrumble && !_isHit) {
      _isHit = true;
      animation = await BlockConfigs.brickBlockHit();
      opacity = 0;
      await Future.delayed(const Duration(milliseconds: 200));
      removeFromParent();
    }
    super.hit();
  }
}