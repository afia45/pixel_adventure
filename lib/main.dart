import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape(); //game in landscape

  PixelAdventure game = PixelAdventure();
  runApp(GameWidget(game:kDebugMode ? PixelAdventure() : game)); //kdebug mode to recreate state everytime i save a file (for debug mode)
}

