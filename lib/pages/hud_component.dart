import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:nextbigthing/components/mario.dart';
import 'package:nextbigthing/components/virtual_button.dart';
import 'package:nextbigthing/mario_lite.dart';

class HUDComponent extends Component with HasGameRef<MarioLite> {
  final Mario mario;

  HUDComponent(this.mario);

  @override
  Future<void> onLoad() async {
    addAll([
      VirtualButton(
        onPressed: () => mario.onLeftKeyPressed(),
        onReleased: () => mario.onLeftKeyReleased(),
        buttonSize: Vector2(60, 60),
        label: '←',
        position: Vector2(20, gameRef.size.y - 80),
      ),
      VirtualButton(
        onPressed: () => mario.onRightKeyPressed(),
        onReleased: () => mario.onRightKeyReleased(),
        buttonSize: Vector2(60, 60),
        label: '→',
        position: Vector2(100, gameRef.size.y - 80),
      ),
      VirtualButton(
        onPressed: () => mario.onJumpKeyPressed(),
        onReleased: () => mario.onJumpKeyReleased(),
        buttonSize: Vector2(60, 60),
        label: '↑',
        position: Vector2(gameRef.size.x - 80, gameRef.size.y - 80),
      ),
    ]);
  }
}