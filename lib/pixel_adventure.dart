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
  late ButtonComponent jumpButton;
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
    priority = -1;
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam,world]);

    if(showJoystick){
      addJoyStick();
      addJumpButton();
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
      margin: EdgeInsets.only(left: 1, bottom: 48),
    );

    cam.viewport.add(joystick); //cam.viewport.add(joystick)
    
  }
  
  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      default:
        //idle
        player.horizontalMovement = 0;
        break;
    }
  }
  
  void addJumpButton() {
    jumpButton = ButtonComponent(
      // The button's size (adjust as needed)
      size: Vector2.all(64), 
      // The margin positions the button on the screen
      // We place it on the right side, above the bottom margin
      position: Vector2(size.x - 64 - 32, size.y - 48), 
      anchor: Anchor.topRight, // Anchor to top-right of its position
      
      // Use a sprite for the button's appearance (you'll need to add a 'JumpButton.png')
      // You can use a simple color if you don't have a sprite yet:
      button: SpriteComponent(
        sprite: Sprite(images.fromCache('HUD/Jump.png')), // Replace with your image path
      ),
      
      // Action when the button is pressed
      onPressed: player.jump, // <-- Calls the public jump method in Player.dart
      
      // The positioning must be relative to the viewport's size (size.x and size.y)
      // Since it's fixed to the screen, we need to know the screen size.
    );

    // Adjust position based on size.x (screen width) and size.y (screen height)
    jumpButton.position = Vector2(
        cam.viewport.size.x + 3, // to the right edge
        cam.viewport.size.y - 48  // 48 pixels from the bottom edge (matching joystick bottom)
    );
    jumpButton.anchor = Anchor.bottomRight;


    // Add to the camera's viewport to keep it fixed on the screen
    cam.viewport.add(jumpButton);
  }

}