import 'dart:async' as async;


import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:nextbigthing/components/goomba.dart';
import 'package:nextbigthing/components/star.dart';
import '../constants/globals/globals.dart';
import '../constants/animations/animations_configs.dart';
import 'package:nextbigthing/components/platform.dart';
import 'package:nextbigthing/components/red_mushroom.dart';
import 'package:flame_audio/flame_audio.dart';

import 'coin.dart';
import 'koopa.dart';
// import 'package:shake/shake.dart';

bool shaked = false;


enum MarioAnimationStates {
  idle,
  walking,
  jumping,
  sliding,
  invincibleIdle,
  invincibleWalking,
  invincibleJumping
}


class Mario extends SpriteAnimationGroupComponent<MarioAnimationStates>
    with CollisionCallbacks, KeyboardHandler {


  static const double _gravity = 200;
  static const double _jumpHoldGravity = 50;
  static const double _maxJumpHoldTime = 0.7;
  static const double _instantJumpSpeed = 100;
  static const double _maxFallSpeed = 150;
  // static const double _minMoveSpeed = 100;
  static const double _maxMoveSpeed = 100;
  static double _moveAcceleration = 100;
  set moveAcceleration(double value) => _moveAcceleration = value;
  static const double _friction = 10;
  static const double _scaleSize = 1;
  late AudioPool audioPool;

  Vector2 _velocity = Vector2.zero();
  set velocity(Vector2 v) {
    _velocity = v;
  }
  Vector2 _acceleration = Vector2(0, 0);


  late Vector2 _minClamp;
  late Vector2 _maxClamp;


  int _hAxis = 0;
  int get hAxis => _hAxis;
  set hAxis(int value) {
    _hAxis = value;
  }
  int _hAxis_left = 0;
  int _hAxis_right = 0;
  set hAxis_right(int value) {
    _hAxis_right = value;
  }
  int _vAxis = 0;

  int lives = 3;
  int points = 0;
  int coins = 0;

  bool _isOnGround = false;
  bool isSliding = false;
  //Kept it true so infoscreen is displayed at the beginning of level.
  bool hasDied = true;
  bool hasWon = false;
  bool atDoor = false;
  bool pause = false;
  bool inputDisabled = false;
  bool shake_used = false;
  bool _isJumpHold = false;
  bool _goombaSmash = false;
  double _jumpHoldTime = 0;
  bool invincible = false;
  bool sizeUp = false;
  double invincibleTime = 0;
  bool deathSound = false;

  Mario({required Vector2 position,
    required Rect levelBounds
  })
      : super(
      position: position,
      size: Vector2(Globals.numbers.tileSize, Globals.numbers.tileSize),
      anchor: Anchor.center
  ) {
    debugMode = true;


    _minClamp = Vector2(levelBounds.left, levelBounds.top) + (size / 2);
    _maxClamp = Vector2(levelBounds.right, levelBounds.bottom) + (size / 2);


    add(CircleHitbox());
  }



  @override
  async.FutureOr<void> onLoad() async {

    final SpriteAnimation idle = await AnimationConfigs.mario.idle();
    final SpriteAnimation walking = await AnimationConfigs.mario.walking();
    final SpriteAnimation jumping = await AnimationConfigs.mario.jumping();
    final SpriteAnimation sliding = await AnimationConfigs.mario.sliding();
    final SpriteAnimation invincibleIdle = await AnimationConfigs.mario.invincibleIdle();
    final SpriteAnimation invincibleWalking = await AnimationConfigs.mario.invincibleWalking();
    final SpriteAnimation invincibleJumping = await AnimationConfigs.mario.invincibleJumping();

    animations = {
      MarioAnimationStates.idle: idle,
      MarioAnimationStates.walking: walking,
      MarioAnimationStates.jumping: jumping,
      MarioAnimationStates.sliding: sliding,
      MarioAnimationStates.invincibleIdle: invincibleIdle,
      MarioAnimationStates.invincibleWalking: invincibleWalking,
      MarioAnimationStates.invincibleJumping: invincibleJumping,
    };

    current = MarioAnimationStates.idle;
    moveAcceleration = 100;
    // _detector = ShakeDetector.autoStart(onPhoneShake: _onShake);

    await FlameAudio.audioCache.load('maro-jump-sound-effect_1.mp3');
    audioPool = await FlameAudio.createPool('maro-jump-sound-effect_1.mp3', maxPlayers: 1);
    /*
    await FlameAudio.audioCache.load('backgroundMusic.mp3');
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('backgroundMusic.mp3', volume: 1);
  */
    return super.onLoad();

  }
/*
  @override
  void onRemove() async{
    await FlameAudio.bgm.stop();
    FlameAudio.bgm.dispose();
    super.onRemove();
 */

  //testing
  Vector2 get velocity => _velocity;

  void _onShake(){
    print("Function Shake" + shaked.toString());

    shaked = false;

    if(_isOnGround == false && shake_used == false){
      double _temp = _velocity.y;

      _velocity.y = 20;

      shake_used = true;

      async.Timer(const Duration(milliseconds: 500), ()=>_velocity.y = _temp);
    }

  }


  @override
  void update(double dt) {

    if(dt >0.05){
      return;
    }

    if (shaked == true){
      _onShake();
    }

    super.update(dt);
    if (dt > 0.05) return;
    updateAnimation();
    updateFacingDirection();
    updateJumpHoldTime(dt);
    updateHAxis();
    updatePosition(dt);
    updateVelocity(dt);
    updateAcceleration(dt);
    updateInvincible(dt);
  }

  void updateAnimation() {
    if (invincible) {
      current = _isOnGround ?
      _hAxis != 0 ? MarioAnimationStates.invincibleWalking : MarioAnimationStates.invincibleIdle
          : MarioAnimationStates.invincibleJumping;
    } else {
      current = _isOnGround ?
      _hAxis != 0 ? MarioAnimationStates.walking : MarioAnimationStates.idle
          : isSliding ? MarioAnimationStates.sliding : MarioAnimationStates.jumping;
    }
  }

  void updateJumpHoldTime(double dt) {
    if (_isJumpHold && _jumpHoldTime < _maxJumpHoldTime) {
      _jumpHoldTime += dt;
    }
  }


  void updatePosition(double dt) {
    position += _velocity * dt + _acceleration * dt * dt / 2;


    position.clamp(_minClamp, _maxClamp);
  }


  void updateVelocity(double dt) {
    _velocity += _acceleration * dt;
    _velocity.y = _velocity.y.clamp(-_instantJumpSpeed, _maxFallSpeed);
    _velocity.x = _velocity.x.clamp(-_maxMoveSpeed, _maxMoveSpeed);
  }


  void updateAcceleration(double dt) {
    if (_hAxis != 0) {
      _acceleration = Vector2(
          _hAxis * _moveAcceleration,
          (_isJumpHold && _jumpHoldTime < _maxJumpHoldTime)  ?
          _jumpHoldGravity  : _gravity
      );
    } else {
      double friction = _isOnGround ? _friction : 0;
      _acceleration = Vector2(
          -friction * _velocity.x,
          (_isJumpHold && _jumpHoldTime < _maxJumpHoldTime)  ?
          _jumpHoldGravity : _gravity
      );
    }
  }

//here
  @override
  async.Future<void> onCollision(Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollision(intersectionPoints, other);

    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        moveOutFromPlatform(intersectionPoints);
      }
    }
    else if (other is Goomba){
      if (intersectionPoints.length == 2) {

        if(position.y < other.position.y || invincible){
          _goombaSmash = true;
          other.goombaSmashed();
          this._velocity.y = -75;
          points += 100;

        }else if (sizeUp == true) {
          setSizeScale(1);
          sizeUp = false;
          jump();
        }
        else {


          //Put Death Animation here

          this.reset();
          this.inputDisabled = true;
          //countdown.pause();

          //For sound designer: Match seconds with the length of death sound.

          this.position = Vector2(24, 192);
          this.hasDied = true;
          this.deathSound = true;
        }
      }
    }
    else if (other is RedMushroom) {
      //position.y -= 15;
      setSizeScale(2);
      sizeUp = true;
      /*moveOutFromPlatform(intersectionPoints);*/
    }
    else if (other is Koopa) {
      if (!other.isShell) {
        if (_isOnGround && !invincible && sizeUp == false) {
          reset();
          inputDisabled = true;
          other.direction = Direction.none;
          await Future.delayed(const Duration(seconds: 3));
          position = Vector2(24, 192);
          pause = true;
          hasDied = true;

          other.position = Vector2(1662, 192);
          other.reset();
        }else if (sizeUp == true && _isOnGround && !invincible) {
          setSizeScale(1);
          sizeUp = false;
          jump();
        }
        else {
          if (!invincible) {
            other.direction = Direction.none;
            other.current = KoopaAnimationStates.idle;
            _velocity.y = -90;
            other.isShell = true;
          }
          else {
            other.removeFromParent();
          }
          points += hasDied ? 0 : 100;
        }
      }
      else {
        if (other.velocity.x == 0) {
          if (!other.hasBeenHit) {
            if (_hAxis_left > 0) {
              other.position.x -= 10;
              other.direction = Direction.left;
            }
            else {
              other.position.x += 10;
              other.direction = Direction.right;
            }
          }
          points += other.hasBeenHit ? 0 : 400;
          other.hasBeenHit = true;
        }
        else {
          if (_isOnGround && !invincible) {
            other.direction = Direction.none;
            print(other.velocity.x);
            _velocity.y = -90;
            reset();
            inputDisabled = true;
            await Future.delayed(const Duration(seconds: 3));
            position = Vector2(24, 192);
            pause = true;
            hasDied = true;

            other.position = Vector2(1662, 192);
            other.reset();
          }
          else {
            other.velocity.x = 0;
            other.direction = Direction.none;
            other.hasBeenHit = false;
            _velocity.y = -90;
            points += 100;
          }
        }

      }
    }
    else if (other is Coin) {
      points += 100;
      coins += 1;
    }
    else if (other is Star) {
      invincibleTime = other.effectTime;
      invincible = true;
    }
  }


  void moveOutFromPlatform(Set<Vector2> intersectionPoints) {
    final Vector2 mid =
        (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;


    final Vector2 collisionNormal = absoluteCenter - mid;
    double penetrationDepth = (size.x / 2) - collisionNormal.length;
    collisionNormal.normalize();


    if (Vector2(0, -1).dot(collisionNormal) > 0.9) {
      _isOnGround = true;
      _jumpHoldTime = 0;
      shake_used = false;
      isSliding = false;
      _goombaSmash = false;

    }

    position += collisionNormal.scaled(penetrationDepth);
  }


  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (!inputDisabled) {

      if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        jump();
        _isJumpHold = true;
      }
      else if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
        _hAxis_left = 1;
      }
      else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
        _hAxis_right = 1;
      }
      else {
        _hAxis_left = 0;
        _hAxis_right = 0;
          _isJumpHold = false;
        _goombaSmash = false;
      }
    }
    return super.onKeyEvent(event, keysPressed);
  }

  void updateHAxis() {
    _hAxis = -_hAxis_left + _hAxis_right;
  }

  void onLeftKeyPressed() {
    _hAxis_left = 1;
  }

  void onLeftKeyReleased() {
    _hAxis_left = 0;
  }

  void onRightKeyPressed() {
    _hAxis_right = 1;
  }

  void onRightKeyReleased() {
    _hAxis_right = 0;
  }

  void onJumpKeyPressed() {
    jump();
    _isJumpHold = true;
  }

  void onJumpKeyReleased() {
    _isJumpHold = false;
  }

  void updateFacingDirection() {
    if (_hAxis > 0 && scale.x < 0 || _hAxis < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
  }

  void updateInvincible(double dt) {
    if (invincible) {
      invincibleTime -= dt;
      if (invincibleTime <= 0) {
        invincible = false;
        invincibleTime = 0;
      }
    }
  }

  void jump() {
    if (_isOnGround) {
      audioPool.start();
      _velocity.y = -_instantJumpSpeed;
    }
    _isOnGround = false;
  }


  void setSizeScale(double scale){
    size = Vector2(Globals.numbers.tileSize, Globals.numbers.tileSize) * scale;
  }

  void decrementLife() {
    if (hasDied) {
      lives -= 1;
      setSizeScale(1);
      
      hasDied = false;
    }
  }

  void reset() {
    _velocity = Vector2.zero();
    _acceleration = Vector2(0, 0);
    _hAxis = 0;
  }




}