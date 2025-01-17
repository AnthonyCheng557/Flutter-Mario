import 'package:flame/components.dart';

import 'dart:math';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/text.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:nextbigthing/components/koopa.dart';
import 'package:nextbigthing/components/level_options.dart';
import 'package:nextbigthing/components/mystery_block.dart';
import 'package:nextbigthing/components/star.dart';
import 'package:nextbigthing/components/virtual_button.dart';
import 'package:nextbigthing/constants/globals/globals.dart';
import 'package:nextbigthing/pages/gameplay_page.dart';
import 'dart:async';
import 'dart:ui';
import 'package:nextbigthing/components/mario.dart';
import 'package:nextbigthing/components/platform.dart';
import 'package:nextbigthing/components/red_mushroom.dart';
import '../pages/hud_component.dart';
import 'brick_blocks.dart';
import 'coin.dart';
import 'door.dart';
import 'flag.dart';
import 'goomba.dart';




class LevelComponent extends Component with HasGameRef<GameplayPage> {
  final LevelOption options;
  late CameraComponent cam;
  late Rect _levelBounds;
  late Polygon levelBoundsShape;
  late Mario mario;
  late Goomba goomba;
  late Koopa koopa;
  late RedMushroom redMushroom;
  late MysteryBlock mysteryBlock;
  late Coin coin;
  late Platform platform;
  late TiledComponent level;
  late TextComponent marioText, coinsText, pointsText, levelTopText, levelMiddleText, livesText, timerText;
  late Image marioImage, coinImage;
  late SpriteComponent marioIcon, coinIcon;
  late Timer countdown;
  late VirtualButton leftKeyButton, rightKeyButton, jumpKeyButton;
  int seconds = 400;
  final AudioPlayer player = AudioPlayer();
  late AudioPool audioPool;

  LevelComponent (this.options) : super();



  @override
  Future<void> onLoad() async {
    level = await TiledComponent.load(options.pathName, Vector2.all(16));
    marioImage = await Flame.images.load("mario_idle.gif");
    coinImage = await Flame.images.load("coin.png");
    countdown = Timer(1, onTick: () {
      if (seconds == 0 && !mario.atDoor) {
        mario.hasDied = true;
        seconds = 400;
      }
      if (seconds > 0) {
        seconds -= 1;
        if (mario.atDoor) {
          mario.points += 50;
        }
      }
    }, repeat: true);

    _levelBounds = Rect.fromLTWH(
      0,
      0,
      level.tileMap.map.width.toDouble() * Globals.numbers.tileSize,
      level.tileMap.map.height.toDouble() * Globals.numbers.tileSize,
    );
    levelBoundsShape = Polygon([
      Vector2(_levelBounds.left, _levelBounds.top),
      Vector2(_levelBounds.right, _levelBounds.top),
      Vector2(_levelBounds.right, _levelBounds.bottom),
      Vector2(_levelBounds.left, _levelBounds.bottom),
    ]);

    loadActors();
    loadPlatform();
    createBlocks();
    loadFlag();
    loadDoor();


    //Setting gameRef.mario to be able to switch to gameover page once mario's lives are 0.
    gameRef.mario = mario;

    final renderer = TextPaint(
      style: const TextStyle(
          fontFamily: 'Super Mario Bros. NES Regular',
        fontSize: 12
      )
    );
    marioText = TextComponent(textRenderer: renderer, text: "MARIO                  WORLD    TIME", position: Vector2(gameRef.camera.visibleWorldRect.topLeft.dx + gameRef.size.x / 2 - 25 + mario.position.x,20));
    pointsText = TextComponent(textRenderer: renderer, text:'${mario.points}', position: Vector2(marioText.position.x, marioText.position.y+15));
    coinsText = TextComponent(textRenderer: renderer, text:'${mario.coins}', position: Vector2(pointsText.position.x+180, pointsText.position.y));
    levelTopText = TextComponent(textRenderer: renderer, text: options.name, position: Vector2(marioText.position.x + 288, marioText.position.y+15));
    levelMiddleText = TextComponent(textRenderer: renderer, text: 'WORLD ${options.name}', position: Vector2(marioText.position.x + 160, gameRef.size.y/2-120));
    timerText = TextComponent(textRenderer: renderer, text: '$seconds', position: Vector2(levelTopText.position.x-115, levelTopText.position.y+5));

    initButtons();

    marioIcon = SpriteComponent(
      sprite: Sprite(marioImage),
      size: Vector2(20, 20),
      position: Vector2(levelMiddleText.position.x + 20, levelMiddleText.position.y + 40)
    );

    coinIcon = SpriteComponent(
      sprite: Sprite(coinImage),
      size: Vector2(13, 13),
      position: Vector2(pointsText.position.x+150, pointsText.position.y)
    );

   // redMushroom = RedMushroom(position: Vector2(pointsText.position.x+150, pointsText.position.y));


    livesText = TextComponent(textRenderer: renderer, text: '${mario.lives}', position: Vector2(marioIcon.position.x + 50, marioIcon.position.y + 5));

    cam = CameraComponent(world: gameRef.world)
      ..viewport.size = Vector2(450, 50)
      ..viewport.position = Vector2(60, 0)
      ..viewfinder.position = Vector2(0, 20)
      ..viewfinder.visibleGameSize = Vector2(450, 50)
      ..viewfinder.anchor = Anchor.topLeft;

    cam.setBounds(levelBoundsShape);
    cam.follow(mario, horizontalOnly: true);
    gameRef.add(cam);

    await FlameAudio.audioCache.load('deathSound.mp3');
    audioPool = await FlameAudio.createPool('deathSound.mp3', maxPlayers: 1);

    return super.onLoad();
  }


