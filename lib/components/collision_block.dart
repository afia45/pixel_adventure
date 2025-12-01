import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent{
  bool isPlatform;
  CollisionBlock({position, size, this.isPlatform = false}) : super(position: position, size: size,) 
  
  {debugMode=true;} //see x,y width and height of collisions
}