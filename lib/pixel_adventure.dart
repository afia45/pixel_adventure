import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/level.dart';

class PixelAdventure extends FlameGame {

  @override
  Color backgroundColor() => const Color(0xFF211F30); //covering up the blank screen on the sides for longer screens
  late final CameraComponent cam;


  final world = Level(
    levelName: 'Level-02'
  );

  @override
  FutureOr<void> onLoad() async{
    //Load all image into cache
    await images.loadAllImages(); //load all, but dont load all if theres too much images, takes game longer to load

    cam = CameraComponent.withFixedResolution(world: world, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam,world]);



    return super.onLoad();
  }

}