  void loadActors() {
    ObjectGroup? actorsLayer = level.tileMap.getLayer<ObjectGroup>('Actors');

    if (actorsLayer == null) {
      throw Exception('Actors layer not found.');
    }

    for (final TiledObject obj in actorsLayer.objects) {
      print(obj.name);
      switch (obj.name) {
        case 'Mario':
          gameRef.world.add(mario = Mario(
              position: Vector2(
                obj.x,
                obj.y - 200,
              ),
              levelBounds: _levelBounds
          ));
          break;
        case 'Goomba':
          gameRef.world.add(goomba = Goomba(
              position: Vector2(
                obj.x,
                obj.y,
              ),
          )..priority=10);
          break;
        case 'Koopa':
          gameRef.world.add(koopa = Koopa(
              position: Vector2(
                  obj.x,
                  obj.y
              ), mario: mario,
          )..priority=10);
          break;
        case 'RedMushroom':
          gameRef.world.add(redMushroom = RedMushroom(
            position: Vector2(
              obj.x,
              obj.y,
            ),
          ));
          break;
        case 'Coin':
          gameRef.world.add(coin = Coin(
              position: Vector2(
                obj.x,
                obj.y,
              ),
          )..priority = 3);
          break;
        case 'Star':
          gameRef.world.add(Star(
              position: Vector2(
                obj.x,
                obj.y,
              ),
          )..priority = 3);
        default:
          break;
      }
    }

  }

  void loadFlag() {
    ObjectGroup? flagLayer = level.tileMap.getLayer<ObjectGroup>('Flag');

    if (flagLayer == null) {
      throw Exception('Flag layer not found');
    }

    for (final TiledObject obj in flagLayer.objects) {
      Flag flag = Flag(
          position: Vector2(obj.x, obj.y),
          timer: countdown,
          mario: mario
      );
      gameRef.world.add(flag);
    }
  }

  void loadDoor() {
    ObjectGroup? doorLayer = level.tileMap.getLayer<ObjectGroup>('Door');

    if (doorLayer == null) {
      throw Exception('Door layer not found');
    }

    for (final TiledObject obj in doorLayer.objects) {
      Door door = Door(
          position: Vector2(obj.x, obj.y),
          size: Vector2(obj.size.x, obj.size.y),
          mario: mario
      );
      gameRef.world.add(door);
    }

  }

  void loadPlatform() {
    //Platform, Floor
    ObjectGroup? platformsLayer = level.tileMap.getLayer<ObjectGroup>('Platforms');

    if (platformsLayer == null) {
      throw Exception('Platforms layer not found.');
    }

    for (final TiledObject obj in platformsLayer.objects) {
      platform = Platform(
        position: Vector2(obj.x, obj.y),
        size: Vector2(obj.width, obj.height),
      );
      gameRef.world.add(platform);
    }
  }

  @override
  Future<void> update(double dt) async {
    marioText.position = Vector2(gameRef.camera.visibleWorldRect.topLeft.dx + gameRef.size.x / 2 - 25 + mario.position.x,20);
    pointsText.position = Vector2(marioText.position.x, marioText.position.y+15);
    levelTopText.position = Vector2(marioText.position.x + 288, marioText.position.y+15);
    timerText.position = Vector2(levelTopText.position.x+105, levelTopText.position.y);
    coinsText.position = Vector2(pointsText.position.x+180, pointsText.position.y);
    coinIcon.position = Vector2(pointsText.position.x+150, pointsText.position.y);

    updateButtons();

    timerText.text = '$seconds';
    pointsText.text = '${mario.points}';
    coinsText.text = '${mario.coins}';

    if (mario.hasDied) {
      seconds = 400;

      if(mario.deathSound == true){
        audioPool.start();
        mario.deathSound = false;
        await Future.delayed(Duration(seconds: 3));
      }

      //await player.pause();
      if (mario.lives > 0) {
        await displayInfo();
        await displayButtons();

      }
      mario.decrementLife();
      /*redMushroom.reset();*/
      mario.inputDisabled = false;

    }

    if (cam.canSee(koopa) && !koopa.isShell) {
      koopa.direction = Direction.left;
    }

    if (mario.pause) {
      countdown.pause();
      mario.pause = false;
    }

    if (mario.position.y > _levelBounds.bottom && !mario.hasDied) {
      mario.reset();
      mario.inputDisabled = true;
      mario.pause = true;
      
      //For sound designer: Match seconds with the length of death sound.
      //await Future.delayed(const Duration(seconds: 3));
      mario.position = Vector2(24, 192);
      mario.deathSound = true;
      mario.hasDied = true;
    }
    if (mario.atDoor) {
      countdown.resume();
      countdown.update(dt*65);

      if (seconds == 0) {
        await Future.delayed(const Duration(seconds: 3));
        mario.hasWon = true;
      }
    }
    else {
      countdown.update(dt);
    }
  }

