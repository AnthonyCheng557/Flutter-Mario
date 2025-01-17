import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:nextbigthing/mario_lite.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';

class TitlePage extends Component with HasGameRef<MarioLite>, TapCallbacks {
  late SpriteComponent background, quitButton;

  @override
  Future<void> onLoad() async {
    final titleScreen = await Flame.images.load('titlescreen.PNG');
    final quit = await Flame.images.load('quitbutton.png');

    background = SpriteComponent();
    background.sprite = Sprite(titleScreen);
    background.size = gameRef.size;

    quitButton = SpriteComponent();
    quitButton.sprite = Sprite(quit);
    quitButton.size = Vector2(50, 50);
    quitButton.position = Vector2(gameRef.size.x - 60, 10);

    addAll([background, quitButton]);
  }

// Add this when changing to another page.
  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapDown(TapDownEvent event) {
    if (quitButton.containsPoint(event.localPosition)) {
      FlutterExitApp.exitApp();
    }
    else {
      game.router.pushNamed('gameplay');
    }
  }
}
