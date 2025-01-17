import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:nextbigthing/mario_lite.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';


class GameoverPage extends Component with HasGameRef<MarioLite>, TapCallbacks{
  late SpriteComponent background, quitButton, playAgainButton;


  @override
  Future<void> onLoad() async{
    final gameOverScreen= await Flame.images.load('gameoverscreen.png');
    final playAgain = await Flame.images.load('playagain.png');
    final quit = await Flame.images.load('gameoverquit.png');

    background = SpriteComponent();
    background.sprite = Sprite(gameOverScreen);
    background.size = gameRef.size;

    playAgainButton = SpriteComponent();
    playAgainButton.sprite = Sprite(playAgain);
    playAgainButton.size = Vector2(140, 70);
    playAgainButton.position = Vector2(gameRef.size.x/2-90, gameRef.size.y*3/4-50);

    quitButton = SpriteComponent();
    quitButton.sprite = Sprite(quit);
    quitButton.size = Vector2(50, 50);
    quitButton.position = Vector2(gameRef.size.x/2-50, gameRef.size.y*3/4+20);

    addAll([background, playAgainButton, quitButton]);


  }

  // Add this when changing to another page.
  @override
  bool containsLocalPoint(Vector2 point) => true;


  @override
  void onTapDown(TapDownEvent event) {
    if (quitButton.containsPoint(event.localPosition)) {
      gameRef.reset(false);
    }
    if (playAgainButton.containsPoint(event.localPosition)) {
      gameRef.reset(true);

    }
  }
}