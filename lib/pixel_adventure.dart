import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/components/player.dart';
import 'package:pixel_adventure/components/level.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents, DragCallbacks {

  @override
  Color backgroundColor() => const Color(0xFF211F30); //covering up the blank screen on the sides for longer screens
  late final CameraComponent cam;
  Player player = Player(character: 'Mask Dude');
  late JoystickComponent joystick;
  bool showJoystick = true; // set false for desktop app and true for mobile

  @override
  FutureOr<void> onLoad() async{
    //Load all image into cache
    await images.loadAllImages(); //load all, but dont load all if theres too much images, takes game longer to load
    final world = Level(
    player: player,
    levelName: 'Level-02'
  );

    cam = CameraComponent.withFixedResolution(
      world: world, 
      width: 640, 
      height: 360
    );
    priority = 0;
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam,world]);

    if(showJoystick){
      addJoyStick();
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(showJoystick){
      updateJoystick();
    }
    super.update(dt);
  }
  
  void addJoyStick() {
    joystick = JoystickComponent(
      priority: 10,
      //created joystick in figma
      knob: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Knob.png'),
        ),
      ),
      //knobRadius: 15, //radius to drag knob outside
      background: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Joystick.png')
        )
      ),
      margin: EdgeInsets.only(left: 32, bottom: 48),
    );

    add(joystick); //cam.viewport.add(joystick)
    
  }
  
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.playerDirection = PlayerDirection.left;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.playerDirection = PlayerDirection.right;
        break;
      default:
        //idle
        player.playerDirection = PlayerDirection.none;
        break;
    }
  }

}