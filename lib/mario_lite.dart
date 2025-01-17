import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:nextbigthing/pages/gameover_page.dart';
import 'package:nextbigthing/pages/gameplay_page.dart';
import 'package:nextbigthing/pages/title_page.dart';

class MarioLite extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents{
  late RouterComponent router;
  bool isPlayingAgain = false;

  @override
  FutureOr<void> onLoad() {

    add(
      router = RouterComponent(
          routes: {
            'title': Route(TitlePage.new),
            'gameplay': Route(() => GameplayPage(router: router, gameRef: this)),
            'gameover': Route(GameoverPage.new),
          },
          initialRoute: determineInitialRoute()
      ),
    );

    return super.onLoad();
  }

  void reset(bool value) {
    for (var component in children) {
      component.removeFromParent();
    }
    isPlayingAgain = value;
    onLoad();
  }

  String determineInitialRoute() {
    return isPlayingAgain ? "gameplay" : "title";
  }

}