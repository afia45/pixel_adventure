import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/components/collision_block.dart';
import 'package:pixel_adventure/components/player_hitbox.dart';
import 'package:pixel_adventure/components/utils.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

enum PlayerState { idle, running, jumping, falling}

class Player extends SpriteAnimationGroupComponent with HasGameReference<PixelAdventure>, KeyboardHandler{
  //grp component makes it easier to switch btwn idle to running and so on

  Player({position, this.character = 'Ninja Frog'}) : super(position: position);
  String character;

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runningAnimation;
  late final SpriteAnimation jumpingAnimation;
  late final SpriteAnimation fallingAnimation;
  final double stepTime = 0.05; //20sec fps
  //final double _friction = 0.83; //slip effect

  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 300;
  double horizontalMovement = 0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool hasJumped = false;
  List<CollisionBlock> collisionBlocks = [];
  PlayerHitbox hitbox = PlayerHitbox(offsetX: 
  10, offsetY: 4, width: 14, height: 28,);

  @override
  FutureOr<void> onLoad() {
    _loadAllAniamtions();
    debugMode = true; //see collisions on player
    add(RectangleHitbox(//see hitbox
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollision();
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0;
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);

    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }
  
  void _loadAllAniamtions() {
    idleAnimation = _spriteAnimation('Idle', 11);
    runningAnimation =_spriteAnimation('Run', 12);
    jumpingAnimation =_spriteAnimation('Jump', 1);
    fallingAnimation =_spriteAnimation('Fall', 1);

    //List of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runningAnimation,
      PlayerState.jumping: jumpingAnimation,
      PlayerState.falling: fallingAnimation,
    };

    //Set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String state, int frames){
    return SpriteAnimation.fromFrameData(game.images.fromCache('Main Characters/$character/$state (32x32).png'), SpriteAnimationData.sequenced(
      amount: frames, //no. of imgs in the animation
      stepTime: stepTime,
      textureSize: Vector2.all(32)
    ));
  }

  
  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if(velocity.x < 0 && scale.x > 0){
      flipHorizontallyAroundCenter();
    }else if(velocity.x > 0 && scale.x < 0){
      flipHorizontallyAroundCenter();
    }

    // Check if moving, set running
    if(velocity.x > 0 || velocity.x < 0){
      playerState = PlayerState.running;
    }

    //Check if falling set to falling
    if(velocity.y > 0){
      playerState = PlayerState.falling;
    }

    //Checks if jumping, set to jumping
    if(velocity.y < 0){
      playerState = PlayerState.jumping;
    }

    current = playerState;
  }
  
  void _updatePlayerMovement(double dt) {

    if(hasJumped && isOnGround){
      _playerJump(dt);
    }

    //remove double jump with this if state
    // if(velocity.y > _gravity){
    //   isOnGround = false;
    // }

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;//dt is delta time
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }
  
  void _checkHorizontalCollisions() {
    for(final block in collisionBlocks){
      //handle collision
      if(!block.isPlatform){
        if(checkCollision(this, block)) {
          if(velocity.x > 0){
            velocity.x = 0;
            position.x = block.x - width;
            break;
          }
          if(velocity.x < 0){
            velocity.x = 0;
            position.x = block.x + block.width + width;
            break;
          }
        }
      }
    }
  }
  
  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;

  }
  
  void _checkVerticalCollision() {
    for (final block in collisionBlocks){
      if(block.isPlatform){
        //handle platform
        if(checkCollision(this, block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - width;
            isOnGround = true;
            break;
          }
        }
      }else{
        if(checkCollision(this, block)){
          if(velocity.y > 0){
            velocity.y = 0;
            position.y = block.y - width;
            isOnGround = true;
            break;
          }
          if(velocity.y < 0){
            velocity.y = 0;
            position.y = block.y + block.height;

          }
        }
      }
    }
  }
  
  void jump() {
  if (isOnGround) {
    hasJumped = true;
  }
}
  
}