  Future<void> displayInfo() async {

    timerText.parent != null ? gameRef.world.remove(timerText) : timerText.priority = -1;
    level.parent != null ? gameRef.world.remove(level) : level.priority = -1;
    mario.parent != null ? gameRef.world.remove(mario) : mario.priority = -1;
    platform.parent != null ? gameRef.world.remove(platform) : platform.priority = -1;

    livesText.text = '${mario.lives}';

    await gameRef.world.addAll([marioText..priority = 4,
      levelTopText..priority = 4, pointsText..priority = 4, levelMiddleText..priority = 4, marioIcon..priority = 4,
      coinIcon..priority = 4, coinsText..priority = 4, livesText..priority = 4]);

    await Future.delayed(const Duration(seconds: 3));

    levelMiddleText.parent != null ? gameRef.world.remove(levelMiddleText) : levelMiddleText.priority = 0;
    marioIcon.parent != null ? gameRef.world.remove(marioIcon) : marioIcon.priority = 0;
    livesText.parent != null ? gameRef.world.remove(livesText) : livesText.priority = 0;


    gameRef.world.addAll([level..priority = 1, platform..priority = 2,
    timerText..priority = 2, mario..priority = 3, redMushroom..priority = 3]);


   countdown.resume();
  }

  void initButtons() {
    leftKeyButton = VirtualButton(
      onPressed: () => mario.onLeftKeyPressed(),
      onReleased: () => mario.onLeftKeyReleased(),
      buttonSize: Vector2(60, 60),
      label: '←',
      position: Vector2.zero(),
    );

    rightKeyButton = VirtualButton(
      onPressed: () => mario.onRightKeyPressed(),
      onReleased: () => mario.onRightKeyReleased(),
      buttonSize: Vector2(60, 60),
      label: '→',
      position: Vector2.zero(),
    );

    jumpKeyButton = VirtualButton(
      onPressed: () => mario.onJumpKeyPressed(),
      onReleased: () => mario.onJumpKeyReleased(),
      buttonSize: Vector2(60, 60),
      label: '↑',
      position: Vector2.zero(),
    );

  }

  void updateButtons() {
    leftKeyButton.position = Vector2(
      gameRef.camera.visibleWorldRect.bottomLeft.dx
          + gameRef.size.x / 2 - 25 + mario.position.x,
      gameRef.camera.visibleWorldRect.bottomLeft.dy - leftKeyButton.height
    );

    rightKeyButton.position = Vector2(
        leftKeyButton.position.x + leftKeyButton.width,
        gameRef.camera.visibleWorldRect.bottomLeft.dy - rightKeyButton.height
    );

    jumpKeyButton.position = Vector2(
        gameRef.camera.visibleWorldRect.bottomRight.dx - jumpKeyButton.width
            + mario.position.x - 50,
        gameRef.camera.visibleWorldRect.bottomLeft.dy - jumpKeyButton.height
    );
  }

  Future<void> displayButtons() async {
    leftKeyButton.parent != null ?
      gameRef.world.remove(leftKeyButton) : leftKeyButton.priority = -1;
    rightKeyButton.parent != null ?
      gameRef.world.remove(rightKeyButton) : rightKeyButton.priority = -1;
    jumpKeyButton.parent != null ?
      gameRef.world.remove(jumpKeyButton) : jumpKeyButton.priority = -1;

    gameRef.world.addAll([
      leftKeyButton..priority = 4,
      rightKeyButton..priority = 4,
      jumpKeyButton..priority = 4]
    );
  }
  //blocks in level
  void createBlocks() {
    ObjectGroup? blocksLayer = level.tileMap.getLayer<ObjectGroup>('Blocks');
    if (blocksLayer == null) {
      throw Exception('Block layer not found in Tile.Io');
    }
    for(final TiledObject obj in blocksLayer.objects) {
      switch(obj.name) {
        case 'Mystery':
           MysteryBlock mysteryBlock = MysteryBlock(
            position: Vector2(obj.x, obj.y),
          );
          gameRef.world.add(mysteryBlock..priority=4);
          break;
        case 'Brick':
          BrickBlock brickBlock = BrickBlock(
            position: Vector2(obj.x, obj.y),
            shouldCrumble: Random().nextBool(),
          );
          gameRef.world.add(brickBlock..priority=4);
          break;

        default:
          break;
      }
    }
  }

}


